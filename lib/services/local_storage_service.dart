// services/local_storage_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class LocalStorageService {
  Future<String> saveProfileImage(File imageFile, String uid) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'profile_images');

    // Create directory if it doesn't exist
    await Directory(path).create(recursive: true);

    // Save file
    final newPath = join(path, '$uid.png');
    await imageFile.copy(newPath);

    return newPath;
  }

  Future<String?> getProfileImagePath(String uid) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'profile_images', '$uid.png');
    return File(path).existsSync() ? path : null;
  }
}