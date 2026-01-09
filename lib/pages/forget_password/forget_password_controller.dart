import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:austin_small_talk/utils/custom_snackbar/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../service/auth/api_service/api_services.dart';
import '../../service/auth/models/forgot_password_request_model.dart';
import '../verify_email_from_forget_password/verify_email_from_forget_password_controller.dart';

/// Controller for ForgetPasswordScreen - handles password reset logic
class ForgetPasswordController extends GetxController {
  // Text editing controller
  final TextEditingController emailController = TextEditingController();
  
  // Flag for routing (true = forgot password flow)
  var flag = true;

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool acceptTerms = false.obs;

  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // API service
  final ApiServices _apiServices = ApiServices();

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
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Handle forget password button press
  Future<void> onForgetPasswordPressed(BuildContext context) async {
    // Check if terms are accepted
    if (!acceptTerms.value) {
      CustomSnackbar.warning(
        context: context,
        title: "Warning",
        message: "You have to agree with Terms and Condition",
      );
      return;
    }

    // Validate form
    if (formKey.currentState?.validate() ?? false) {
      try {
        isLoading.value = true;

        // Create forgot password request
        final request = ForgotPasswordRequestModel(
          email: emailController.text.trim(),
        );

        // Call API to send reset password email
        final response = await _apiServices.sendResetPasswordEmail(request);

        if (context.mounted) {
          CustomSnackbar.success(
            context: context,
            title: 'Success',
            message: response.message,
          );
        }

        // Get VerifyEmailFromForgetPasswordController and set email
        final verifyController = Get.find<VerifyEmailFromForgetPasswordController>();
        verifyController.email.value = emailController.text.trim();

        // Navigate to verify email from forget password screen
        if (context.mounted) {
          context.push(AppPath.verifyEmailFromForgetPassword);
        }
      } catch (e) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        
        if (!context.mounted) return;
        
        // Check if email doesn't exist
        if (errorMessage.toLowerCase().contains('not found') || 
            errorMessage.toLowerCase().contains('does not exist')) {
          CustomSnackbar.error(
            context: context,
            title: 'Email Not Found',
            message: errorMessage,
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
    context.push(AppPath.termsAndConditions);
  }

  /// Navigate to Privacy Policy
  void onPrivacyPolicyPressed(BuildContext context) {
    context.push(AppPath.privacyPolicy);
  }

  /// Navigate to Account Recovery
  void onAccountRecoveryPressed() {
    // TODO: Implement account recovery flow
  }
}
