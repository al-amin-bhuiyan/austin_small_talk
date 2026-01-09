/// Change Password Request Model
class ChangePasswordRequestModel {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  ChangePasswordRequestModel({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
      'confirm_new_password': confirmNewPassword,
    };
  }
}
