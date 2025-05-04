// lib/constants/tag_options.dart

class TagOptions {
  /// Predefined style tags
  static const List<String> styleTags = [
    'Casual',
    'Formal',
    'Sporty',
    'Streetwear',
    'Business',
    'Bohemian',
    'Vintage',
    'Minimalist',
    'Trendy',
    'Fancy',
  ];

  /// Predefined mood tags
  static const List<String> moodTags = [
    'Relaxed',
    'Energetic',
    'Confident',
    'Playful',
    'Mysterious',
    'Calm',
    'Adventurous',
  ];

  /// Price is a numeric value—no fixed options.
  /// In your form you might use a TextField with `keyboardType: TextInputType.number`
  /// or a Slider from min→max to capture this.
  /// static const List<double> priceRanges = [ ... ]; // if you ever want ranges

  /// Predefined occasions
  static const List<String> occasionTags = [
    'Home',
    'Party',
    'Wedding',
    'Office',
    'School',
    'Gym',
    'Travel',
    'Lounge',
    'Date',
    'Interview',
  ];

  /// A basic palette of color names
  static const List<String> colorTags = [
    'Black',
    'White',
    'Gray',
    'Brown',
    'Red',
    'Orange',
    'Yellow',
    'Green',
    'Blue',
    'Purple',
    'Pink',
    'Beige',
    'Navy',
    'Teal',
  ];

  /// Fit options
  static const List<String> fitTags = [
    'Slim',
    'Regular',
    'Oversized',
    'Tight',
    'Loose',
    'Relaxed',
  ];

  /// Weather suitability
  static const List<String> weatherTypeTags = [
    'Summer',
    'Winter',
    'Rainy',
    'All-season',
  ];

  /// Cultural influences
  static const List<String> culturalInfluenceTags = [
    'Western',
    'Eastern',
    'Traditional',
  ];
}
