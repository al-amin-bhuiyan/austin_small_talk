import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_route/app_path.dart';
import '../../service/auth/api_service/api_services.dart';
import '../../service/auth/models/set_new_password_request_model.dart';
import '../../utils/custom_snackbar/custom_snackbar.dart';

/// Controller for CreateNewPasswordScreen - handles password creation logic
class CreateNewPasswordController extends GetxController {
  // Text editing controllers
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool acceptTerms = false.obs;
  final RxString resetToken = ''.obs; // Reset token from OTP verification
  final RxString email = ''.obs; // Email for reference

  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // API Service
  final ApiServices _apiServices = ApiServices();

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// Toggle terms acceptance
  void toggleTerms() {
    acceptTerms.value = !acceptTerms.value;
  }

  /// Validate new password
  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Validate confirm password
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Handle forget password button press
  Future<void> onForgetPasswordPressed(BuildContext context) async {
    if (!acceptTerms.value) {
      CustomSnackbar.warning(
        context: context,
        title: 'Terms Required',
        message: 'Please agree to Small Talk Terms of Use and Privacy Policy',
      );
      return;
    }

    if (formKey.currentState?.validate() ?? false) {
      // Check if reset token is available
      if (resetToken.value.isEmpty) {
        CustomSnackbar.error(
          context: context,
          title: 'Error',
          message: 'Reset token is missing. Please restart the password reset process.',
        );
        return;
      }

      try {
        isLoading.value = true;

        // Create set new password request
        final request = SetNewPasswordRequestModel(
          resetToken: resetToken.value,
          newPassword: newPasswordController.text,
          newPassword2: confirmPasswordController.text,
        );

        // Call API to set new password
        final response = await _apiServices.setNewPassword(request);

        if (context.mounted) {
          CustomSnackbar.success(
            context: context,
            title: 'Success',
            message: response.message,
          );
        }

        // Clear password fields
        newPasswordController.clear();
        confirmPasswordController.clear();
        acceptTerms.value = false;

        // Navigate to verified screen
        await Future.delayed(const Duration(milliseconds: 500));
        if (context.mounted) {
          context.go(AppPath.verifiedfromcreatenewpassword);
        }
      } catch (e) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        
        if (!context.mounted) return;
        
        // Check specific error types
        if (errorMessage.toLowerCase().contains('invalid') && 
            errorMessage.toLowerCase().contains('reset token')) {
          CustomSnackbar.error(
            context: context,
            title: 'Invalid Reset Token',
            message: 'Your reset token is invalid or has expired. Please restart the password reset process.',
          );
        } else if (errorMessage.toLowerCase().contains('password') && 
                   errorMessage.toLowerCase().contains('match')) {
          CustomSnackbar.error(
            context: context,
            title: 'Password Mismatch',
            message: 'The passwords you entered do not match.',
          );
        } else {
          CustomSnackbar.error(
            context: context,
            title: 'Failed',
            message: errorMessage,
          );
        }
      } finally {
        isLoading.value = false;
      }
    }
  }

  /// Navigate to Terms of Use
  void onTermsPressed(BuildContext context) {
    context.go(AppPath.termsAndConditions);
  }

  /// Navigate to Privacy Policy
  void onPrivacyPolicyPressed(BuildContext context) {
    context.go(AppPath.privacyPolicy);
  }

  /// Navigate to Small Talk Support
  void onSupportPressed(BuildContext context) {
   context.go(AppPath.supportandhelp);
  }
}
