import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'home_feed_screen.dart';
import 'workout_log_screen.dart';
import 'photo_journal_screen.dart';
import 'profile_screen.dart';
import 'new_challenge.dart';
import 'challenge_detail_screen.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  int _currentIndex = 1;
  final ChallengeService _challengeService = ChallengeService();
  final Set<String> _localJoined = {};

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeFeedScreen()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => WorkoutLogScreen()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => PhotoJournalScreen()));
        break;
      case 4:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Challenges")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Featured Challenges",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _featuredChallenges(),
            const SizedBox(height: 24),

            const Text("All Challenges",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _challengeService.streamActiveChallenges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Failed to load challenges: ${snapshot.error}');
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return const SizedBox.shrink();

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.1,
                  ),
                  itemBuilder: (context, index) =>
                      _buildChallengeCard(docs[index]),
                );
              },
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const NewChallenge())),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor:
            Theme.of(context).colorScheme.secondary.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events), label: "Challenges"),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: "Workout"),
          BottomNavigationBarItem(icon: Icon(Icons.photo), label: "Journal"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    void open() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChallengeDetailScreen(
            challengeId: doc.id,
            title: doc.data()['title'] ?? 'Untitled',
            description: doc.data()['description'] ?? '',
            difficulty: doc.data()['difficulty'] ?? 'N/A',
          ),
        ),
      );
    }

    if (uid == null) {
      return _challengeCardContent(
        doc,
        isJoined: false,
        onOpen: open,
        onJoin: null,
      );
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('challenges')
          .doc(doc.id)
          .collection('participants')
          .doc(uid)
          .get(),
      builder: (context, snapshot) {
        final bool isJoined =
          (snapshot.data?.exists ?? false) || _localJoined.contains(doc.id);

        final VoidCallback onJoin = isJoined
            ? () => _leaveChallenge(doc.id)
            : () => _joinChallenge(doc.id);

        return _challengeCardContent(
          doc,
          isJoined: isJoined,
          onOpen: open,
          onJoin: onJoin,
        );
      },
    );
  }

  Widget _challengeCardContent(
    QueryDocumentSnapshot<Map<String, dynamic>> doc, {
    required bool isJoined,
    VoidCallback? onJoin,
    VoidCallback? onOpen,
  }) {
    final data = doc.data();

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['title'] ?? 'Untitled',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(data['description'] ?? 'No description',
                maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text("Difficulty: ${data['difficulty'] ?? 'N/A'}"),
            const SizedBox(height: 10),

            Row(
              children: [
                SizedBox(
                  width: 85,
                  child: ElevatedButton(
                    onPressed: onOpen,
                    child: const Text("Open"),
                  ),
                ),
                const SizedBox(width: 12),

                SizedBox(
                  width: 90,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isJoined ? Colors.grey : Colors.orange,
                    ),
                    onPressed: onJoin,
                    child: Text(isJoined ? "Leave" : "Join"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _featuredChallenges() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('challenges')
          .where('featured', isEqualTo: true)
          .where('active', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Failed to load featured challenges');
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Text("No featured challenges right now.");
        }

        return Column(
          children: docs.map(_buildChallengeCard).toList(),
        );
      },
    );
  }

  Future<void> _joinChallenge(String id) async {
    try {
      await _challengeService.joinChallenge(id);
      setState(() => _localJoined.add(id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Join failed: $e')));
    }
  }

  Future<void> _leaveChallenge(String id) async {
    try {
      await _challengeService.leaveChallenge(id);
      setState(() => _localJoined.remove(id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Leave failed: $e')));
    }
  }
}