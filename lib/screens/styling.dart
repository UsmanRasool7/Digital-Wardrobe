import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/widgets/custom_bottom_nav.dart';
import 'package:test_app/repositories/clothing_item_repository.dart';
import 'package:test_app/models/clothing_item_model.dart';
import 'package:test_app/screens/user_input.dart';

class StylingPage extends StatefulWidget {
  const StylingPage({super.key});

  @override
  State<StylingPage> createState() => _StylingPageState();
}

class _StylingPageState extends State<StylingPage> {
  int _currentIndex = 1;
  int _selectedTab = 0;
  final List<String> _tabs = ['Dress Me', 'Canvas', 'Moodboards'];

  final ClothingItemRepository _clothingRepo = ClothingItemRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Top Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_tabs.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = index;
                    });
                  },
                  child: Column(
                    children: [
                      Text(
                        _tabs[index],
                        style: TextStyle(
                          fontWeight: _selectedTab == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 16,
                          color: _selectedTab == index
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 2,
                        width: 40,
                        color: _selectedTab == index
                            ? Colors.black
                            : Colors.transparent,
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            // Arrow Button
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lime,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.black),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 90),
            _buildAddItem('Add Tops'),
            const SizedBox(height: 30),
            _buildAddItem('Add Bottoms'),
            const SizedBox(height: 30),
            _buildAddItem('Add Footwear'),
            const Spacer(),
            // Dress Me Button
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = await Navigator.of(context).push<Map<String, String>>(
                    MaterialPageRoute(
                      builder: (_) => const UserPreferencesPage(),
                    ),
                  );
                  if (prefs != null) {
                    debugPrint('User Preferences: $prefs');
                    await _handleDressMePressed();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[100],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  'Dress Me',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Future<void> _handleDressMePressed() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userId = user.uid;
      final items = await _clothingRepo.getUserClothingItems(userId);

      // Grouped clothing items
      List<ClothingItemModel> topWears = [];
      List<ClothingItemModel> bottomWears = [];
      List<ClothingItemModel> footwears = [];

      // Grouped tag vectors
      List<Map<String, String>> topVectors = [];
      List<Map<String, String>> bottomVectors = [];
      List<Map<String, String>> footVectors = [];

      for (var item in items) {
        final vector = <String, String>{};
        debugPrint('Item tags: style=${item.styleTag}, mood=${item.moodTag}, occasion=${item.occasionTag}, color=${item.colorTag}, fit=${item.fitTag}, culture=${item.culturalInfluenceTag}, wearType=${item.wearTypeTag}');

        if (item.styleTag != null) vector['styleTags'] = item.styleTag!;
        if (item.moodTag != null) vector['moodTags'] = item.moodTag!;
        if (item.occasionTag != null) vector['occasionTags'] = item.occasionTag!;
        if (item.colorTag != null) vector['colorTags'] = item.colorTag!;
        if (item.fitTag != null) vector['fitTag'] = item.fitTag!;
        if (item.culturalInfluenceTag != null) {
          vector['culturalInfluenceTag'] = item.culturalInfluenceTag!;
        }

        switch (item.wearTypeTag) {
          case WearType.topWear:
            topWears.add(item);
            topVectors.add(vector);
            break;
          case WearType.bottomWear:
            bottomWears.add(item);
            bottomVectors.add(vector);
            break;
          case WearType.footwear:
            footwears.add(item);
            footVectors.add(vector);
            break;
          default:
            break;
        }
      }

      // debugPrint('Topwear Vectors: $topVectors');
      // debugPrint('Bottomwear Vectors: $bottomVectors');
      // debugPrint('Footwear Vectors: $footVectors');

      // TODO: Add recommendation logic or navigate to outfit preview

    } catch (e) {
      debugPrint('Error fetching clothing items: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch clothing items.')),
      );
    }
  }

  Widget _buildAddItem(String text) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.lightBlueAccent,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {},
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
