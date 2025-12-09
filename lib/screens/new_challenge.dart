import 'package:flutter/material.dart';

class NewChallenge extends StatelessWidget {
  const NewChallenge({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Challenge")),
      body: const Center(child: Text("Create a new challenge here")),
    );
  }
}