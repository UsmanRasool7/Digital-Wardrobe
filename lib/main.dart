import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test_app/screens/login_page.dart';
import 'package:test_app/screens/signin.dart';
import 'package:test_app/screens/signup.dart';
import 'screens/edit_profile_page.dart';
import 'screens/wardrobe_insights_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Profile Edit',
      routes: {
        //'/': (context) => App(), // Your root widget
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => EditProfilePage(), // Add this line
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SignUpPage(), // Set the EditProfilePage as the home screen
      debugShowCheckedModeBanner: false,
    );
  }
}
