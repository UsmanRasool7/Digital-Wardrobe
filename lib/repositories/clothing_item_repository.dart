// lib/repositories/clothing_item_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/clothing_item_model.dart';

class ClothingItemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'clothing_items';

  Future<void> addClothingItem(ClothingItemModel item) async {
    await _firestore.collection(_collection).doc(item.id).set(item.toMap());
  }

  Future<void> updateClothingItem(ClothingItemModel item) async {
    await _firestore.collection(_collection).doc(item.id).update(item.toMap());
  }

  Future<void> deleteClothingItem(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<List<ClothingItemModel>> getUserClothingItems(String userId) async {
    // 1) Fetch all for this user (no orderBy)
    final snap = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .get();

    // 2) Map each DocumentSnapshot → ClothingItemModel, injecting doc.id
    final items = snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ClothingItemModel.fromMap(data);
    }).toList();

    // 3) Sort in‑memory by uploadDate descending
    items.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
    return items;
  }

  Future<ClothingItemModel?> getClothingItemById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    data['id'] = doc.id;
    return ClothingItemModel.fromMap(data);
  }
}
