/// Reset Password OTP Response Model
class ResetPasswordOtpResponseModel {
  final String message;
  final String? resetToken;

  ResetPasswordOtpResponseModel({
    required this.message,
    this.resetToken,
  });

  factory ResetPasswordOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordOtpResponseModel(
      message: json['message'] ?? json['msg'] ?? 'OTP verified successfully',
      resetToken: json['reset_token'] ?? json['resetToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'reset_token': resetToken,
    };
  }
}
