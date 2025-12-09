import 'package:flutter/material.dart';
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

  // temp data to be replaced later
  String name = "User Example";
  String email = "user@example.com";
  String dob = "Not set";
  String gender = "Not set";


  final List<Map<String, dynamic>> userPosts = [
    {
      "caption": "Loving my workouts!",
      "image": "assets/images/gym_woman_crunch.jpeg",
      "date": DateTime(2025, 1, 10),
    },
  ];

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

    void _editProfile() async {
    TextEditingController nameCtrl = TextEditingController(text: name);
    TextEditingController dobCtrl = TextEditingController(text: dob);
    TextEditingController genderCtrl = TextEditingController(text: gender);

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
              setState(() {
                name = nameCtrl.text;
                dob = dobCtrl.text;
                gender = genderCtrl.text;
              });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
          )
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey,
                // backgroundImage: add pfp here,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
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

          for (var post in userPosts) _postCard(post),
        ],
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