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

  /// Helper to safely get a String value
  static String? _getString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  /// Helper to safely get an int value
  static int? _getInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  /// Create model from JSON
  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    print('');
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║       PARSING OTP VERIFICATION RESPONSE                    ║');
    print('╚═══════════════════════════════════════════════════════════╝');
    print('📦 Raw JSON keys: ${json.keys.toList()}');
    
    // ✅ Check for nested token object (new API format)
    final tokenMap = json['token'] is Map<String, dynamic> 
        ? json['token'] as Map<String, dynamic> 
        : <String, dynamic>{};
    
    // ✅ Check for nested user object (new API format)
    final userMap = json['user'] is Map<String, dynamic> 
        ? json['user'] as Map<String, dynamic> 
        : <String, dynamic>{};
    
    // ✅ Check for nested data object (old API format)
    final dataMap = json['data'] is Map<String, dynamic> 
        ? json['data'] as Map<String, dynamic> 
        : <String, dynamic>{};
    
    print('📦 Has "token" object: ${json.containsKey("token")}');
    print('📦 Has "user" object: ${json.containsKey("user")}');
    print('📦 Token keys: ${tokenMap.keys.toList()}');
    print('📦 User keys: ${userMap.keys.toList()}');
    
    // Extract access token from multiple possible locations
    final accessToken = _getString(tokenMap['access']) ??  // token.access (new format)
                        _getString(json['access']) ??       // root level
                        _getString(json['access_token']) ?? 
                        _getString(json['token']) ??        // if token is string
                        _getString(dataMap['access']) ?? 
                        _getString(dataMap['access_token']);
    
    // Extract refresh token from multiple possible locations
    final refreshToken = _getString(tokenMap['refresh']) ?? // token.refresh (new format)
                         _getString(json['refresh']) ??      // root level
                         _getString(json['refresh_token']) ?? 
                         _getString(dataMap['refresh']) ?? 
                         _getString(dataMap['refresh_token']);
    
    // Extract user ID from multiple possible locations
    final userId = _getInt(userMap['id']) ??       // user.id (new format)
                   _getInt(json['user_id']) ?? 
                   _getInt(json['id']) ?? 
                   _getInt(dataMap['user_id']) ?? 
                   _getInt(dataMap['id']);
    
    // Extract user name from multiple possible locations
    final userName = _getString(userMap['name']) ??     // user.name (new format)
                     _getString(json['user_name']) ?? 
                     _getString(json['name']) ?? 
                     _getString(json['username']) ?? 
                     _getString(dataMap['user_name']) ?? 
                     _getString(dataMap['name']);
    
    // Extract email from multiple possible locations
    final email = _getString(userMap['email']) ??  // user.email (new format)
                  _getString(json['email']) ?? 
                  _getString(dataMap['email']);
    
    print('');
    print('✅ Parsed Values:');
    print('   accessToken: ${accessToken != null ? "Present (${accessToken.length} chars)" : "NULL ❌"}');
    print('   refreshToken: ${refreshToken != null ? "Present (${refreshToken.length} chars)" : "NULL"}');
    print('   userId: $userId');
    print('   userName: $userName');
    print('   email: $email');
    print('═══════════════════════════════════════════════════════════');
    
    return VerifyOtpResponseModel(
      message: _getString(json['msg'] ?? json['message']) ?? 'OTP verified successfully',
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      userName: userName,
      email: email,
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
