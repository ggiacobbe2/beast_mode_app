import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/storage_service.dart';
import '../services/firestore_service.dart';

class NewPost extends StatefulWidget {
  const NewPost({super.key});

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  final _captionCtrl = TextEditingController();
  final _picker = ImagePicker();
  XFile? _picked;
  bool _isSubmitting = false;

  @override
  void dispose() {
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

    if ((_captionCtrl.text.trim().isEmpty) && _picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a caption or select an image.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      String? imageUrl;
      if (_picked != null) {
        imageUrl = await StorageService()
            .uploadFeedImage(uid: user.uid, file: File(_picked!.path));
      }

      await FeedService().addFeedEntry({
        'authorName': user.displayName ?? user.email ?? 'Athlete',
        'caption': _captionCtrl.text.trim(),
        'imageUrl': imageUrl,
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Post")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                    ? const Text("Tap to select a photo (optional)")
                    : const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _captionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Caption",
                hintText: "Share a workout highlight or update",
              ),
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
                    : const Text("Post"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
