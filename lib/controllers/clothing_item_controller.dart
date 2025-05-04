import 'package:uuid/uuid.dart';
import '../models/clothing_item_model.dart';
import '../repositories/clothing_item_repository.dart';

class ClothingItemController {
  final ClothingItemRepository _repo;

  ClothingItemController(this._repo);

  Future<void> uploadClothingItem({
    required String userId,
    required String imageUrl,
    required String category,
    String? color,
    List<String>? tags,
    List<String>? styleTags,
    List<String>? moodTags,
    double? priceTag,
    List<String>? occasionTags,
    List<String>? colorTags,
    String? fitTag,
    String? weatherTypeTag,
    String? culturalInfluenceTag,
    WearType? wearTypeTag,
  }) async {
    final item = ClothingItemModel(
      id: const Uuid().v4(),
      userId: userId,
      imageUrl: imageUrl,
      category: category,
      color: color,
      tags: tags,
      uploadDate: DateTime.now(),
      styleTags: styleTags,
      moodTags: moodTags,
      priceTag: priceTag,
      occasionTags: occasionTags,
      colorTags: colorTags,
      fitTag: fitTag,
      weatherTypeTag: weatherTypeTag,
      culturalInfluenceTag: culturalInfluenceTag,
      wearTypeTag: wearTypeTag,
    );

    await _repo.addClothingItem(item);
  }

  Future<List<ClothingItemModel>> fetchUserItems(String userId) {
    return _repo.getUserClothingItems(userId);
  }

  Future<void> deleteItem(String itemId) {
    return _repo.deleteClothingItem(itemId);
  }

  Future<void> updateItem(ClothingItemModel item) {
    return _repo.updateClothingItem(item);
  }
}
