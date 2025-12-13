import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:async/async.dart';

class ProgressDashboardScreen extends StatelessWidget {
  const ProgressDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in")),
      );
    }

    final uid = user.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Progress Dashboard")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _challengeProgress(uid),
            const SizedBox(height: 24),
            _workoutCount(uid),
            const SizedBox(height: 24),
            _weightProgress(uid),
          ],
        ),
      ),
    );
  }

  Widget _challengeProgress(String uid) {
    final challengesRef = FirebaseFirestore.instance.collection('challenges');

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: challengesRef.snapshots(),
      builder: (context, challengesSnapshot) {
        if (!challengesSnapshot.hasData) return const CircularProgressIndicator();

        final challengeDocs = challengesSnapshot.data!.docs;

        if (challengeDocs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text("No challenges available."),
            ),
          );
        }

        final progressStreams = challengeDocs.map((doc) {
          return doc.reference.collection('progress').doc(uid).snapshots();
        }).toList();

        return StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
          stream: StreamZip(progressStreams),
          builder: (context, progressSnapshots) {
            if (!progressSnapshots.hasData) return const CircularProgressIndicator();

            final completedDifficulties = <String>[];

            for (int i = 0; i < challengeDocs.length; i++) {
              final progress = progressSnapshots.data![i].data() ?? {};

              final allDaysCompleted = List.generate(
                      7, (day) => progress['day${day + 1}'] == true)
                  .every((v) => v);

              if (allDaysCompleted || progress['completed'] == true) {
                final difficulty = challengeDocs[i].data()['difficulty'] as String?;
                if (difficulty != null) completedDifficulties.add(difficulty);
              }
            }

            final easy = completedDifficulties.where((d) => d == 'easy').length;
            final medium = completedDifficulties.where((d) => d == 'medium').length;
            final hard = completedDifficulties.where((d) => d == 'hard').length;
            final total = easy + medium + hard;

            if (total == 0) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("No challenges completed yet."),
                ),
              );
            }

            final dataMap = {
              "Easy": easy.toDouble(),
              "Medium": medium.toDouble(),
              "Hard": hard.toDouble(),
            };

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "Challenges Completed: $total",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    PieChart(
                      dataMap: dataMap,
                      chartType: ChartType.ring,
                      chartRadius: 120,
                      chartValuesOptions: const ChartValuesOptions(
                        showChartValuesInPercentage: true,
                      ),
                      legendOptions: const LegendOptions(
                        legendPosition: LegendPosition.bottom,
                      ),
                      colorList: const [Colors.green, Colors.orange, Colors.red],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _workoutCount(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('workouts')
          .where('ownerId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final count = snapshot.data!.docs.length;

        return Card(
          child: ListTile(
            leading: const Icon(Icons.fitness_center, size: 36),
            title: const Text(
              "Workouts Completed",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              count.toString(),
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _weightProgress(String uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

        final startWeight = double.tryParse(data['starting weight']?.toString() ?? '');
        final goalWeight = double.tryParse(data['goal weight']?.toString() ?? '');
        double currentWeight = double.tryParse(data['current weight']?.toString() ?? '') ?? startWeight ?? 0;

        if (startWeight == null || goalWeight == null) {
          return const Text("Set your starting and goal weight to track progress.");
        }

        return StatefulBuilder(
          builder: (context, setStateSlider) {
            final minWeight = startWeight < goalWeight ? startWeight : goalWeight;
            final maxWeight = startWeight > goalWeight ? startWeight : goalWeight;
            final divisions = ((maxWeight - minWeight) >= 1 ? (maxWeight - minWeight).toInt() : null);

            final displayValue = startWeight > goalWeight ? maxWeight - (currentWeight - minWeight) : currentWeight;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Weight Progress",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${startWeight.toStringAsFixed(1)} lbs"),
                        Text("${goalWeight.toStringAsFixed(1)} lbs"),
                      ],
                    ),
                    Slider(
                      value: displayValue,
                      min: minWeight,
                      max: maxWeight,
                      divisions: divisions,
                      label: currentWeight.toStringAsFixed(1),
                      onChanged: (val) {
                        final newWeight = startWeight > goalWeight ? maxWeight - (val - minWeight) : val;
                        setStateSlider(() => currentWeight = newWeight);
                      },
                      onChangeEnd: (val) async {
                        final newWeight = startWeight > goalWeight ? maxWeight - (val - minWeight) : val;
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .update({'current weight': newWeight});
                      },
                    ),
                    Text(
                      "${currentWeight.toStringAsFixed(1)} lbs → Goal: ${goalWeight.toStringAsFixed(1)} lbs",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}