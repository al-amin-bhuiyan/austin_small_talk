/// OTP Verification Response Model
class VerifyOtpResponseModel {
  final String message;
  final dynamic data;

  VerifyOtpResponseModel({
    required this.message,
    this.data,
  });

  /// Create model from JSON
  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(
      message: json['msg'] ?? json['message'] ?? 'OTP verified successfully',
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
