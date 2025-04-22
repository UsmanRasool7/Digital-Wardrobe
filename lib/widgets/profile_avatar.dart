import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String imagePath;
  final VoidCallback onEditTap;

  ProfileAvatar({required this.imagePath, required this.onEditTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: AssetImage(imagePath), // Replace with NetworkImage for dynamic loading
        ),
        CircleAvatar(
          backgroundColor: Colors.blueAccent,
          radius: 18,
          child: IconButton(
            icon: Icon(Icons.edit, color: Colors.white, size: 18),
            onPressed: onEditTap, // Call onEditTap when the icon is tapped
          ),
        ),
      ],
    );
  }
}
