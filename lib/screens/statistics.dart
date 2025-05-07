import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/models/outfit_history_table.dart';
import '/models/clothing_item_model.dart';
import '/repositories/outfit_history_repository.dart';
import '/repositories/clothing_item_repository.dart';

class WardrobeStatsPage extends StatefulWidget {
  const WardrobeStatsPage({Key? key}) : super(key: key);

  @override
  _WardrobeStatsPageState createState() => _WardrobeStatsPageState();
}

class _WardrobeStatsPageState extends State<WardrobeStatsPage> {
  final _historyRepo = OutfitHistoryRepository();
  final _itemRepo = ClothingItemRepository();

  late Future<void> _initFuture;
  List<OutfitHistory> _history = [];
  List<ClothingItemModel> _items = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _initFuture = _initData();
  }

  Future<void> _initData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final history = await _historyRepo.getUserOutfitHistory(uid);
      final items = await _itemRepo.getUserClothingItems(uid);
      setState(() {
        _history = history;
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
        _loading = false;
      });
    }
  }

  /// Generic counter by ID extractor
  Map<String, int> _countById<T>(List<T> list, String Function(T) idExtractor) {
    final counts = <String, int>{};
    for (var item in list) {
      final id = idExtractor(item);
      counts.update(id, (v) => v + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Wardrobe Stats'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snap) {
          if (_loading) return const Center(child: CircularProgressIndicator());
          if (_error.isNotEmpty) return Center(child: Text(_error));

          // Map history to clothing lists
          final tops = _history.map((h) => h.top).toList();
          final bottoms = _history.map((h) => h.bottom).toList();
          final feet = _history.map((h) => h.foot).toList();

          // Count occurrences per itemId
          final topCounts = _countById<ClothingItem>(tops, (c) => c.itemId);
          final bottomCounts = _countById<ClothingItem>(bottoms, (c) => c.itemId);
          final footCounts = _countById<ClothingItem>(feet, (c) => c.itemId);

          /// Lookup imageUrl from ClothingItemModel list
          String imgFor(String id) {
            final match = _items.firstWhere(
                  (i) => i.id == id,
              orElse: () => ClothingItemModel(
                id: id,
                category: '',
                uploadDate: DateTime.now(),
                userId: '',
                imageUrl: '',
              ),
            );
            return match.imageUrl;
          }

          Widget buildSection(String title, Map<String, int> counts) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: counts.entries.map((e) {
                        final url = imgFor(e.key);
                        return Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: url.isNotEmpty
                                    ? (url.startsWith('http')
                                    ? CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                  placeholder: (c, u) => const Center(child: CircularProgressIndicator()),
                                  errorWidget: (c, u, _) => const Icon(Icons.broken_image),
                                )
                                    : Image.file(File(url), fit: BoxFit.cover))
                                    : Container(color: Colors.grey[200]),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('${e.value}× worn', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            children: [
              buildSection('Topwear Usage', topCounts),
              buildSection('Bottomwear Usage', bottomCounts),
              buildSection('Footwear Usage', footCounts),
            ],
          );
        },
      ),
    );
  }
}