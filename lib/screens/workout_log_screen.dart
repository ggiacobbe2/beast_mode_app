import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'home_feed_screen.dart';
import 'challenges_screen.dart';
import 'photo_journal_screen.dart';
import 'profile_screen.dart';
import 'new_workout.dart';
import 'progress_dashboard_screen.dart';

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  int _currentIndex = 2;
  final WorkoutService _workoutService = WorkoutService();
  bool _working = false;

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    switch (index) {
      case 0: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeFeedScreen())); break;
      case 1: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ChallengesScreen())); break;
      case 2: break;
      case 3: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PhotoJournalScreen())); break;
      case 4: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen())); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Sign in to view your workouts.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Workout Log")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProgressDashboardScreen(),
                    ),
                  );
                },
                child: const Text(
                  "View Progress Dashboard",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _workoutService.streamUserWorkouts(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load workouts: ${snapshot.error}'),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text("No workouts yet. Log your first session!"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final ts = data['createdAt'] as Timestamp?;
                    final date = ts?.toDate();
                    final dateLabel = date != null
                        ? "${date.month}/${date.day}/${date.year}"
                        : 'Just now';
                    final duration = data['durationMinutes'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(data['title'] as String? ?? 'Workout'),
                        subtitle: Text([
                          if (duration != null) "$duration min",
                          dateLabel
                        ].join(" • ")),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: _working
                                  ? null
                                  : () => _editWorkout(doc.id, data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed:
                                  _working ? null : () => _confirmDelete(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NewWorkout()));
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: "Challenges"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Workout"),
          BottomNavigationBarItem(icon: Icon(Icons.photo), label: "Journal"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  void _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete workout?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _working = true);
    try {
      await _workoutService.deleteWorkout(id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _editWorkout(String id, Map<String, dynamic> data) {
    final titleCtrl = TextEditingController(text: data['title'] as String? ?? '');
    final durationCtrl = TextEditingController(
        text: data['durationMinutes'] != null ? '${data['durationMinutes']}' : '');
    final notesCtrl = TextEditingController(text: data['notes'] as String? ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit workout'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: durationCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
              ),
              TextField(
                controller: notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: _working
                ? null
                : () async {
                    setState(() => _working = true);
                    try {
                      await _workoutService.updateWorkout(id, {
                        'title': titleCtrl.text.trim(),
                        'durationMinutes': int.tryParse(durationCtrl.text.trim()),
                        'notes': notesCtrl.text.trim(),
                      });
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Update failed: $e')),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _working = false);
                    }
                  },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
