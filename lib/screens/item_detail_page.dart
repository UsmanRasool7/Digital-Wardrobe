import 'dart:io';
import 'package:flutter/material.dart';

class ItemDetailPage extends StatelessWidget {
  final File imageFile;

  const ItemDetailPage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Detail')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('This is a dummy Item Detail Page.'),
            const SizedBox(height: 20),
            Image.file(imageFile), // Display the image from a File
          ],
        ),
      ),
    );
  }
}
