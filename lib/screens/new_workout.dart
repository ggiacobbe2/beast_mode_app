import 'package:flutter/material.dart';

class NewWorkout extends StatelessWidget {
  const NewWorkout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Workout")),
      body: const Center(child: Text("Create a new workout here")),
    );
  }
}