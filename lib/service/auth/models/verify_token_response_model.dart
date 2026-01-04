/// Verify Token Response Model
class VerifyTokenResponseModel {
  final bool isValid;
  final String? message;

  VerifyTokenResponseModel({
    required this.isValid,
    this.message,
  });

  factory VerifyTokenResponseModel.fromJson(Map<String, dynamic> json) {
    // If the response doesn't contain an error, the token is valid
    return VerifyTokenResponseModel(
      isValid: true,
      message: json['message'] ?? json['msg'] ?? 'Token is valid',
    );
  }

  factory VerifyTokenResponseModel.invalid(String message) {
    return VerifyTokenResponseModel(
      isValid: false,
      message: message,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_valid': isValid,
      'message': message,
    };
  }
}
