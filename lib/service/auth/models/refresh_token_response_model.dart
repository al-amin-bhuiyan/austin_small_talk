/// Refresh Token Response Model
class RefreshTokenResponseModel {
  final String accessToken;
  final String? refreshToken;

  RefreshTokenResponseModel({
    required this.accessToken,
    this.refreshToken,
  });

  factory RefreshTokenResponseModel.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponseModel(
      accessToken: json['access'] ?? json['access_token'] ?? json['token'] ?? '',
      refreshToken: json['refresh'] ?? json['refresh_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': accessToken,
      'refresh': refreshToken,
    };
  }
}
