import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/widgets/custom_bottom_nav.dart';
import 'package:test_app/widgets/three_dot_menu.dart';
import 'package:test_app/repositories/user_repository.dart';
import 'package:test_app/services/auth_service.dart';
import 'package:test_app/services/firestore_service.dart';
import 'package:test_app/services/local_storage_service.dart';
import 'wardrobe_insights_page.dart'; // Import the WardrobeInsightsScreen here
import 'package:test_app/screens/add_item_page.dart'; // Add this import
import 'dart:io'; // Import dart:io for File
import 'package:test_app/screens/item_detail_page.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class WardrobeHomePage extends StatefulWidget {
  const WardrobeHomePage({super.key});

  @override
  State<WardrobeHomePage> createState() => _WardrobeHomePageState();
}

class _WardrobeHomePageState extends State<WardrobeHomePage> {
  int selectedIndex = 2;
  int selectedToggle = 0;
  String displayName = ''; // We will use this to display the username
  List<File> wardrobeItems = []; // List to store wardrobe items

  late UserRepository userRepository;

  @override
  void initState() {
    super.initState();
    userRepository = UserRepository(
      AuthService(),
      FirestoreService(),
      LocalStorageService(),
    );
    _getUserDisplayName();
    _loadWardrobeItems(); // Load wardrobe items from SharedPreferences
  }

  void _getUserDisplayName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print(user.uid);
      final userModel = await userRepository.fetchUser();
      if (userModel != null) {
        setState(() {
          displayName = userModel.username;
        });
      } else {
        setState(() {
          displayName = 'Cylinder';
        });
      }
    }
  }

  void _loadWardrobeItems() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userKey = 'wardrobe_items_${user.uid}';
      List<String>? imagePaths = prefs.getStringList(userKey);
      if (imagePaths != null) {
        setState(() {
          wardrobeItems = imagePaths.map((path) => File(path)).toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 40, bottom: 40),
            decoration: const BoxDecoration(
              color: Color(0xFFE1CFFF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(children: const [Spacer(), ThreeDotMenu()]),
                        const SizedBox(height: 10),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.teal,
                          child: Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : 'T', // Display first letter in uppercase
                            style: TextStyle(fontSize: 28, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          displayName.isEmpty
                              ? 'Loading...'
                              : displayName, // Display user's name or loading text
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Text(
                          '@cylinder', // You can customize this to show more info if needed
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        _toggleButtons(),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _interactiveIcon(Icons.bookmark_border, "Bookmark"),
                      const SizedBox(width: 16),
                      _interactiveIcon(Icons.grid_view, "Grid"),
                      const SizedBox(width: 16),
                      _interactiveIcon(
                        Icons.bar_chart,
                        "Stats",
                        onTap: _navigateToStats,
                      ), // Pass the navigation function
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80), // Adjusted height to avoid overlap
          if (wardrobeItems.isEmpty) ...[
            const Text(
              'No items in wardrobe.',
              style: TextStyle(color: Colors.grey),
            ),
            const Text(
              'Tap the blue + button to add items.',
              style: TextStyle(color: Colors.grey),
            ),
          ] else ...[
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: wardrobeItems.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ItemDetailPage(
                                imageFile: wardrobeItems[index],
                              ),
                        ),
                      );
                    },
                    child: Image.file(wardrobeItems[index], fit: BoxFit.cover),
                  );
                },
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.blueAccent,
                      ),
                      title: const Text('Add Items'),
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddItemPage(),
                          ),
                        );
                        if (result != null && result is List<File>) {
                          setState(() {
                            wardrobeItems.addAll(result);
                          });
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.add_circle,
                        color: Colors.blueAccent,
                      ),
                      title: const Text('Add Outfit'),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implement add outfit functionality
                        print('Add Outfit selected');
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: selectedIndex,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _toggleButtons() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedToggle = 0;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color:
                      selectedToggle == 0
                          ? Colors.blueAccent
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Items',
                  style: TextStyle(
                    color: selectedToggle == 0 ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedToggle = 1;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color:
                      selectedToggle == 1
                          ? Colors.blueAccent
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Outfits',
                  style: TextStyle(
                    color: selectedToggle == 1 ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _interactiveIcon(IconData icon, String label, {VoidCallback? onTap}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap:
            onTap ??
            () {
              print('$label tapped');
            },
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(icon, color: Colors.black87, size: 24),
        ),
      ),
    );
  }

  void _navigateToStats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WardrobeInsightsScreen()),
    );
  }
}
