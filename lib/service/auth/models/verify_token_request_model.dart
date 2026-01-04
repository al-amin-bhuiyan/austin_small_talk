/// Verify Token Request Model
class VerifyTokenRequestModel {
  final String token;

  VerifyTokenRequestModel({
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}
