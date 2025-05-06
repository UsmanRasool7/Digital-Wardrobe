// lib/screens/item_detail_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/clothing_item_model.dart';
import '../repositories/clothing_item_repository.dart';
import 'edit_item_page.dart';

class ItemDetailPage extends StatefulWidget {
  final String itemId;

  const ItemDetailPage({
    super.key,
    required this.itemId,
  });

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late Future<ClothingItemModel> _clothingItemFuture;

  @override
  void initState() {
    super.initState();
    _fetchClothingItem();
  }

  void _fetchClothingItem() {
    _clothingItemFuture = ClothingItemRepository()
        .getClothingItemById(widget.itemId)
        .then((item) {
      if (item == null) {
        throw Exception('Item not found');
      }
      return item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ClothingItemModel>(
      future: _clothingItemFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Item not found')),
          );
        }

        final clothingItem = snapshot.data!;
        final imageUrl = clothingItem.imageUrl;
        Widget imageWidget;

        if (imageUrl.startsWith('http')) {
          imageWidget = Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 250,
          );
        } else {
          imageWidget = Image.file(
            File(imageUrl),
            fit: BoxFit.cover,
            width: double.infinity,
            height: 250,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Item Detail'),
            backgroundColor: Colors.teal,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final updatedItem = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditItemPage(
                        clothingItem: clothingItem,
                      ),
                    ),
                  );
                  if (updatedItem != null) {
                    setState(() {
                      _fetchClothingItem();
                    });
                  }
                },
                tooltip: 'Edit Item',
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
                  child: imageWidget,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (clothingItem.styleTag != null)
                            _buildDetailRow(
                              icon: Icons.style,
                              label: 'Style',
                              value: clothingItem.styleTag!,
                            ),
                          if (clothingItem.moodTag != null)
                            _buildDetailRow(
                              icon: Icons.mood,
                              label: 'Mood',
                              value: clothingItem.moodTag!,
                            ),
                          if (clothingItem.occasionTag != null)
                            _buildDetailRow(
                              icon: Icons.event,
                              label: 'Occasion',
                              value: clothingItem.occasionTag!,
                            ),
                          if (clothingItem.priceTag != null)
                            _buildDetailRow(
                              icon: Icons.attach_money,
                              label: 'Price',
                              value:
                              '\\${clothingItem.priceTag!.toStringAsFixed(2)}',
                            ),
                          if (clothingItem.colorTag != null)
                            _buildDetailRow(
                              icon: Icons.color_lens,
                              label: 'Color',
                              value: clothingItem.colorTag!,
                            ),
                          if (clothingItem.fitTag != null)
                            _buildDetailRow(
                              icon: Icons.checkroom,
                              label: 'Fit',
                              value: clothingItem.fitTag!,
                            ),
                          if (clothingItem.weatherTypeTag != null)
                            _buildDetailRow(
                              icon: Icons.wb_sunny,
                              label: 'Weather',
                              value: clothingItem.weatherTypeTag!,
                            ),
                          if (clothingItem.culturalInfluenceTag != null)
                            _buildDetailRow(
                              icon: Icons.public,
                              label: 'Cultural Influence',
                              value: clothingItem.culturalInfluenceTag!,
                            ),
                          if (clothingItem.wearTypeTag != null)
                            _buildDetailRow(
                              icon: Icons.category,
                              label: 'Wear Type',
                              value: clothingItem.wearTypeTag!.name,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
