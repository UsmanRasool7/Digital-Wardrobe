import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test_app/screens/login_page.dart';
import 'package:test_app/screens/signin.dart';
import 'package:test_app/screens/signup.dart';
import 'screens/edit_profile_page.dart';
import 'screens/wardrobe_insights_page.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child:  MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Profile Edit',
      routes: {
        //'/': (context) => App(), // root widget
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => EditProfilePage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SignInPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
