import 'dart:io';
import '/models/user_model.dart';
import '/services/auth_service.dart';
import '/services/firestore_service.dart';
import '/services/local_storage_service.dart'; // Changed from StorageService
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final AuthService _auth;
  final FirestoreService _fs;
  final LocalStorageService _localStorage;

  UserRepository(this._auth, this._fs, this._localStorage);

  String get uid => _auth.currentUser!.uid;

  Future<UserModel?> fetchUser() async {
    final user = await _fs.fetchUser(uid);
    if (user != null) {
      // Get locally stored image path
      final localImagePath = await _localStorage.getProfileImagePath(uid);
      return user.copyWith(profileImageUrl: localImagePath);
    }
    return null;
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser!;

    // Reauthenticate user
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> updateProfile({
    required String username,
    String? email,
    String? bio,
    File? avatarFile,
  }) async {
    final user = _auth.currentUser!;
    String? imagePath;

    // 1) Save image locally if provided
    if (avatarFile != null) {
      imagePath = await _localStorage.saveProfileImage(avatarFile, uid);
    }

    // 2) Update email if changed
    if (email != null && email != user.email) {
      await user.updateEmail(email);
    }

    // 3) Update Firestore with local image path
    final updatedUser = UserModel(
      uid: uid,
      username: username,
      email: user.email ?? '',
      profileImageUrl: imagePath, // Now stores local file path
      bio: bio,
    );

    await _fs.updateUser(updatedUser);
  }
}

