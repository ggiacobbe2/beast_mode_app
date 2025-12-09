import 'package:flutter/material.dart';
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

    final List<Map<String, dynamic>> tempEntries = [
    {
      "title": "First Day Back",
      "caption": "Excited to kick off the New Year right! My goal for the new year is to focus on strength and consistency. Let's do this!",
      "image":
          "assets/images/gym_weights.jpeg",
      "date": DateTime(2025, 1, 1),
    },
    {
      "title": "Leg Day",
      "caption": "Today, I started with some dynamic stretches to warm up, followed by squats, lunges, and deadlifts. Finished with some calf raises and a good stretch. Feeling strong!",
      "image":
          "assets/images/leg_press.jpeg",
      "date": DateTime(2025, 1, 3),
    },
    {
      "title": "New Bench PR",
      "caption": "Hit a new personal record on my bench press today! Pushed through some tough sets and finally nailed 150 for 5 reps. It's nice to celebrate the small wins!",
      "image":
          "assets/images/bench_press.jpeg",
      "date": DateTime(2025, 1, 4),
    },
  ];

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
    final sortedPosts = List<Map<String, dynamic>>.from(tempEntries)
      ..sort((a, b) => b['date'].compareTo(a['date']));

    return Scaffold(
      appBar: AppBar(title: const Text("Photo Journal")),

      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: sortedPosts.length,
        itemBuilder: (context, index) {
          final post = sortedPosts[index];
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
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child: Image.asset(
                    post["image"],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author
                      Text(
                        post["title"],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),

                      const SizedBox(height: 6),

                      // Caption
                      Text(post["caption"]),

                      const SizedBox(height: 8),

                      // Date
                      Text(
                        "${post["date"].month}/${post["date"].day}/${post["date"].year}",
                        style:
                            TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
}