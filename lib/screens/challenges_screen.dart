import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'home_feed_screen.dart';
import 'workout_log_screen.dart';
import 'photo_journal_screen.dart';
import 'profile_screen.dart';
import 'new_challenge.dart';
import 'pushup_challenge_screen.dart';

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
      case 1:
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Challenges"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "All Challenges",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _pushupChallengeCard(),
              const SizedBox(height: 16),
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
                  if (docs.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      return _buildChallengeCard(docs[index]);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const NewChallenge()));
        },
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
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
    if (uid == null) {
      return _challengeCardContent(doc, isJoined: false, onJoin: null);
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('challenges')
          .doc(doc.id)
          .collection('participants')
          .doc(uid)
          .get(),
      builder: (context, snapshot) {
        final remoteJoined = snapshot.data?.exists ?? false;
        final isJoined = remoteJoined || _localJoined.contains(doc.id);
        return _challengeCardContent(
          doc,
          isJoined: isJoined,
          onJoin: () => _joinChallenge(doc.id),
        );
      },
    );
  }

  Widget _pushupChallengeCard() {
    const challengeId = 'pushup_50_per_day_week';
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text(
                  "Featured Challenge",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Chip(
                  label: Text("Push-ups"),
                  backgroundColor: Colors.orangeAccent,
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              "50 Push-ups a Day for 7 Days",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text("Log daily reps; hit 50+ to stay on track."),
            const SizedBox(height: 10),
            if (uid == null)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PushupChallengeScreen()));
                },
                child: const Text("Open Challenge"),
              )
            else
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _challengeService.streamParticipant(challengeId, uid),
                builder: (context, snapshot) {
                  final joined = snapshot.data?.exists ?? false;
                  return Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PushupChallengeScreen()),
                          );
                        },
                        child: const Text("Open Challenge"),
                      ),
                      const SizedBox(width: 8),
                      if (joined)
                        const Text(
                          "Joined",
                          style: TextStyle(
                              color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _challengeCardContent(QueryDocumentSnapshot<Map<String, dynamic>> doc,
      {required bool isJoined, VoidCallback? onJoin}) {
    final data = doc.data();
    final title = data['title'] as String? ?? 'Untitled challenge';
    final description = data['description'] as String? ?? 'No description';
    final difficulty = data['difficulty'] as String? ?? 'N/A';
    final author = data['authorName'] as String? ?? 'Unknown';

    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text("Author: $author"),
            Text("Difficulty: $difficulty"),
            const SizedBox(height: 10),

            if (!isJoined)
              ElevatedButton(
                onPressed: onJoin,
                child: const Text("Join Challenge"),
              ),

            if (isJoined)
              const Text(
                "Joined",
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _joinChallenge(String id) async {
    try {
      await _challengeService.joinChallenge(id);
      setState(() {
        _localJoined.add(id);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Join failed: $e')),
        );
      }
    }
  }
}
