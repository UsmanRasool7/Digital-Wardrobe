import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/outfit_history_table.dart';

class OutfitHistoryRepository {
  final CollectionReference outfitCollection =
      FirebaseFirestore.instance.collection('outfit_history');

  Future<void> addOutfitHistory(OutfitHistory outfit) async {
    await outfitCollection.add(outfit.toMap());
  }

  Future<List<OutfitHistory>> getUserOutfitHistory(
      String userId, String loggedInUserId) async {
    if (userId != loggedInUserId) {
      return []; // Return an empty list if the user IDs do not match
    }

    final snapshot = await outfitCollection
        .where('user_id', isEqualTo: loggedInUserId)
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
      DateTime date, String loggedInUserId) async {
    final startOfDay =
        Timestamp.fromDate(DateTime(date.year, date.month, date.day));
    final endOfDay = Timestamp.fromDate(
        DateTime(date.year, date.month, date.day, 23, 59, 59));

    final snapshot = await outfitCollection
        .where('created_at', isGreaterThanOrEqualTo: startOfDay)
        .where('created_at', isLessThanOrEqualTo: endOfDay)
        .where('user_id', isEqualTo: loggedInUserId)
        .get();

    return snapshot.docs.map((doc) {
      return OutfitHistory.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> deleteOutfitHistory(String docId) async {
    await outfitCollection.doc(docId).delete();
  }
}
