/// Register Request Model
class RegisterRequestModel {
  final String email;
  final String name;
  final String password;
  final String password2;
  final String voice;
  final String dateOfBirth;

  RegisterRequestModel({
    required this.email,
    required this.name,
    required this.password,
    required this.password2,
    required this.voice,
    required this.dateOfBirth,
  });

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'password': password,
      'password2': password2,
      'voice': voice,
      'date_of_birth': dateOfBirth,
    };
  }

  /// Create model from JSON
  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) {
    return RegisterRequestModel(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      password: json['password'] ?? '',
      password2: json['password2'] ?? '',
      voice: json['voice'] ?? 'male',
      dateOfBirth: json['date_of_birth'] ?? '',
    );
  }
}
