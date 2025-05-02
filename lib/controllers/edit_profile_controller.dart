
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/user_repository.dart';

class EditProfileController extends ChangeNotifier {
  final UserRepository _repo;

  final displayNameCtrl = TextEditingController();
  final usernameCtrl    = TextEditingController();
  final emailCtrl       = TextEditingController();
  final bioCtrl         = TextEditingController();

  File?  pickedImage;
  bool  isLoading = false;

  EditProfileController(this._repo);

  Future<void> init() async {
    final user = await _repo.fetchUser();
    if (user != null) {
      usernameCtrl.text    = user.username  ?? '';
      emailCtrl.text       = user.email     ?? '';
      bioCtrl.text         = user.bio       ?? '';
      pickedImage = null;
      notifyListeners();
    }
  }

  Future<void> pickImage() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x != null) {
      pickedImage = File(x.path);
      notifyListeners();
    }
  }

  Future<void> save() async {
    isLoading = true;
    notifyListeners();

    await _repo.updateProfile(
      //displayName: displayNameCtrl.text.trim(),
      username:    usernameCtrl.text.trim(),
      email:       emailCtrl.text.trim(),
      bio:         bioCtrl.text.trim(),
      avatarFile:  pickedImage,
    );

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    //displayNameCtrl.dispose();
    usernameCtrl.dispose();
    emailCtrl.dispose();
    bioCtrl.dispose();
    super.dispose();
  }
}
