
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Write (or merge) the given UserModel into `users/{uid}`
  Future<void> updateUser(UserModel user) {
    return _db
        .collection('users')
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  /// Fetches the user document at `users/{uid}` and converts it to UserModel.
  Future<UserModel?> fetchUser(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserModel.fromMap({
      'uid': snap.id,
      ...snap.data()!,
    });
  }
}
