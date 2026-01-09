/// Set New Password Response Model
class SetNewPasswordResponseModel {
  final String message;

  SetNewPasswordResponseModel({
    required this.message,
  });

  factory SetNewPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return SetNewPasswordResponseModel(
      message: json['message'] ?? json['msg'] ?? 'Password reset successfully',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}
