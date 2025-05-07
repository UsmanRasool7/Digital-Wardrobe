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

  Future<List<OutfitHistory>> getOutfitsByDate(
      DateTime date,
      String loggedInUserId,
      ) async {
    // Compute the day’s bounds
    final startOfDay = Timestamp.fromDate(
      DateTime(date.year, date.month, date.day),
    );
    final endOfDay = Timestamp.fromDate(
      DateTime(date.year, date.month, date.day, 23, 59, 59),
    );

    // Query: filter by user_id (equality), by created_at (range), then order by created_at
    final snapshot = await outfitCollection
        .where('user_id', isEqualTo: loggedInUserId)
        .where('created_at', isGreaterThanOrEqualTo: startOfDay)
        .where('created_at', isLessThanOrEqualTo: endOfDay)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return OutfitHistory.fromMap(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    }).toList();
  }



  Future<void> deleteOutfitHistory(String docId) async {
    await outfitCollection.doc(docId).delete();
  }
}
