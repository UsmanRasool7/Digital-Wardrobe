enum WearType { topWear, bottomWear, footwear }

class ClothingItemModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String category;
  final String? color;
  final List<String>? tags;
  final DateTime uploadDate;

  // New tag fields
  final List<String>? styleTags;
  final List<String>? moodTags;
  final double? priceTag;
  final List<String>? occasionTags;
  final List<String>? colorTags;
  final String? fitTag;
  final String? weatherTypeTag;
  final String? culturalInfluenceTag;

  // New wear-type tag
  final WearType? wearTypeTag;

  ClothingItemModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.category,
    required this.color,
    this.tags,
    required this.uploadDate,
    this.styleTags,
    this.moodTags,
    this.priceTag,
    this.occasionTags,
    this.colorTags,
    this.fitTag,
    this.weatherTypeTag,
    this.culturalInfluenceTag,
    this.wearTypeTag,
  });

  ClothingItemModel copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? category,
    String? color,
    List<String>? tags,
    DateTime? uploadDate,
    List<String>? styleTags,
    List<String>? moodTags,
    double? priceTag,
    List<String>? occasionTags,
    List<String>? colorTags,
    String? fitTag,
    String? weatherTypeTag,
    String? culturalInfluenceTag,
    WearType? wearTypeTag,
  }) {
    return ClothingItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      color: color ?? this.color,
      tags: tags ?? this.tags,
      uploadDate: uploadDate ?? this.uploadDate,
      styleTags: styleTags ?? this.styleTags,
      moodTags: moodTags ?? this.moodTags,
      priceTag: priceTag ?? this.priceTag,
      occasionTags: occasionTags ?? this.occasionTags,
      colorTags: colorTags ?? this.colorTags,
      fitTag: fitTag ?? this.fitTag,
      weatherTypeTag: weatherTypeTag ?? this.weatherTypeTag,
      culturalInfluenceTag: culturalInfluenceTag ?? this.culturalInfluenceTag,
      wearTypeTag: wearTypeTag ?? this.wearTypeTag,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'category': category,
      'color': color,
      'tags': tags,
      'uploadDate': uploadDate.toIso8601String(),
      'styleTags': styleTags,
      'moodTags': moodTags,
      'priceTag': priceTag,
      'occasionTags': occasionTags,
      'colorTags': colorTags,
      'fitTag': fitTag,
      'weatherTypeTag': weatherTypeTag,
      'culturalInfluenceTag': culturalInfluenceTag,
      'wearTypeTag': wearTypeTag?.toString().split('.').last, // e.g. "topWear"
    };
  }

  factory ClothingItemModel.fromMap(Map<String, dynamic> map) {
    WearType? parseWearType(String? value) {
      if (value == null) return null;
      try {
        return WearType.values
            .firstWhere((e) => e.toString().split('.').last == value);
      } catch (_) {
        return null;
      }
    }

    return ClothingItemModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      color: map['color'],
      tags: List<String>.from(map['tags'] ?? []),
      uploadDate: DateTime.tryParse(map['uploadDate'] ?? '') ?? DateTime.now(),
      styleTags: List<String>.from(map['styleTags'] ?? []),
      moodTags: List<String>.from(map['moodTags'] ?? []),
      priceTag: map['priceTag']?.toDouble(),
      occasionTags: List<String>.from(map['occasionTags'] ?? []),
      colorTags: List<String>.from(map['colorTags'] ?? []),
      fitTag: map['fitTag'],
      weatherTypeTag: map['weatherTypeTag'],
      culturalInfluenceTag: map['culturalInfluenceTag'],
      wearTypeTag: parseWearType(map['wearTypeTag']),
    );
  }

  @override
  String toString() {
    return 'ClothingItemModel('
        'id: $id, userId: $userId, imageUrl: $imageUrl, category: $category, '
        'color: $color, tags: $tags, uploadDate: $uploadDate, '
        'styleTags: $styleTags, moodTags: $moodTags, priceTag: $priceTag, '
        'occasionTags: $occasionTags, colorTags: $colorTags, fitTag: $fitTag, '
        'weatherTypeTag: $weatherTypeTag, culturalInfluenceTag: $culturalInfluenceTag, '
        'wearTypeTag: $wearTypeTag'
        ')';
  }
}
