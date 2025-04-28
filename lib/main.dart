import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test_app/screens/login_page.dart';
import 'package:test_app/screens/signin.dart';
import 'package:test_app/screens/signup.dart';
import 'screens/edit_profile_page.dart';
import 'screens/wardrobe_insights_page.dart';
<<<<<<< Updated upstream
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
=======
import 'screens/planner_page.dart';
import 'screens/styling_page.dart';
import 'screens/wardrobe_page.dart';

>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
        //'/': (context) => App(), // root widget
=======
>>>>>>> Stashed changes
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => EditProfilePage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
<<<<<<< Updated upstream
      home: SignInPage(),
=======
      home: HomePage(),
>>>>>>> Stashed changes
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    PlannerPage(),
    StylingPage(),
    WardrobePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.style),
            label: 'Styling',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            label: 'Wardrobe',
          ),
        ],
      ),
    );
  }
}
