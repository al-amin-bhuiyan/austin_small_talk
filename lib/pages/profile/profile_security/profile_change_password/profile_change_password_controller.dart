import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/toast_message/toast_message.dart';

class ProfileChangePasswordController extends GetxController {
  // Text editing controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Password visibility toggles
  final RxBool isCurrentPasswordObscured = true.obs;
  final RxBool isNewPasswordObscured = true.obs;
  final RxBool isConfirmPasswordObscured = true.obs;

  /// Toggle current password visibility with animation
  void toggleCurrentPassword() {
    isCurrentPasswordObscured.value = !isCurrentPasswordObscured.value;
  }

  /// Toggle new password visibility with animation
  void toggleNewPassword() {
    isNewPasswordObscured.value = !isNewPasswordObscured.value;
  }

  /// Toggle confirm password visibility with animation
  void toggleConfirmPassword() {
    isConfirmPasswordObscured.value = !isConfirmPasswordObscured.value;
  }

  /// Validate and change password
  void changePassword() async {
    // Validate current password
    await Future.delayed(const Duration(seconds: 2));

    if (currentPasswordController.text.isEmpty) {
      ToastMessage.error('Please enter your current password', title: 'Error');
      return;
    }

    // Validate new password
    if (newPasswordController.text.isEmpty) {
      ToastMessage.error('Please enter a new password', title: 'Error');
      return;
    }

    // Validate password length
    if (newPasswordController.text.length < 6) {
      ToastMessage.error('Password must be at least 6 characters', title: 'Error');
      return;
    }

    // Validate confirm password
    if (confirmPasswordController.text.isEmpty) {
      ToastMessage.error('Please confirm your password', title: 'Error');
      return;
    }

    // Check if passwords match
    if (newPasswordController.text != confirmPasswordController.text) {
      ToastMessage.error('Passwords do not match', title: 'Error');
      return;
    }

    // Check if new password is different from current
    if (currentPasswordController.text == newPasswordController.text) {
      ToastMessage.error('New password must be different from current password', title: 'Error');
      return;
    }

    // TODO: Add your password change API call here
    // Example:
    // final result = await authService.changePassword(
    //   currentPassword: currentPasswordController.text,
    //   newPassword: newPasswordController.text,
    // );

    // Show success message
    ToastMessage.success('Password changed successfully', title: 'Success');
    
    // Go back
    Get.back();
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
