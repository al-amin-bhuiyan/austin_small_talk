/// Register Response Model
class RegisterResponseModel {
  final String message;
  final String email;
  final int expiresInMinutes;

  RegisterResponseModel({
    required this.message,
    required this.email,
    required this.expiresInMinutes,
  });

  /// Create model from JSON
  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      message: json['msg'] ?? 'Registration successful',
      email: json['email'] ?? '',
      expiresInMinutes: json['expires_in_minutes'] ?? 15,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'msg': message,
      'email': email,
      'expires_in_minutes': expiresInMinutes,
    };
  }
}
