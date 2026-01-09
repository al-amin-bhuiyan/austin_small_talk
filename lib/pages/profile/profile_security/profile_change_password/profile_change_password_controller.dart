import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/custom_snackbar/custom_snackbar.dart';
import '../../../../service/auth/api_service/api_services.dart';
import '../../../../service/auth/models/change_password_request_model.dart';
import '../../../../data/global/shared_preference.dart';

class ProfileChangePasswordController extends GetxController {
  // API Service
  final ApiServices _apiServices = ApiServices();

  // Text editing controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Password visibility toggles
  final RxBool isCurrentPasswordObscured = true.obs;
  final RxBool isNewPasswordObscured = true.obs;
  final RxBool isConfirmPasswordObscured = true.obs;
  
  // Loading state
  final RxBool isLoading = false.obs;

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
  void changePassword(BuildContext context) async {
    print('🔹 Change Password button clicked');
    print('✅ Context received, proceeding with validation');

    // Validate current password
    if (currentPasswordController.text.isEmpty) {
      print('❌ Validation failed: Current password is empty');
      CustomSnackbar.error(
        context: context,
        title: 'Error',
        message: 'Please enter your current password',
      );
      return;
    }
    print('✅ Current password validated');

    // Validate new password
    if (newPasswordController.text.isEmpty) {
      print('❌ Validation failed: New password is empty');
      CustomSnackbar.error(
        context: context,
        title: 'Error',
        message: 'Please enter a new password',
      );
      return;
    }
    print('✅ New password validated');

    // Validate password length
    if (newPasswordController.text.length < 6) {
      print('❌ Validation failed: Password too short');
      CustomSnackbar.error(
        context: context,
        title: 'Error',
        message: 'Password must be at least 6 characters',
      );
      return;
    }
    print('✅ Password length validated');

    // Validate confirm password
    if (confirmPasswordController.text.isEmpty) {
      print('❌ Validation failed: Confirm password is empty');
      CustomSnackbar.error(
        context: context,
        title: 'Error',
        message: 'Please confirm your password',
      );
      return;
    }
    print('✅ Confirm password validated');

    // Check if passwords match
    if (newPasswordController.text != confirmPasswordController.text) {
      print('❌ Validation failed: Passwords do not match');
      CustomSnackbar.error(
        context: context,
        title: 'Error',
        message: 'Passwords do not match',
      );
      return;
    }
    print('✅ Passwords match');

    // Check if new password is different from current
    if (currentPasswordController.text == newPasswordController.text) {
      print('❌ Validation failed: New password same as current');
      CustomSnackbar.error(
        context: context,
        title: 'Error',
        message: 'New password must be different from current password',
      );
      return;
    }
    print('✅ New password is different from current');

    try {
      print('📡 Getting access token...');
      // Get access token from shared preferences
      final accessToken = SharedPreferencesUtil.getAccessToken();
      
      if (accessToken == null || accessToken.isEmpty) {
        print('❌ No access token found');
        CustomSnackbar.error(
          context: context,
          title: 'Error',
          message: 'Session expired. Please login again',
        );
        Get.offAllNamed('/login');
        return;
      }
      print('✅ Access token found: ${accessToken.substring(0, 20)}...');

      // Set loading state
      print('🔄 Setting loading state...');
      isLoading.value = true;

      // Create request model
      print('📦 Creating request model...');
      final request = ChangePasswordRequestModel(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
        confirmNewPassword: confirmPasswordController.text,
      );
      print('✅ Request model created');

      // Call API
      print('🌐 Calling API...');
      final response = await _apiServices.changePassword(request, accessToken);
      print('✅ API response received: ${response.message}');

      // Hide loading
      isLoading.value = false;
      print('✅ Loading state cleared');

      // Show success message
      print('🎉 Showing success message...');
      CustomSnackbar.success(
        context: context,
        title: 'Success',
        message: response.message,
      );
      
      // Clear fields
      print('🧹 Clearing fields...');
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      
      // Go back after a short delay
      print('⏰ Waiting before navigation...');
      await Future.delayed(const Duration(milliseconds: 500));
      print('🔙 Navigating back...');
      Get.back();
      
    } catch (e) {
      print('❌ Exception caught: $e');
      // Hide loading
      isLoading.value = false;
      print('✅ Loading state cleared after error');
      
      // Extract error message
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      print('📝 Error message: $errorMessage');
      
      // Show error message
      print('⚠️ Showing error message...');
      CustomSnackbar.error(
        context: context,
        title: 'Error',
        message: errorMessage,
      );
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
