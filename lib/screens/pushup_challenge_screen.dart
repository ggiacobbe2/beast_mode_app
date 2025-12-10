import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class PushupChallengeScreen extends StatefulWidget {
  const PushupChallengeScreen({super.key});

  @override
  State<PushupChallengeScreen> createState() => _PushupChallengeScreenState();
}

class _PushupChallengeScreenState extends State<PushupChallengeScreen> {
  static const String challengeId = 'pushup_50_per_day_week';
  final ChallengeService _challengeService = ChallengeService();
  final _countCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _countCtrl.dispose();
    super.dispose();
  }

  String _dayKey(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  List<Map<String, dynamic>> _last7Days(Map<String, dynamic> records) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: i));
      final key = _dayKey(day);
      final count = (records[key] as num?)?.toInt() ?? 0;
      return {
        'label': "${day.month}/${day.day}",
        'count': count,
        'met': count >= 50,
      };
    }).reversed.toList();
  }

  Future<void> _saveCount(String uid) async {
    final parsed = int.tryParse(_countCtrl.text.trim());
    if (parsed == null || parsed < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid number of push-ups.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await _challengeService.upsertProgress(
        challengeId: challengeId,
        uid: uid,
        dayKey: _dayKey(DateTime.now()),
        count: parsed,
      );
      _countCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress saved for today.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Sign in to join the challenge.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("50 Push-ups/Day • 7 Days")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Challenge",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("Do 50 push-ups every day for 7 days straight."),
                  SizedBox(height: 4),
                  Text("Log your daily count; aim for 50+ to stay on track."),
                ],
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _challengeService.streamParticipant(challengeId, user.uid),
              builder: (context, participantSnap) {
                final joined = participantSnap.data?.exists ?? false;
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: _submitting
                          ? null
                          : () async {
                              try {
                                if (joined) {
                                  await _challengeService.leaveChallenge(challengeId);
                                } else {
                                  await _challengeService.joinChallenge(challengeId);
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Action failed: $e')),
                                );
                              }
                            },
                      child: Text(joined ? "Leave Challenge" : "Join Challenge"),
                    ),
                    const SizedBox(width: 12),
                    if (joined)
                      const Text(
                        "You're in!",
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _challengeService.streamProgress(challengeId, user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data?.data() ?? {};
                final records = (data['records'] as Map<String, dynamic>?) ?? {};
                final days = _last7Days(records);
                final metCount = days.where((d) => d['met'] == true).length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Progress: $metCount / 7 days",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: metCount / 7,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Log today's push-ups",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _countCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Count",
                              hintText: "e.g., 50",
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _submitting ? null : () => _saveCount(user.uid),
                          child: _submitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text("Save"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Last 7 days",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...days.map((d) => ListTile(
                          dense: true,
                          leading: Icon(
                            d['met'] ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: d['met'] ? Colors.green : Colors.grey,
                          ),
                          title: Text(d['label']),
                          trailing: Text("${d['count']}"),
                        )),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
