import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'home_feed_screen.dart';
import 'challenges_screen.dart';
import 'workout_log_screen.dart';
import 'profile_screen.dart';
import 'new_photo_entry.dart';

class PhotoJournalScreen extends StatefulWidget {
  const PhotoJournalScreen({super.key});

  @override
  State<PhotoJournalScreen> createState() => _PhotoJournalScreenState();
}

class _PhotoJournalScreenState extends State<PhotoJournalScreen> {
  int _currentIndex = 3;
  final PhotoJournalService _journalService = PhotoJournalService();
  bool _working = false;

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    switch (index) {
      case 0: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeFeedScreen())); break;
      case 1: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChallengesScreen())); break;
      case 2: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkoutLogScreen())); break;
      case 3: break;
      case 4: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen())); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Photo Journal")),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _journalService.streamEntries(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Failed to load journal: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("No photo entries yet. Add your first progress shot!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final post = doc.data();
              final imageUrl = post["imageUrl"] as String?;
              final ts = post['createdAt'] as Timestamp?;
              final date = ts?.toDate();
              final dateLabel = date != null
                  ? "${date.month}/${date.day}/${date.year}"
                  : 'Just now';
              final phase = post['phase'] as String?;
              final workoutTitle = post['workoutTitle'] as String?;

              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                        ),
                        child: Image.network(
                          imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post["title"] as String? ?? 'Untitled',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),

                          const SizedBox(height: 6),

                          Text(post["caption"] as String? ?? ''),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              if (phase != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: phase == 'pre' ? Colors.blue.shade50 : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    phase == 'pre' ? 'Pre-workout' : 'Post-workout',
                                    style: TextStyle(
                                      color: phase == 'pre' ? Colors.blue : Colors.green,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              if (workoutTitle != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  workoutTitle,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),

                          Text(
                            dateLabel,
                            style:
                                TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: _working ? null : () => _editEntry(doc.id, post),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: _working ? null : () => _confirmDelete(doc.id),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => NewPhotoEntry()));
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
        title: const Text('Delete entry?'),
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
      await _journalService.deleteEntry(id);
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

  void _editEntry(String id, Map<String, dynamic> data) {
    final titleCtrl = TextEditingController(text: data['title'] as String? ?? '');
    final captionCtrl = TextEditingController(text: data['caption'] as String? ?? '');
    bool blur = (data['blur'] as bool?) ?? false;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit entry'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: captionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Caption'),
              ),
              SwitchListTile(
                title: const Text('Blur by default'),
                value: blur,
                onChanged: (v) {
                  setState(() {});
                  blur = v;
                },
                contentPadding: EdgeInsets.zero,
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
                      await _journalService.updateEntry(id, {
                        'title': titleCtrl.text.trim(),
                        'caption': captionCtrl.text.trim(),
                        'blur': blur,
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
