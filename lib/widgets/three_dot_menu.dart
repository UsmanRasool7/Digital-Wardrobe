import 'package:flutter/material.dart';
import 'package:test_app/screens/edit_profile_page.dart';
import 'package:test_app/screens/settings_page.dart';

class ThreeDotMenu extends StatelessWidget {
  const ThreeDotMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        if (value == 'settings') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          );
        } else if (value == 'edit_profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfilePage()),
          );
        }
      },
      itemBuilder:
          (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'settings',
              child: Text('Settings'),
            ),
            const PopupMenuItem<String>(
              value: 'edit_profile',
              child: Text('Edit Profile'),
            ),
          ],
      icon: const Icon(Icons.more_vert),
    );
  }
}
