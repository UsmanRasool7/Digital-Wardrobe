import 'package:flutter/material.dart';

class PlannerPage extends StatelessWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planner'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          'Welcome to the Planner Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
