import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'screens/login_page.dart';
import 'screens/edit_profile_page.dart';
import 'providers/auth_provider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          return user == null ? LoginPage() : EditProfilePage();
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}