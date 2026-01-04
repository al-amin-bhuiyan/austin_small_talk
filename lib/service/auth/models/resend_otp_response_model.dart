/// Resend OTP Response Model
class ResendOtpResponseModel {
  final String message;
  final dynamic data;

  ResendOtpResponseModel({
    required this.message,
    this.data,
  });

  /// Create model from JSON
  factory ResendOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return ResendOtpResponseModel(
      message: json['msg'] ?? json['message'] ?? 'OTP sent successfully',
      data: json['data'],
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data,
    };
  }
}
