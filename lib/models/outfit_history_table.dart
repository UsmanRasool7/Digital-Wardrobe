import 'package:cloud_firestore/cloud_firestore.dart';

class OutfitHistory {
  final String id;
  final String userId;
  final DateTime createdAt;

  final ClothingItem top;
  final ClothingItem bottom;
  final ClothingItem foot;

  OutfitHistory({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.top,
    required this.bottom,
    required this.foot,
  });

  factory OutfitHistory.fromMap(String id, Map<String, dynamic> data) {
    return OutfitHistory(
      id: id,
      userId: data['user_id'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      top: ClothingItem.fromMap(data['top'] ?? {}),
      bottom: ClothingItem.fromMap(data['bottom'] ?? {}),
      foot: ClothingItem.fromMap(data['foot'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'created_at': createdAt,
      'top': top.toMap(),
      'bottom': bottom.toMap(),
      'foot': foot.toMap(),
    };
  }
}

class ClothingItem {
  final String itemId;
  final String colorTag;
  final String fitTag;

  ClothingItem({
    required this.itemId,
    required this.colorTag,
    required this.fitTag,
  });

  factory ClothingItem.fromMap(Map<String, dynamic> data) {
    return ClothingItem(
      itemId: data['item_id'] ?? '',
      colorTag: data['color_tag'] ?? '',
      fitTag: data['fit_tag'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId,
      'color_tag': colorTag,
      'fit_tag': fitTag,
    };
  }
}
