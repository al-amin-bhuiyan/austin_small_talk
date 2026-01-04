/// Resend OTP Request Model
class ResendOtpRequestModel {
  final String email;

  ResendOtpRequestModel({
    required this.email,
  });

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }

  /// Create model from JSON
  factory ResendOtpRequestModel.fromJson(Map<String, dynamic> json) {
    return ResendOtpRequestModel(
      email: json['email'] ?? '',
    );
  }
}
