import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:test_app/widgets/profile_avatar.dart';
import '../repositories/user_repository.dart';
import 'package:test_app/services/auth_service.dart';
import 'package:test_app/services/firestore_service.dart';
import 'package:test_app/services/local_storage_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String profileImage = 'assets/default_avatar.png';
  File? avatarFile;
  final ImagePicker _picker = ImagePicker();
  late UserRepository userRepository;

  @override
  void initState() {
    super.initState();
    userRepository = UserRepository(AuthService(), FirestoreService(), LocalStorageService());
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    final userModel = await userRepository.fetchUser();
    if (userModel != null) {
      setState(() {
        usernameController.text = userModel.username;
        emailController.text = userModel.email;
        bioController.text = userModel.bio ?? '';
        profileImage = userModel.profileImageUrl ?? 'assets/default_avatar.png';
      });
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    bioController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      throw Exception('New passwords do not match');
    }

    await userRepository.updatePassword(
      currentPasswordController.text.trim(),
      newPasswordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ProfileAvatar(
              imagePath: profileImage,
              onEditTap: () async {
                final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  final extension = pickedFile.path.split('.').last.toLowerCase();
                  if (['jpg', 'jpeg', 'png'].contains(extension)) {
                    setState(()
                    {
                      avatarFile = File(pickedFile.path);
                      profileImage = pickedFile.path;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Only JPG, JPEG and PNG formats are allowed.')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 30),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline)),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.password)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.verified_user)),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    // Update profile
                    await userRepository.updateProfile(
                      username: usernameController.text.trim(),
                      bio: bioController.text.trim(),
                      avatarFile: avatarFile,
                    );

                    // Update password if fields are filled
                    if (newPasswordController.text.isNotEmpty ||
                        confirmPasswordController.text.isNotEmpty ||
                        currentPasswordController.text.isNotEmpty) {
                      await _updatePassword();
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated successfully!')),
                    );
                    Navigator.pushNamed(context, '/home');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}