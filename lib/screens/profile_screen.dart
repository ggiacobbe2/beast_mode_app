import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import 'home_feed_screen.dart';
import 'challenges_screen.dart';
import 'workout_log_screen.dart';
import 'photo_journal_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 4;

  final UserProfileService _profileService = UserProfileService();
  final WorkoutService _workoutService = WorkoutService();
  final PhotoJournalService _journalService = PhotoJournalService();
  final auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  bool _uploadingPhoto = false;

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    switch (index) {
      case 0: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeFeedScreen())); break;
      case 1: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChallengesScreen())); break;
      case 2: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkoutLogScreen())); break;
      case 3: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PhotoJournalScreen())); break;
      case 4: break;
    }
  }

    void _editProfile(Map<String, dynamic> data) async {
    TextEditingController nameCtrl = TextEditingController(text: data['name'] as String? ?? '');
    TextEditingController dobCtrl = TextEditingController(text: data['dob'] as String? ?? '');
    TextEditingController genderCtrl = TextEditingController(text: data['gender'] as String? ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: dobCtrl, decoration: const InputDecoration(labelText: "Date of Birth")),
            TextField(controller: genderCtrl, decoration: const InputDecoration(labelText: "Gender")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _profileService.upsertProfile(
                uid: auth.currentUser!.uid,
                data: {
                  'name': nameCtrl.text,
                  'dob': dobCtrl.text,
                  'gender': genderCtrl.text,
                },
              );
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _profileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text("$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

Widget _postCard(Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(post["image"], height: 200, width: double.infinity, fit: BoxFit.cover),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post["caption"],
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  "${post["date"].month}/${post["date"].day}/${post["date"].year}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _workoutItem(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'] as Timestamp?;
    final date = ts?.toDate();
    final duration = data['durationMinutes'];
    final notes = data['notes'] as String?;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(data['title'] as String? ?? 'Workout'),
        subtitle: Text([
          if (duration != null) "$duration min",
          if (date != null) "${date.month}/${date.day}/${date.year}",
        ].join(" • ")),
        trailing: const Icon(Icons.fitness_center),
        onTap: notes != null && notes.isNotEmpty
            ? () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(data['title'] as String? ?? 'Workout'),
                    content: Text(notes),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              }
            : null,
      ),
    );
  }

  Widget _journalItem(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'] as Timestamp?;
    final date = ts?.toDate();
    final imageUrl = data['imageUrl'] as String?;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] as String? ?? 'Entry',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  data['caption'] as String? ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  date != null ? "${date.month}/${date.day}/${date.year}" : '',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
            },
          )
        ],
      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _profileService.streamProfile(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Failed to load profile: ${snapshot.error}'));
          }

          final data = snapshot.data?.data() ?? {};
          final name = data['name'] as String? ?? 'Athlete';
          final email = data['email'] as String? ?? auth.currentUser?.email ?? '';
          final dob = data['dob'] as String? ?? 'Not set';
          final gender = data['gender'] as String? ?? 'Not set';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: (data['photoUrl'] as String?) != null
                            ? NetworkImage(data['photoUrl'] as String)
                            : null,
                        child: (data['photoUrl'] as String?) == null
                            ? const Icon(Icons.person, size: 32, color: Colors.white70)
                            : null,
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: IconButton(
                          icon: _uploadingPhoto
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.camera_alt, size: 20),
                          onPressed: _uploadingPhoto ? null : () => _changePhoto(uid),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editProfile(data),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _profileDetail("Email", email),
              _profileDetail("Date of Birth", dob),
              _profileDetail("Gender", gender),

              const SizedBox(height: 24),
              const Text(
                "Your Posts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              const Text(
                "Workouts",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _workoutService.streamUserWorkouts(uid),
                builder: (context, workoutSnap) {
                  if (workoutSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (workoutSnap.hasError) {
                    return Text('Failed to load workouts: ${workoutSnap.error}');
                  }
                  final docs = workoutSnap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Text("No workouts yet.");
                  }
                  return Column(
                    children: docs.map(_workoutItem).toList(),
                  );
                },
              ),

              const SizedBox(height: 16),
              const Text(
                "Journal",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _journalService.streamEntries(uid),
                builder: (context, journalSnap) {
                  if (journalSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (journalSnap.hasError) {
                    return Text('Failed to load journal: ${journalSnap.error}');
                  }
                  final docs = journalSnap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Text("No journal entries yet.");
                  }
                  return Column(
                    children: docs.map(_journalItem).toList(),
                  );
                },
              ),
            ],
          );
        },
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

  Future<void> _changePhoto(String uid) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() => _uploadingPhoto = true);
    try {
      final url = await StorageService()
          .uploadProfileImage(uid: uid, file: File(picked.path));
      await _profileService.upsertProfile(uid: uid, data: {'photoUrl': url});
      await auth.currentUser?.updatePhotoURL(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }
}
