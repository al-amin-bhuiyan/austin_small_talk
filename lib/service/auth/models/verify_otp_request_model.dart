/// OTP Verification Request Model
class VerifyOtpRequestModel {
  final String email;
  final String otp;

  VerifyOtpRequestModel({
    required this.email,
    required this.otp,
  });

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }

  /// Create model from JSON
  factory VerifyOtpRequestModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpRequestModel(
      email: json['email'] ?? '',
      otp: json['otp'] ?? '',
    );
  }
}
