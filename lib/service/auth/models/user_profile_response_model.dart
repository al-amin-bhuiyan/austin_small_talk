/// User Profile Response Model
class UserProfileResponseModel {
  final int id;
  final String email;
  final String name;
  final bool isAdmin;
  final String? image;
  final String? voice;
  final String? dateOfBirth;

  UserProfileResponseModel({
    required this.id,
    required this.email,
    required this.name,
    required this.isAdmin,
    this.image,
    this.voice,
    this.dateOfBirth,
  });

  /// Create model from JSON
  factory UserProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return UserProfileResponseModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      isAdmin: json['is_admin'] ?? false,
      image: json['image'],
      voice: json['voice'],
      dateOfBirth: json['date_of_birth'],
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'is_admin': isAdmin,
      'image': image,
      'voice': voice,
      'date_of_birth': dateOfBirth,
    };
  }

  /// Get full image URL
  String? getFullImageUrl(String baseUrl) {
    if (image == null || image!.isEmpty) return null;
    if (image!.startsWith('http')) return image;
    
    // Remove leading slash from image path if baseUrl has trailing slash
    String imagePath = image!;
    if (baseUrl.endsWith('/') && imagePath.startsWith('/')) {
      imagePath = imagePath.substring(1);
    }
    
    return baseUrl + imagePath;
  }
}
