/// Login Response Model
class LoginResponseModel {
  final String message;
  final String accessToken;
  final String? refreshToken;
  final int? userId;
  final String? userName;
  final String? email;

  LoginResponseModel({
    required this.message,
    required this.accessToken,
    this.refreshToken,
    this.userId,
    this.userName,
    this.email,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      message: json['message'] ?? json['msg'] ?? 'Login successful',
      accessToken: json['access'] ?? json['access_token'] ?? json['token'] ?? '',
      refreshToken: json['refresh'] ?? json['refresh_token'],
      userId: json['user_id'] ?? json['id'],
      userName: json['user_name'] ?? json['name'] ?? json['username'],
      email: json['email'],
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
    };
  }
}
