// lib/services/storage_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'digital-wardrobe-ed3ce.appspot.com',
  );

  Future<String> uploadProfileImage(File file, String uid) async {
    // --- OUTSIDE TRY SO WE ALWAYS SEE THESE LOGS ---
    final appName    = _storage.app.name;
    final options    = _storage.app.options;
    final bucket     = options.storageBucket;
    final fileExists = file.existsSync();
    print('🛠 [StorageService] APP NAME:       $appName');
    print('🛠 [StorageService] STORAGE BUCKET: $bucket');
    print('🛠 [StorageService] FILE PATH:      ${file.path}');
    print('🛠 [StorageService] FILE EXISTS?:   $fileExists');
    // -----------------------------------------------

    // Now the normal upload flow
    try {
      final ext       = file.path.split('.').last.toLowerCase();
      final ts        = DateTime.now().millisecondsSinceEpoch;
      final path      = 'user_profiles/$uid/$ts.$ext';
      print('🛠 [StorageService] UPLOAD PATH:    $path');

      final ref       = _storage.ref().child(path);
      final metadata  = SettableMetadata(
        contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
        customMetadata: {'uploaded_by': uid},
      );

      final snapshot  = await ref.putFile(file, metadata);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('🛠 [StorageService] SUCCESS URL:   $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('🛠 [StorageService] FIREBASE ERR:   ${e.code}');
      print('🛠 [StorageService] FIREBASE MSG:   ${e.message}');
      throw StorageException('Upload error: ${e.code}');
    }
  }
}

class StorageException implements Exception {
  final String message;
  StorageException(this.message);
  @override
  String toString() => 'StorageException: $message';
}
