import 'package:flutter/material.dart';
import 'home_feed_screen.dart';
import 'workout_log_screen.dart';
import 'photo_journal_screen.dart';
import 'profile_screen.dart';
import 'new_challenge.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final String author;
  final DateTime startDate;
  final DateTime endDate;
  final String difficulty;

  bool isJoined;
  bool isCompleted;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.startDate,
    required this.endDate,
    required this.difficulty,
    this.isJoined = false,
    this.isCompleted = false,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }
}

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  int _currentIndex = 1;

  List<Challenge> challenges = [
    Challenge(
      id: "1",
      title: "10K Steps Daily",
      description: "Walk 10,000 steps every day this week.",
      author: "Penny",
      startDate: DateTime(2025, 12, 1),
      endDate: DateTime(2025, 12, 8),
      difficulty: "Easy",
    ),
    Challenge(
      id: "2",
      title: "50 Pushups a Day",
      description: "Complete 50 pushups every day for 14 days.",
      author: "Ryan",
      startDate: DateTime(2025, 12, 1),
      endDate: DateTime(2025, 12, 15),
      difficulty: "Medium",
    ),
    Challenge(
      id: "3",
      title: "Earn a New PR",
      description: "Set a new personal record in any lift by the end of the month.",
      author: "Nick",
      startDate: DateTime(2025, 12, 1),
      endDate: DateTime(2026, 1, 1),
      difficulty: "Hard",
    ),
  ];

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeFeedScreen()));
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => WorkoutLogScreen()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => PhotoJournalScreen()));
        break;
      case 4:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeChallenges = challenges.where((c) => c.isActive).toList();
    final yourChallenges =
        challenges.where((c) => c.isJoined || c.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Challenges"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Active Challenges",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (activeChallenges.isEmpty)
                const Text("No active challenges right now."),
              
              if (activeChallenges.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeChallenges.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildChallengeCard(activeChallenges[index]),
                    );
                  },
                ),

              const SizedBox(height: 30),

              const Text(
                "Your Challenges",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (yourChallenges.isEmpty)
                const Text("You haven’t joined any challenges yet."),
              for (var challenge in yourChallenges)
                _buildYourChallengeCard(challenge),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const NewChallenge()));
        },
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events), label: "Challenges"),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: "Workout"),
          BottomNavigationBarItem(icon: Icon(Icons.photo), label: "Journal"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(challenge.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              challenge.description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text("Author: ${challenge.author}"),
            Text("Difficulty: ${challenge.difficulty}"),
            const SizedBox(height: 10),

            if (!challenge.isJoined)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    challenge.isJoined = true;
                  });
                },
                child: const Text("Join Challenge"),
              ),

            if (challenge.isJoined && !challenge.isCompleted)
              const Text(
                "In Progress",
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),

            if (challenge.isCompleted)
              const Text(
                "Completed",
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildYourChallengeCard(Challenge challenge) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      color: challenge.isCompleted ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(challenge.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      challenge.isJoined = false;
                      challenge.isCompleted = false;
                    });
                  },
                ),
              ],
            ),
            Text(challenge.description),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  challenge.isCompleted ? "Completed" : "In Progress",
                  style: TextStyle(
                    color: challenge.isCompleted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (!challenge.isCompleted)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        challenge.isCompleted = true;
                      });
                    },
                    child: const Text("Mark as Completed"),
                  ),
                  
                if (challenge.isCompleted)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        challenge.isCompleted = false;
                      });
                    },
                    child: const Text("Undo"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}