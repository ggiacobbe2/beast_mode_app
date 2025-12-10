import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class NewWorkout extends StatefulWidget {
  const NewWorkout({super.key});

  @override
  State<NewWorkout> createState() => _NewWorkoutState();
}

class _NewWorkoutState extends State<NewWorkout> {
  final _titleCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _shareToFeed = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _durationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be signed in.')),
      );
      return;
    }

    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a workout title.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final workoutRef = await WorkoutService().createWorkout({
        'title': _titleCtrl.text.trim(),
        'durationMinutes': int.tryParse(_durationCtrl.text.trim()),
        'notes': _notesCtrl.text.trim(),
      });

      if (_shareToFeed) {
        await FeedService().addFeedEntry({
          'authorName': user.displayName ?? user.email ?? 'Athlete',
          'caption': 'Finished: ${_titleCtrl.text.trim()}',
          'workoutId': workoutRef.id,
        });
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save workout: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Workout")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: "Workout title",
                hintText: "e.g., Push day, 5K run",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Duration (minutes)",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Notes",
                hintText: "Key lifts, intervals, RPE, etc.",
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text("Share to feed"),
              value: _shareToFeed,
              onChanged: _isSubmitting ? null : (v) => setState(() => _shareToFeed = v),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Save Workout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
