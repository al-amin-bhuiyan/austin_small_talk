/// Reset Password OTP Request Model
class ResetPasswordOtpRequestModel {
  final String email;
  final String otp;

  ResetPasswordOtpRequestModel({
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}
