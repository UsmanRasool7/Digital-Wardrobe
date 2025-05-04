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
      appBar: AppBar(title: const Text('Item Detail')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: imageWidget),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (clothingItem.styleTags != null)
                  Text('Style: ${clothingItem.styleTags!}'),
                if (clothingItem.moodTags != null)
                  Text('Mood: ${clothingItem.moodTags!}'),
                if (clothingItem.occasionTags != null)
                  Text('Occasion: ${clothingItem.occasionTags!}'),
                if (clothingItem.priceTag != null)
                  Text('Price: \$${clothingItem.priceTag!.toStringAsFixed(2)}'),
                if (clothingItem.colorTags != null && clothingItem.colorTags!.isNotEmpty)
                  Text('Colors: ${clothingItem.colorTags!.join(', ')}'),
                if (clothingItem.fitTag != null)
                  Text('Fit: ${clothingItem.fitTag!}'),
                if (clothingItem.weatherTypeTag != null)
                  Text('Weather: ${clothingItem.weatherTypeTag!}'),
                if (clothingItem.culturalInfluenceTag != null)
                  Text('Cultural Influence: ${clothingItem.culturalInfluenceTag!}'),
                if (clothingItem.wearTypeTag != null)
                  Text('Wear Type: ${clothingItem.wearTypeTag!.name}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
