import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/widgets/custom_bottom_nav.dart';
import 'package:test_app/repositories/clothing_item_repository.dart';
import 'package:test_app/models/clothing_item_model.dart';
import 'package:test_app/models/outfit_history_table.dart';
import 'package:test_app/repositories/outfit_history_repository.dart';
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
  int _currentOutfitIndex = 0;

  final List<String> _tabs = ['Dress Me'];
  final ClothingItemRepository _clothingRepo = ClothingItemRepository();
  final OutfitHistoryRepository _historyRepo = OutfitHistoryRepository();

  // recommended pools
  List<ClothingItemModel> _recommendedTops = [];
  List<ClothingItemModel> _recommendedBottoms = [];
  List<ClothingItemModel> _recommendedShoes = [];

  // user’s one‑of‑each selection
  ClothingItemModel? _selectedTop;
  ClothingItemModel? _selectedBottom;
  ClothingItemModel? _selectedShoes;

  double? _currentTemperature;

  int get _totalOutfits => [
    _recommendedTops.length,
    _recommendedBottoms.length,
    _recommendedShoes.length,
  ].reduce((a, b) => a < b ? a : b); // Get smallest list length


  Future<void> _fetchCurrentTemperature(String cityName) async {
    const apiKey = '94abe65ce4454ca00732e54f17071b2e'; // Replace with your OpenWeatherMap API key
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final temp = data['main']['temp'];
        _currentTemperature = (temp as num).toDouble();
      } else {
        throw HttpException('Failed to load temperature');
      }
    } catch (e) {
      debugPrint('Error fetching temperature: $e');
    }
  }

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
                children: List.generate(_tabs.length, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: Column(
                      children: [
                        Text(
                          _tabs[i],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: _selectedTab == i
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _selectedTab == i ? Colors.black : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 2,
                          width: 40,
                          color: _selectedTab == i
                              ? Colors.black
                              : Colors.transparent,
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 30),

              if (_selectedTab == 0) ...[

                _buildOutfitViewer(),
                // _buildAddItem('Add Tops'),
                //
                //
                // (
                //   _recommendedTops,
                //   _selectedTop,
                //       (itm) => _selectedTop = itm,
                // ),
                // const SizedBox(height: 20),
                //
                // _buildAddItem('Add Bottoms'),
                // _buildClothingList(
                //   _recommendedBottoms,
                //   _selectedBottom,
                //       (itm) => _selectedBottom = itm,
                // ),
                // const SizedBox(height: 20),
                //
                // _buildAddItem('Add Footwear'),
                // _buildClothingList(
                //   _recommendedShoes,
                //   _selectedShoes,
                //       (itm) => _selectedShoes = itm,
                // ),
                const SizedBox(height: 30),

                // Save Outfit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _saveOutfit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[300],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text('Save Outfit', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final topUrl = _selectedTop?.imageUrl;
                    final bottomUrl = _selectedBottom?.imageUrl;
                    final shoeUrl = _selectedShoes?.imageUrl;
                    debugPrint('Selected URLs:\nTop: \$topUrl\nBottom: \$bottomUrl\nShoes: \$shoeUrl');

                    final prefs = await Navigator.of(context).push<
                        Map<String, String>>(
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
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }

  // Future<void> _saveOutfit() async {
  //   if (_selectedTop == null || _selectedBottom == null || _selectedShoes == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select top, bottom, and footwear.')),
  //     );
  //     return;
  //   }
  //
  //   final user = FirebaseAuth.instance.currentUser!;
  //   final now = DateTime.now();
  //
  //   final history = OutfitHistory(
  //     id: '', // Firestore will assign
  //     userId: user.uid,
  //     createdAt: now,
  //     top: ClothingItem(
  //       itemId: _selectedTop!.id,
  //       colorTag: _selectedTop!.colorTag ?? '',
  //       fitTag: _selectedTop!.fitTag ?? '',
  //     ),
  //     bottom: ClothingItem(
  //       itemId: _selectedBottom!.id,
  //       colorTag: _selectedBottom!.colorTag ?? '',
  //       fitTag: _selectedBottom!.fitTag ?? '',
  //     ),
  //     foot: ClothingItem(
  //       itemId: _selectedShoes!.id,
  //       colorTag: _selectedShoes!.colorTag ?? '',
  //       fitTag: _selectedShoes!.fitTag ?? '',
  //     ),
  //   );
  //
  //   try {
  //     await _historyRepo.addOutfitHistory(history);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Outfit saved successfully!')),
  //     );
  //     // reset selections and recommendations to "reload" page
  //     setState(() {
  //       _selectedTop = null;
  //       _selectedBottom = null;
  //       _selectedShoes = null;
  //       _recommendedTops = [];
  //       _recommendedBottoms = [];
  //       _recommendedShoes = [];
  //     });
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error saving outfit: \$e')),
  //     );
  //   }
  // }
  Future<void> _saveOutfit() async {
    if (_currentOutfitIndex >= _totalOutfits) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No outfit to save.')),
      );
      return;
    }

    final top = _recommendedTops[_currentOutfitIndex];
    final bottom = _recommendedBottoms[_currentOutfitIndex];
    final shoes = _recommendedShoes[_currentOutfitIndex];

    final user = FirebaseAuth.instance.currentUser!;
    final now = DateTime.now();

    final history = OutfitHistory(
      id: '', // Firestore will assign
      userId: user.uid,
      createdAt: now,
      top: ClothingItem(
        itemId: top.id,
        colorTag: top.colorTag ?? '',
        fitTag: top.fitTag ?? '',
      ),
      bottom: ClothingItem(
        itemId: bottom.id,
        colorTag: bottom.colorTag ?? '',
        fitTag: bottom.fitTag ?? '',
      ),
      foot: ClothingItem(
        itemId: shoes.id,
        colorTag: shoes.colorTag ?? '',
        fitTag: shoes.fitTag ?? '',
      ),
    );

    try {
      await _historyRepo.addOutfitHistory(history);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving outfit: $e')),
      );
    }
  }

  /// Builds a selectable list. onSelected just assigns the model;
  /// we call setState here so that the highlight updates instantly.
  Widget _buildOutfitViewer() {
    if (_totalOutfits == 0) return const SizedBox.shrink();

    final isAtAddScreen = _currentOutfitIndex == _totalOutfits;

    return Column(
      children: [
        if (!isAtAddScreen)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildImageWidget(_recommendedTops[_currentOutfitIndex].imageUrl),
              _buildImageWidget(_recommendedBottoms[_currentOutfitIndex].imageUrl),
              _buildImageWidget(_recommendedShoes[_currentOutfitIndex].imageUrl),
            ],
          )
        else
          Column(
            children: [
              ElevatedButton(
                onPressed: ()=>{},//_addTop
                child: const Text('Add Top'),
              ),
              ElevatedButton(
                onPressed: ()=>{},//_addBottom,
                child: const Text('Add Bottom'),
              ),
              ElevatedButton(
                onPressed: ()=>{},//_addFootwear,
                child: const Text('Add Footwear'),
              ),
            ],
          ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left, size: 40),
              onPressed: _currentOutfitIndex > 0
                  ? () => setState(() => _currentOutfitIndex--)
                  : null,
            ),
            Text(
              isAtAddScreen
                  ? 'Add a new outfit'
                  : 'Outfit ${_currentOutfitIndex + 1} of $_totalOutfits',
            ),
            IconButton(
              icon: const Icon(Icons.arrow_right, size: 40),
              onPressed: _currentOutfitIndex < _totalOutfits
                  ? () => setState(() => _currentOutfitIndex++)
                  : null,
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildImageWidget(String url) {
    if (url.isEmpty) {
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        loadingBuilder: (c, child, prog) =>
        prog == null ? child : Container(
          width: 100,
          height: 100,
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorBuilder: (c, e, st) => Container(
          width: 100,
          height: 100,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.red),
        ),
      );
    }
    return Image.file(
      File(url),
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (c, e, st) => Container(
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, color: Colors.red),
      ),
    );
  }

  Widget _buildAddItem(String label) {
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
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  ClothingItemModel? _findBestMatch(
      List<String> tags, List<ClothingItemModel> pool) {
    ClothingItemModel? best;
    int bestScore = -1;
    for (var it in pool) {
      int score = 0;
      if (it.styleTag != null && tags.contains(it.styleTag!)) score++;
      if (it.moodTag != null && tags.contains(it.moodTag!)) score++;
      if (it.occasionTag != null && tags.contains(it.occasionTag!)) score++;
      if (it.colorTag != null && tags.contains(it.colorTag!)) score++;
      if (it.fitTag != null && tags.contains(it.fitTag!)) score++;
      if (it.culturalInfluenceTag != null &&
          tags.contains(it.culturalInfluenceTag!)) {
        score++;
      }
      if (score > bestScore) {
        bestScore = score;
        best = it;
      }
    }
    return best;
  }

  Future<void> _handleDressMePressed(Map<String, String> userPrefs) async {
    try {
      await _fetchCurrentTemperature('Lahore');
      final user = FirebaseAuth.instance.currentUser!;
      final items = await _clothingRepo.getUserClothingItems(user.uid);

      String weatherCategory;
      if (_currentTemperature == null) {
        weatherCategory = 'All-season';
      } else if (_currentTemperature! >= 25) {
        weatherCategory = 'Summer';
      } else if (_currentTemperature! >= 10) {
        weatherCategory = 'Winter';
      } else {
        weatherCategory = 'Winter';
      }

      final filteredItems = items.where((item) {
        final tag = item.weatherTypeTag;
        return tag == 'All-season' || tag == weatherCategory;
      }).toList();
      debugPrint('Filtered items: ${filteredItems.length} items found.');

      final tops = <ClothingItemModel>[];
      final bottoms = <ClothingItemModel>[];
      final shoes = <ClothingItemModel>[];


      for (var it in filteredItems) {
        switch (it.wearTypeTag ) {
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
        }
      }

      List<Map<String, String>> mapOf(List<ClothingItemModel> pool) =>
          pool
              .map((it) => {
            'styleTags': it.styleTag ?? '',
            'moodTags': it.moodTag ?? '',
            'occasionTags': it.occasionTag ?? '',
            'colorTags': it.colorTag ?? '',
            'fitTag': it.fitTag ?? '',
            'culturalInfluenceTag': it.culturalInfluenceTag ?? '',
          })
              .toList();

      final resp = await http.post(
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
      debugPrint('Result: \${resp.body}');
      if (resp.statusCode != 200) {
        throw HttpException('Server error: \${resp.statusCode}');
      }

      final result = jsonDecode(resp.body) as Map<String, dynamic>;
      final recTops = (result['upper_wears'] as List)
          .map((e) => List<String>.from(e))
          .toList();
      final recBottoms = (result['bottom_wears'] as List)
          .map((e) => List<String>.from(e))
          .toList();
      final recShoes = (result['footwears'] as List)
          .map((e) => List<String>.from(e))
          .toList();

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

      setState(() {
        _recommendedTops = displayTops;
        _recommendedBottoms = displayBottoms;
        _recommendedShoes = displayShoes;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Got \${displayTops.length} outfits!')),
      );
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error – please check your connection')),
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
