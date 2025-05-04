import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/clothing_item_model.dart';
import '../repositories/clothing_item_repository.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/three_dot_menu.dart';
import 'wardrobe_insights_page.dart';
import 'item_detail_page.dart';
import 'add_item_page.dart';

class WardrobeHomePage extends StatefulWidget {
  const WardrobeHomePage({Key? key}) : super(key: key);

  @override
  State<WardrobeHomePage> createState() => _WardrobeHomePageState();
}

class _WardrobeHomePageState extends State<WardrobeHomePage> {
  final ClothingItemRepository _itemRepo = ClothingItemRepository();
  final UserRepository _userRepo = UserRepository(
    AuthService(),
    FirestoreService(),
    LocalStorageService(),
  );

  List<ClothingItemModel> _items = [];
  bool _loading = true;
  String _errorMessage = '';

  int selectedIndex = 2;
  int selectedToggle = 0;
  String displayName = 'User';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchUserItems();
  }

  Future<void> _fetchUserName() async {
    try {
      final userModel = await _userRepo.fetchUser();
      if (userModel != null) {
        setState(() {
          displayName = userModel.username;
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch username: $e');
    }
  }

  Future<void> _fetchUserItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Not signed in';
        _loading = false;
      });
      return;
    }

    try {
      final items = await _itemRepo.getUserClothingItems(user.uid);
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load items: $e';
        _loading = false;
      });
    }
  }

  void _onAddItemPressed() async {
    final result = await Navigator.push<ClothingItemModel>(
      context,
      MaterialPageRoute(builder: (_) => const AddItemPage()),
    );
    if (result != null) {
      setState(() => _items.insert(0, result));
    }
  }

  void _navigateToStats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WardrobeInsightsScreen()),
    );
  }

  Widget _buildGrid() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage.isNotEmpty) return Center(child: Text(_errorMessage));
    if (_items.isEmpty) {
      return const Center(
        child: Text('No items in wardrobe.', style: TextStyle(color: Colors.grey)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        debugPrint('Rendering image: ${item.imageUrl}');

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItemDetailPage(clothingItem: item),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.imageUrl.isNotEmpty
                ? (item.imageUrl.startsWith('http')
                ? CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
            )
                : Image.file(
              File(item.imageUrl),
              fit: BoxFit.cover,
            ))
                : Container(
              color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        _toggleButton('Items', 0),
        _toggleButton('Outfits', 1),
      ]),
    );
  }

  Widget _toggleButton(String label, int idx) {
    final sel = selectedToggle == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedToggle = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: sel ? Colors.blueAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(color: sel ? Colors.white : Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
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
        onTap: onTap ?? () => debugPrint('$label tapped'),
        child: SizedBox(width: 56, height: 56, child: Icon(icon, size: 24)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(children: [
        Container(
          padding: const EdgeInsets.only(top: 40, bottom: 40),
          decoration: const BoxDecoration(
            color: Color(0xFFE1CFFF),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Stack(clipBehavior: Clip.none, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(children: [
                  Row(children: const [Spacer(), ThreeDotMenu()]),
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.teal,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : '',
                      style: const TextStyle(fontSize: 28, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Text('@cylinder', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  _buildToggle(),
                ]),
              ),
            ),
            Positioned(
              bottom: -30,
              left: 0,
              right: 0,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _interactiveIcon(Icons.bookmark_border, 'Bookmark'),
                const SizedBox(width: 16),
                _interactiveIcon(Icons.grid_view, 'Grid'),
                const SizedBox(width: 16),
                _interactiveIcon(Icons.bar_chart, 'Stats', onTap: _navigateToStats),
              ]),
            ),
          ]),
        ),

        const SizedBox(height: 80),
        Expanded(child: _buildGrid()),
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: _onAddItemPressed,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
      ),
    );
  }
}
