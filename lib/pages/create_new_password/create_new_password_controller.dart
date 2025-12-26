import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_route/app_path.dart';
import '../../utils/toast_message/toast_message.dart';

/// Controller for CreateNewPasswordScreen - handles password creation logic
class CreateNewPasswordController extends GetxController {
  // Text editing controllers
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool acceptTerms = false.obs;

  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
      ToastMessage.error(
        'Please agree to Small Talk Terms of Use and Privacy Policy',
        title: 'Terms Required',
      );
      return;
    }

    if (formKey.currentState?.validate() ?? false) {
      try {
        isLoading.value = true;

        // TODO: Implement your create new password API call here
        await Future.delayed(const Duration(seconds: 2));
        // Simulating API call

        ToastMessage.success(
          'Password has been reset successfully',
          duration: const Duration(seconds: 2),
        );

        // Navigate to verified screen
        await Future.delayed(const Duration(milliseconds: 500));
        context.go(AppPath.verifiedfromcreatenewpassword);
      } catch (e) {
        ToastMessage.error(
          'Failed to reset password: ${e.toString()}',
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  /// Navigate to Terms of Use
  void onTermsPressed() {
    ToastMessage.info(
      'Terms of Use page coming soon',
    );
  }

  /// Navigate to Privacy Policy
  void onPrivacyPolicyPressed() {
    ToastMessage.info(
      'Privacy Policy page coming soon',
    );
  }

  /// Navigate to Small Talk Support
  void onSupportPressed() {
    ToastMessage.info(
      'Support page coming soon',
    );
  }
}
