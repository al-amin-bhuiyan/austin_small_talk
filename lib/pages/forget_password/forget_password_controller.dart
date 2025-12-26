import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../utils/toast_message/toast_message.dart';

/// Controller for ForgetPasswordScreen - handles password reset logic
class ForgetPasswordController extends GetxController {
  // Text editing controller
  final TextEditingController emailController = TextEditingController();
  var flag=true;

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool acceptTerms = false.obs;

  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  /// Toggle terms acceptance
  void toggleTerms() {
    acceptTerms.value = !acceptTerms.value;
  }

  /// Validate email
  String? validateEmail(String? value) {
    // if (value == null || value.isEmpty) {
    //   return 'Email is required';
    // }
    // if (!GetUtils.isEmail(value)) {
    //   return 'Please enter a valid email';
    // }
    return null;
  }

  /// Handle forget password button press
  Future<void> onForgetPasswordPressed(BuildContext context) async {
    if (!acceptTerms.value) {
      ToastMessage.error(
        'Please agree to Small Talk Terms of Use and Privacy Policy',
        title: 'Terms Required',
      );
    }
    else{
      context.push('${AppPath.verifyEmail}?flag=true');
      //context.push('${AppPath.verifyEmail}?flag=true');

    }

    if (formKey.currentState?.validate() ?? false) {
      try {
        isLoading.value = true;

        // TODO: Implement your password reset API call here
        await Future.delayed(const Duration(seconds: 2));
        // Simulating API call

        ToastMessage.success(
          'Password reset instructions sent to ${emailController.text}',
          duration: const Duration(seconds: 3),
        );

        // Clear email field after success
        emailController.clear();
        acceptTerms.value = false;
      } catch (e) {
        ToastMessage.error(
          'Failed to send reset instructions: ${e.toString()}',
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

  /// Navigate to Account Recovery
  void onAccountRecoveryPressed() {
    ToastMessage.info(
      'Account Recovery page coming soon',
    );
  }
}
