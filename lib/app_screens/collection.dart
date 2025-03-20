import 'package:flutter/material.dart';

class Collection extends StatelessWidget {
  const Collection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Collection"),
      ),
      body: const Center(
        child: Text(
          "Collection...",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}