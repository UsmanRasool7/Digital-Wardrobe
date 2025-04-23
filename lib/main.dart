import 'package:flutter/material.dart';
import 'screens/edit_profile_page.dart';
import 'screens/wardrobe_insights_page.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Profile Edit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WardrobeInsightsScreen(), // Set the EditProfilePage as the home screen
      debugShowCheckedModeBanner: false,
    );
  }
}
