// lib/screens/item_detail_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/clothing_item_model.dart';

class ItemDetailPage extends StatelessWidget {
  final ClothingItemModel clothingItem;

  const ItemDetailPage({
    super.key,
    required this.clothingItem,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = clothingItem.imageUrl;
    final imageWidget = imageUrl.startsWith('http')
        ? Image.network(imageUrl, fit: BoxFit.cover)
        : Image.file(File(imageUrl), fit: BoxFit.cover);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Detail'),
        backgroundColor: Colors.teal, // Adjust app bar color to match app theme
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: imageWidget,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (clothingItem.styleTags != null)
                      Row(
                        children: [
                          const Icon(Icons.style, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text('Style: ${clothingItem.styleTags!}',
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    if (clothingItem.moodTags != null)
                      Row(
                        children: [
                          const Icon(Icons.mood, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text('Mood: ${clothingItem.moodTags!}',
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    if (clothingItem.occasionTags != null)
                      Row(
                        children: [
                          const Icon(Icons.event, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text('Occasion: ${clothingItem.occasionTags!}',
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    if (clothingItem.priceTag != null)
                      Row(
                        children: [
                          const Icon(Icons.attach_money, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                              'Price: \$${clothingItem.priceTag!.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    if (clothingItem.colorTags != null &&
                        clothingItem.colorTags!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.color_lens, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text('Colors: ${clothingItem.colorTags!.join(', ')}',
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    if (clothingItem.fitTag != null)
                      Row(
                        children: [
                          const Icon(Icons.checkroom, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text('Fit: ${clothingItem.fitTag!}',
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    if (clothingItem.weatherTypeTag != null)
                      Row(
                        children: [
                          const Icon(Icons.wb_sunny, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text('Weather: ${clothingItem.weatherTypeTag!}',
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    if (clothingItem.culturalInfluenceTag != null)
                      Row(
                        children: [
                          const Icon(Icons.public, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                              'Cultural Influence: ${clothingItem.culturalInfluenceTag!}',
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    if (clothingItem.wearTypeTag != null)
                      Row(
                        children: [
                          const Icon(Icons.category, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text('Wear Type: ${clothingItem.wearTypeTag!.name}',
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
