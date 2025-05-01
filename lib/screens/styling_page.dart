import 'package:flutter/material.dart';

class StylingPage extends StatelessWidget {
  const StylingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Styling'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          'Styling Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
