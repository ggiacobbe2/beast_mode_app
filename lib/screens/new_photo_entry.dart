import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/storage_service.dart';
import '../services/firestore_service.dart';
import '../services/firestore_service.dart' as services;

class NewPhotoEntry extends StatefulWidget {
  const NewPhotoEntry({super.key});

  @override
  State<NewPhotoEntry> createState() => _NewPhotoEntryState();
}

class _NewPhotoEntryState extends State<NewPhotoEntry> {
  final _titleCtrl = TextEditingController();
  final _captionCtrl = TextEditingController();
  final _picker = ImagePicker();
  XFile? _picked;
  bool _isSubmitting = false;
  bool _blurByDefault = true;
  String _phase = 'pre'; // pre or post
  String? _selectedWorkoutId;
  String? _selectedWorkoutTitle;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (result != null) {
      setState(() {
        _picked = result;
      });
    }
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be signed in.')),
      );
      return;
    }

    if (_picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a photo.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final file = File(_picked!.path);
      final imageUrl = await StorageService().uploadJournalImage(uid: user.uid, file: file);
      await PhotoJournalService().addEntry({
        'title': _titleCtrl.text.trim(),
        'caption': _captionCtrl.text.trim(),
        'imageUrl': imageUrl,
        'blur': _blurByDefault,
        'phase': _phase,
        'workoutId': _selectedWorkoutId,
        'workoutTitle': _selectedWorkoutTitle,
      });
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text("New Photo Entry")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _isSubmitting ? null : _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                  image: _picked != null
                      ? DecorationImage(
                          image: FileImage(File(_picked!.path)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: _picked == null
                    ? const Text("Tap to select a photo")
                    : const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _captionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Caption"),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("Blur by default"),
                Switch(
                  value: _blurByDefault,
                  onChanged: _isSubmitting ? null : (v) => setState(() => _blurByDefault = v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ChoiceChip(
                  label: const Text("Pre-workout"),
                  selected: _phase == 'pre',
                  onSelected: _isSubmitting ? null : (_) => setState(() => _phase = 'pre'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text("Post-workout"),
                  selected: _phase == 'post',
                  onSelected: _isSubmitting ? null : (_) => setState(() => _phase = 'post'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (uid != null)
              StreamBuilder(
                stream: services.WorkoutService().streamUserWorkouts(uid),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  return DropdownButtonFormField<String>(
                    value: _selectedWorkoutId,
                    items: [
                      const DropdownMenuItem(value: null, child: Text("No linked workout")),
                      ...docs.map((d) {
                        final title = d.data()['title'] as String? ?? 'Workout';
                        return DropdownMenuItem(
                          value: d.id,
                          child: Text(title),
                          onTap: () => _selectedWorkoutTitle = title,
                        );
                      }),
                    ],
                    onChanged: _isSubmitting
                        ? null
                        : (val) {
                            setState(() {
                              _selectedWorkoutId = val;
                              if (val == null) _selectedWorkoutTitle = null;
                            });
                          },
                    decoration: const InputDecoration(
                      labelText: "Link to a workout (optional)",
                    ),
                  );
                },
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
                    : const Text("Post Entry"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
