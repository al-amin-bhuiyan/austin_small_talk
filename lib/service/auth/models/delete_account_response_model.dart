class DeleteAccountResponseModel {
  final String message;

  DeleteAccountResponseModel({
    required this.message,
  });

  factory DeleteAccountResponseModel.fromJson(Map<String, dynamic> json) {
    return DeleteAccountResponseModel(
      message: json['msg'] ?? json['message'] ?? 'Account deleted successfully',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': message,
    };
  }
}
