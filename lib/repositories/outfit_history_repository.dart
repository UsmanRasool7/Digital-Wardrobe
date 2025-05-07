import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/outfit_history_table.dart';

class OutfitHistoryRepository {
  final CollectionReference outfitCollection =
  FirebaseFirestore.instance.collection('outfit_history');

  Future<void> addOutfitHistory(OutfitHistory outfit) async {
    await outfitCollection.add(outfit.toMap());
  }

  Future<List<OutfitHistory>> getUserOutfitHistory(String userId) async {
    final snapshot = await outfitCollection
        .where('user_id', isEqualTo: userId)
        .get();

    final list = snapshot.docs.map((doc) {
      return OutfitHistory.fromMap(
        doc.id,
        doc.data()! as Map<String, dynamic>,
      );
    }).toList();

    // Sort by createdAt descending
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> deleteOutfitHistory(String docId) async {
    await outfitCollection.doc(docId).delete();
  }
}
