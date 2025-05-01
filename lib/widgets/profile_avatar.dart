import 'package:flutter/material.dart';
import 'dart:io';

class ProfileAvatar extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onEditTap;
  final double radius;

  const ProfileAvatar({
    super.key,
    this.imagePath,
    required this.onEditTap,
    this.radius = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: _getImageProvider(),
          child: _buildFallbackChild(),
        ),
        _buildEditButton(context),
      ],
    );
  }

  ImageProvider? _getImageProvider() {
    if (imagePath == null) return null;

    if (imagePath!.startsWith('http')) {
      return NetworkImage(imagePath!);
    } else if (imagePath!.startsWith('/')) {
      return FileImage(File(imagePath!));
    }
    return AssetImage(imagePath!);
  }

  Widget _buildFallbackChild() {
    if (imagePath == null) {
      return Icon(
        Icons.person,
        size: radius,
        color: Colors.grey.shade400,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildEditButton(BuildContext context) {
    return GestureDetector(
      onTap: onEditTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).scaffoldBackgroundColor,
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.edit,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}