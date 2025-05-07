import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/widgets/custom_bottom_nav.dart';
import 'package:test_app/repositories/clothing_item_repository.dart';
import 'package:test_app/models/clothing_item_model.dart';
import 'package:test_app/screens/user_input.dart';
import 'package:http/http.dart' as http;

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

  // <-- NEW: hold your recommended models
  List<ClothingItemModel> _recommendedTops    = [];
  List<ClothingItemModel> _recommendedBottoms = [];
  List<ClothingItemModel> _recommendedShoes   = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_tabs.length, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = index),
                    child: Column(
                      children: [
                        Text(
                          _tabs[index],
                          style: TextStyle(
                            fontWeight: _selectedTab == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 16,
                            color: _selectedTab == index ? Colors.black : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 2,
                          width: 40,
                          color: _selectedTab == index ? Colors.black : Colors.transparent,
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 30),

              if (_selectedTab == 0) ...[
                _buildAddItem('Add Tops'),
                _buildClothingList(_recommendedTops),
                const SizedBox(height: 20),

                _buildAddItem('Add Bottoms'),
                _buildClothingList(_recommendedBottoms),
                const SizedBox(height: 20),

                _buildAddItem('Add Footwear'),
                _buildClothingList(_recommendedShoes),
                const SizedBox(height: 30),
              ],

              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs = await Navigator.of(context).push<Map<String, String>>(
                      MaterialPageRoute(
                        builder: (_) => const UserPreferencesPage(),
                      ),
                    );
                    if (prefs != null) {
                      await _handleDressMePressed(prefs);
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
                  child: const Text('Dress Me', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

// Builds a list of clothing items (tops, bottoms, or footwear)
  Widget _buildClothingList(List<ClothingItemModel> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items.map((item) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildImageWidget(item.imageUrl),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }

    if (imageUrl.startsWith('http')) {
      // Handling Network Image
      return Image.network(
        imageUrl,
        height: 100,
        width: 100,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.red),
          );
        },
      );
    } else {
      // Handling Local Image
      return Image.file(
        File(imageUrl),
        height: 100,
        width: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.red),
          );
        },
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
        Text(text, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  /// Finds the ClothingItemModel in [pool] whose tags best match [tags].
  ClothingItemModel? _findBestMatch(
      List<String> tags, List<ClothingItemModel> pool) {
    ClothingItemModel? best;
    int bestScore = -1;

    for (var item in pool) {
      int score = 0;
      if (item.styleTag != null &&
          tags.contains(item.styleTag!)) score++;
      if (item.moodTag != null && tags.contains(item.moodTag!)) score++;
      if (item.occasionTag != null &&
          tags.contains(item.occasionTag!)) score++;
      if (item.colorTag != null && tags.contains(item.colorTag!)) score++;
      if (item.fitTag != null && tags.contains(item.fitTag!)) score++;
      if (item.culturalInfluenceTag != null &&
          tags.contains(item.culturalInfluenceTag!)) score++;

      if (score > bestScore) {
        bestScore = score;
        best = item;
      }
    }
    return best;
  }

  Future<void> _handleDressMePressed(Map<String, String> userPrefs) async {
    try {
      // 1) fetch all items
      final user = FirebaseAuth.instance.currentUser!;
      final items = await _clothingRepo.getUserClothingItems(user.uid);

      // 2) split into three pools
      final tops = <ClothingItemModel>[];
      final bottoms = <ClothingItemModel>[];
      final shoes = <ClothingItemModel>[];

      for (var it in items) {
        switch (it.wearTypeTag) {
          case WearType.topWear:
            tops.add(it);
            break;
          case WearType.bottomWear:
            bottoms.add(it);
            break;
          case WearType.footwear:
            shoes.add(it);
            break;
          default:
            break;
        }
      }

      // 3) build the tag‐vectors to send
      List<Map<String, String>> mapOf(List<ClothingItemModel> pool) =>
          pool.map((it) => {
            'styleTags': it.styleTag ?? '',
            'moodTags': it.moodTag ?? '',
            'occasionTags': it.occasionTag ?? '',
            'colorTags': it.colorTag ?? '',
            'fitTag': it.fitTag ?? '',
            'culturalInfluenceTag': it.culturalInfluenceTag ?? '',
          }).toList();

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_input': {
            'styleTags': userPrefs['styleTags'] ?? '',
            'moodTags': userPrefs['moodTags'] ?? '',
            'occasionTags': userPrefs['occasionTags'] ?? '',
            'culturalInfluenceTag':
            userPrefs['culturalInfluenceTag'] ?? '',
          },
          'top_items': mapOf(tops),
          'bottom_items': mapOf(bottoms),
          'foot_items': mapOf(shoes),
        }),
      );

      if (response.statusCode != 200) {
        throw HttpException(
            'Server error: ${response.statusCode}');
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;

      // 4) parse into List<List<String>>
      final recTops = (result['upper_wears'] as List)
          .map((e) => List<String>.from(e))
          .toList();
      final recBottoms = (result['bottom_wears'] as List)
          .map((e) => List<String>.from(e))
          .toList();
      final recShoes = (result['footwears'] as List)
          .map((e) => List<String>.from(e))
          .toList();

      // 5) find best model matches
      final displayTops = recTops
          .map((tags) => _findBestMatch(tags, tops))
          .whereType<ClothingItemModel>()
          .toList();
      final displayBottoms = recBottoms
          .map((tags) => _findBestMatch(tags, bottoms))
          .whereType<ClothingItemModel>()
          .toList();
      final displayShoes = recShoes
          .map((tags) => _findBestMatch(tags, shoes))
          .whereType<ClothingItemModel>()
          .toList();

      // 6) update UI
      setState(() {
        _recommendedTops = displayTops;
        _recommendedBottoms = displayBottoms;
        _recommendedShoes = displayShoes;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Got ${displayTops.length} outfits!')),
      );
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Network error – please check your connection')),
      );
    } on HttpException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error.')),
      );
    }
  }
}
