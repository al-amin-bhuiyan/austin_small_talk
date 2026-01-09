/// Forgot Password Response Model
class ForgotPasswordResponseModel {
  final String message;
  final String? email;

  ForgotPasswordResponseModel({
    required this.message,
    this.email,
  });

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponseModel(
      message: json['msg'] ?? json['message'] ?? 'Password reset OTP sent. Please check your email',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': message,
      'email': email,
    };
  }
}
