enum WearType { topWear, bottomWear, footwear }

class ClothingItemModel {
  final String   id;
  final String   userId;
  final String   imageUrl;
  final String   category;
  final String?  color;
  final String?  tag;
  final DateTime uploadDate;


  final String?  styleTag;
  final String?  moodTag;
  final double?  priceTag;
  final String?  occasionTag;
  final String?  colorTag;
  final String?  fitTag;
  final String?  weatherTypeTag;
  final String?  culturalInfluenceTag;
  final WearType? wearTypeTag;

  ClothingItemModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.category,
    this.color,
    this.tag,
    required this.uploadDate,
    this.styleTag,
    this.moodTag,
    this.priceTag,
    this.occasionTag,
    this.colorTag,
    this.fitTag,
    this.weatherTypeTag,
    this.culturalInfluenceTag,
    this.wearTypeTag,
  });

  ClothingItemModel copyWith({
    String?   id,
    String?   userId,
    String?   imageUrl,
    String?   category,
    String?   color,
    String?   tag,
    DateTime? uploadDate,
    String?   styleTag,
    String?   moodTag,
    double?   priceTag,
    String?   occasionTag,
    String?   colorTag,
    String?   fitTag,
    String?   weatherTypeTag,
    String?   culturalInfluenceTag,
    WearType? wearTypeTag,
  }) {
    return ClothingItemModel(
      id: id             ?? this.id,
      userId: userId     ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      color: color       ?? this.color,
      tag: tag           ?? this.tag,
      uploadDate: uploadDate                       ?? this.uploadDate,
      styleTag: styleTag                           ?? this.styleTag,
      moodTag: moodTag                             ?? this.moodTag,
      priceTag: priceTag                           ?? this.priceTag,
      occasionTag: occasionTag                     ?? this.occasionTag,
      colorTag: colorTag                           ?? this.colorTag,
      fitTag: fitTag                               ?? this.fitTag,
      weatherTypeTag: weatherTypeTag               ?? this.weatherTypeTag,
      culturalInfluenceTag: culturalInfluenceTag   ?? this.culturalInfluenceTag,
      wearTypeTag: wearTypeTag                     ?? this.wearTypeTag,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':                       id,
      'userId':                   userId,
      'imageUrl':                 imageUrl,
      'category':                 category,
      'color':                    color,
      'tag':                      tag,
      'uploadDate':               uploadDate.toIso8601String(),
      'styleTag':                 styleTag,
      'moodTag':                  moodTag,
      'priceTag':                 priceTag,
      'occasionTag':              occasionTag,
      'colorTag':                 colorTag,
      'fitTag':                   fitTag,
      'weatherTypeTag':           weatherTypeTag,
      'culturalInfluenceTag':     culturalInfluenceTag,
      'wearTypeTag':              wearTypeTag?.toString().split('.').last,
    };
  }

  factory ClothingItemModel.fromMap(Map<String, dynamic> map) {
    WearType? parseWearType(String? value) {
      if (value == null) return null;
      try {
        return WearType.values.firstWhere(
              (e) => e.toString().split('.').last == value,
        );
      } on StateError {
        // no match → return null
        return null;
      }
    }


    return ClothingItemModel(
      id:                       map['id'] ?? '',
      userId:                   map['userId'] ?? '',
      imageUrl:                 map['imageUrl'] ?? '',
      category:                 map['category'] ?? '',
      color:                    map['color'],
      tag:                      map['tag'],
      uploadDate:               DateTime.tryParse(map['uploadDate'] ?? '')
          ?? DateTime.now(),
      styleTag:                 map['styleTag'],
      moodTag:                  map['moodTag'],
      priceTag:                 (map['priceTag'] as num?)?.toDouble(),
      occasionTag:              map['occasionTag'],
      colorTag:                 map['colorTag'],
      fitTag:                   map['fitTag'],
      weatherTypeTag:           map['weatherTypeTag'],
      culturalInfluenceTag:     map['culturalInfluenceTag'],
      wearTypeTag:              parseWearType(map['wearTypeTag']),
    );
  }

  @override
  String toString() =>
      'ClothingItemModel(id: $id, userId: $userId, category: $category, tag: $tag, ... )';
}
