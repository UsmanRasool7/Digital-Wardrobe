// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth      _auth      = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign up with email/password and displayName,
  /// then write a corresponding Firestore document.
  Future<User?> signUp(
      String email,
      String password,
      String displayName,      // ← new parameter
      ) async {
    try {
      // 1. create the auth user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = result.user!;

      // 2. update their FirebaseAuth profile
      await user.updateDisplayName(displayName);

      // 3. build your UserModel (photoUrl stays null)
      final newUser = UserModel(
        uid: user.uid,
        displayName: displayName,
        email: user.email!,
        photoUrl: null,
      );

      // 4. write to Firestore at `users/{uid}`
      await _firestore
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toMap(), SetOptions(merge: true));

      return user;
    } catch (e) {
      print("Signup Error: $e");
      return null;
    }
  }

  /// Login with email/password
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  /// Password reset
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
