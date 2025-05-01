import 'package:flutter/material.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wardrobe'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          'Wardrobe Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
