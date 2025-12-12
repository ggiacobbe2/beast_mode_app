import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final String challengeId;
  final String title;
  final String description;
  final String difficulty;

  const ChallengeDetailScreen({
    super.key,
    required this.challengeId,
    required this.title,
    required this.description,
    required this.difficulty,
  });

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  final ChallengeService _challengeService = ChallengeService();
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  bool _isJoined = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkJoined();
  }

  Future<void> _checkJoined() async {
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('challenges')
        .doc(widget.challengeId)
        .collection('participants')
        .doc(uid)
        .get();
    setState(() {
      _isJoined = doc.exists;
      _loading = false;
    });
  }

  Future<void> _joinChallenge() async {
    if (uid == null) return;
    await _challengeService.joinChallenge(widget.challengeId);
    setState(() {
      _isJoined = true;
    });
  }

  Future<void> _markDayCompleted(int day) async {
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('challenges')
        .doc(widget.challengeId)
        .collection('progress')
        .doc(uid)
        .set({'day$day': true}, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _progressStream() {
    if (uid == null) {
      // dummy stream for null user
      return const Stream.empty() as Stream<DocumentSnapshot<Map<String, dynamic>>>;
    }
    return FirebaseFirestore.instance
        .collection('challenges')
        .doc(widget.challengeId)
        .collection('progress')
        .doc(uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.description),
                  const SizedBox(height: 8),
                  Text("Difficulty: ${widget.difficulty}"),
                  const SizedBox(height: 16),
                  if (!_isJoined)
                    ElevatedButton(
                      onPressed: _joinChallenge,
                      child: const Text("Join Challenge"),
                    ),
                  if (_isJoined)
                    Expanded(
                      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: _progressStream(),
                        builder: (context, snapshot) {
                          final progress = snapshot.data?.data() ?? {};
                          return ListView.builder(
                            itemCount: 7, // example: 7-day challenge
                            itemBuilder: (context, index) {
                              final dayNum = index + 1;
                              final completed = progress['day$dayNum'] == true;
                              return ListTile(
                                title: Text("Day $dayNum"),
                                trailing: completed
                                    ? const Icon(Icons.check, color: Colors.green)
                                    : ElevatedButton(
                                        onPressed: () => _markDayCompleted(dayNum),
                                        child: const Text("Complete"),
                                      ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}