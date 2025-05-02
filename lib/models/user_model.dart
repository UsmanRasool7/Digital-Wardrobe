class UserModel {
  final String uid;
  final String email;
  final String username;
  final String? bio;
  final String? profileImageUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.bio,
    this.profileImageUrl,
  });

  // Add this copyWith method
  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? bio,
    String? profileImageUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  // Convert UserModel to Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '', // Ensure required fields have fallbacks
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      bio: map['bio'],
      profileImageUrl: map['profileImageUrl'],
    );
  }

  // Optional: Override toString for easier debugging
  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, username: $username, bio: $bio, profileImageUrl: $profileImageUrl)';
  }
}