import 'package:flutter/material.dart';
import 'challenges_screen.dart';
import 'workout_log_screen.dart';
import 'photo_journal_screen.dart';
import 'profile_screen.dart';
import 'new_post.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  int _currentIndex = 0;

  final Set<int> likedPosts = {};

  final List<Map<String, dynamic>> tempPosts = [
    {
      "author": "Erin",
      "caption": "First workout of the day!",
      "image":
          "assets/images/gym_woman_crunch.jpeg",
      "date": DateTime(2025, 1, 10),
    },
    {
      "author": "Alex",
      "caption": "My favorite zumba class.",
      "image":
          "assets/images/zumba_class.jpeg",
      "date": DateTime(2025, 1, 8),
    },
    {
      "author": "Sam",
      "caption": "5k run done!",
      "image":
          "assets/images/5k_run_medal.jpeg",
      "date": DateTime(2025, 1, 5),
    },
  ];

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    switch (index) {
      case 0: break;
      case 1: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChallengesScreen())); break;
      case 2: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkoutLogScreen())); break;
      case 3: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PhotoJournalScreen())); break;
      case 4: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen())); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedPosts = List<Map<String, dynamic>>.from(tempPosts)
      ..sort((a, b) => b['date'].compareTo(a['date']));

    return Scaffold(
      appBar: AppBar(title: const Text("Home Feed")),

      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: sortedPosts.length,
        itemBuilder: (context, index) {
          final post = sortedPosts[index];
          final isLiked = likedPosts.contains(index);

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
            child: Stack(
              children: [
                // Main content
                Column(
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
                          Text(
                            post["author"],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(post["caption"]),
                          const SizedBox(height: 8),
                          Text(
                            "${post["date"].month}/${post["date"].day}/${post["date"].year}",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Like button overlayed in lower-right corner
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      likedPosts.contains(index) ? Icons.favorite : Icons.favorite_border,
                      color: likedPosts.contains(index) ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        if (likedPosts.contains(index)) {
                          likedPosts.remove(index);
                        } else {
                          likedPosts.add(index);
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => NewPost()));
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