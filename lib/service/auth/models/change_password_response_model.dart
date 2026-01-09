/// Change Password Response Model
class ChangePasswordResponseModel {
  final String message;
  final bool success;

  ChangePasswordResponseModel({
    required this.message,
    required this.success,
  });

  factory ChangePasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponseModel(
      message: json['message'] ?? json['msg'] ?? json['detail'] ?? 'Password changed successfully',
      success: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
    };
  }
}
