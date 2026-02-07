/// Reset Password OTP Response Model
class ResetPasswordOtpResponseModel {
  final String message;
  final String? resetToken;

  ResetPasswordOtpResponseModel({
    required this.message,
    this.resetToken,
  });

  /// Helper to safely get a String value
  static String? _getString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  factory ResetPasswordOtpResponseModel.fromJson(Map<String, dynamic> json) {
    print('📦 ResetPasswordOtpResponseModel.fromJson:');
    print('   Raw JSON keys: ${json.keys.toList()}');
    
    return ResetPasswordOtpResponseModel(
      message: _getString(json['message'] ?? json['msg']) ?? 'OTP verified successfully',
      resetToken: _getString(json['reset_token']) ?? _getString(json['resetToken']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'reset_token': resetToken,
    };
  }
}
