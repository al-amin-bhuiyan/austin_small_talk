/// OTP Verification Response Model
class VerifyOtpResponseModel {
  final String message;
  final String? accessToken;
  final String? refreshToken;
  final int? userId;
  final String? userName;
  final String? email;
  final dynamic data; // Keep for any additional data

  VerifyOtpResponseModel({
    required this.message,
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.userName,
    this.email,
    this.data,
  });

  /// Create model from JSON
  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    // Try to extract tokens from root level or data field
    final dataMap = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : <String, dynamic>{};
    
    return VerifyOtpResponseModel(
      message: json['msg'] ?? json['message'] ?? 'OTP verified successfully',
      // Check both root level and data field for tokens
      accessToken: json['access'] ?? json['access_token'] ?? json['token'] ?? 
                   dataMap['access'] ?? dataMap['access_token'] ?? dataMap['token'],
      refreshToken: json['refresh'] ?? json['refresh_token'] ?? 
                    dataMap['refresh'] ?? dataMap['refresh_token'],
      userId: json['user_id'] ?? json['id'] ?? 
              dataMap['user_id'] ?? dataMap['id'],
      userName: json['user_name'] ?? json['name'] ?? json['username'] ?? 
                dataMap['user_name'] ?? dataMap['name'] ?? dataMap['username'],
      email: json['email'] ?? dataMap['email'],
      data: json['data'],
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user_id': userId,
      'user_name': userName,
      'email': email,
      'data': data,
    };
  }
}
