/// Set New Password Request Model
class SetNewPasswordRequestModel {
  final String resetToken;
  final String newPassword;
  final String newPassword2;

  SetNewPasswordRequestModel({
    required this.resetToken,
    required this.newPassword,
    required this.newPassword2,
  });

  Map<String, dynamic> toJson() {
    return {
      'reset_token': resetToken,
      'new_password': newPassword,
      'new_password2': newPassword2,
    };
  }
}
