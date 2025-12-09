import 'package:flutter/material.dart';

class NewPhotoEntry extends StatelessWidget {
  const NewPhotoEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Photo Entry")),
      body: const Center(child: Text("Add a new photo entry here")),
    );
  }
}