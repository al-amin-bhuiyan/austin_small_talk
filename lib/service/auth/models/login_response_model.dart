/// Login Response Model
class LoginResponseModel {
  final String message;
  final String accessToken;
  final String? refreshToken;
  final int? userId;
  final String? userName;
  final String? email;
  final String? userImage;
  final bool? isAdmin;

  LoginResponseModel({
    required this.message,
    required this.accessToken,
    this.refreshToken,
    this.userId,
    this.userName,
    this.email,
    this.userImage,
    this.isAdmin,
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

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    print('📦 LoginResponseModel.fromJson: ${json.keys.toList()}');
    
    // ✅ Check for nested token object (new API format)
    final tokenMap = json['token'] is Map<String, dynamic> 
        ? json['token'] as Map<String, dynamic> 
        : <String, dynamic>{};
    
    // ✅ Check for nested user object (new API format)
    final userMap = json['user'] is Map<String, dynamic> 
        ? json['user'] as Map<String, dynamic> 
        : <String, dynamic>{};
    
    // Extract access token from multiple possible locations
    final accessToken = _getString(tokenMap['access']) ??  // token.access (new format)
                        _getString(json['access']) ??       // root level
                        _getString(json['access_token']) ?? 
                        _getString(json['token']) ??        // if token is string
                        '';
    
    // Extract refresh token
    final refreshToken = _getString(tokenMap['refresh']) ?? // token.refresh (new format)
                         _getString(json['refresh']) ??      // root level
                         _getString(json['refresh_token']);
    
    // Extract user ID
    final userId = _getInt(userMap['id']) ??       // user.id (new format)
                   _getInt(json['user_id']) ?? 
                   _getInt(json['id']);
    
    // Extract user name
    final userName = _getString(userMap['name']) ??     // user.name (new format)
                     _getString(json['user_name']) ?? 
                     _getString(json['name']) ?? 
                     _getString(json['username']);
    
    // Extract email
    final email = _getString(userMap['email']) ??  // user.email (new format)
                  _getString(json['email']);
    
    // Extract user image
    final userImage = _getString(userMap['image']) ??  // user.image (new format)
                      _getString(json['image']) ??
                      _getString(json['user_image']);
    
    // Extract admin status
    final isAdmin = userMap['is_admin'] as bool? ?? 
                    json['is_admin'] as bool? ?? 
                    false;
    
    print('   accessToken: ${accessToken.isNotEmpty ? "Present (${accessToken.length} chars)" : "EMPTY ❌"}');
    print('   userId: $userId');
    print('   userName: $userName');
    print('   email: $email');
    print('   userImage: $userImage');
    
    return LoginResponseModel(
      message: _getString(json['message'] ?? json['msg']) ?? 'Login successful',
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      userName: userName,
      email: email,
      userImage: userImage,
      isAdmin: isAdmin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user_id': userId,
      'user_name': userName,
      'email': email,
      'user_image': userImage,
      'is_admin': isAdmin,
    };
  }
}
