import 'dart:async';
import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../service/auth/api_service/api_services.dart';
import '../../service/auth/models/reset_password_otp_request_model.dart';
import '../../service/auth/models/resend_otp_request_model.dart';
import '../../utils/custom_snackbar/custom_snackbar.dart';
import '../create_new_password/create_new_password_controller.dart';

/// Controller for VerifyEmailFromForgetPasswordScreen - handles OTP verification for forgot password flow
class VerifyEmailFromForgetPasswordController extends GetxController {
  // Text editing controllers for 6 OTP digits
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  // Focus nodes for each OTP field
  final List<FocusNode> focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  // Observable states
  final RxBool isLoading = false.obs;
  final RxString email = ''.obs;
  final RxString resetToken = ''.obs; // Store reset token after OTP verification
  
  // Resend OTP timer
  final RxInt resendTimer = 60.obs;
  final RxBool isResending = false.obs;
  Timer? _timer;

  // API Service
  final ApiServices _apiServices = ApiServices();

  @override
  void onInit() {
    super.onInit();
    // Email should be set from forgot password controller
    if (email.value.isEmpty) {
      email.value = 'name@company.com'; // Default placeholder
    }
  }

  @override
  void onClose() {
    // Dispose timer
    _timer?.cancel();
    // Dispose all controllers and focus nodes
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }

  /// Get the complete OTP code
  String getOtpCode() {
    return otpControllers.map((controller) => controller.text).join();
  }

  /// Check if OTP is complete (all 6 digits filled)
  bool isOtpComplete() {
    return getOtpCode().length == 6;
  }

  /// Handle digit input
  void onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      // Move to next field if not the last one
      if (index < 5) {
        focusNodes[index + 1].requestFocus();
      } else {
        // Last field - unfocus to hide keyboard
        focusNodes[index].unfocus();
      }
    }
  }

  /// Handle backspace/delete
  void onDigitDeleted(int index) {
    if (index > 0 && otpControllers[index].text.isEmpty) {
      // Move to previous field
      focusNodes[index - 1].requestFocus();
    }
  }

  /// Handle verify button press - FORGOT PASSWORD FLOW
  Future<void> onVerifyPressed(BuildContext context) async {
    // Validate OTP is complete
    if (!isOtpComplete()) {
      CustomSnackbar.warning(
        context: context,
        title: 'Incomplete Code',
        message: 'Please enter all 6 digits',
      );
      return;
    }

    // Validate email is set
    if (email.value.isEmpty || !GetUtils.isEmail(email.value)) {
      CustomSnackbar.error(
        context: context,
        title: 'Invalid Email',
        message: 'Email address is not valid. Please restart the process.',
      );
      return;
    }

    try {
      isLoading.value = true;

      String otpCode = getOtpCode();

      // Create reset password OTP request
      final request = ResetPasswordOtpRequestModel(
        email: email.value,
        otp: otpCode,
      );

      // Call reset password OTP API (different from signup verify OTP)
      final response = await _apiServices.resetPasswordOtp(request);

      // Store reset token for later use
      if (response.resetToken != null && response.resetToken!.isNotEmpty) {
        resetToken.value = response.resetToken!;
      }

      // Show success message
      if (context.mounted) {
        CustomSnackbar.success(
          context: context,
          title: 'Success',
          message: response.message,
        );
      }

      // Small delay to show success message
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to Create New Password (FORGOT PASSWORD FLOW)
      if (context.mounted) {
        // Pass reset token to CreateNewPasswordController
        final createPasswordController = Get.find<CreateNewPasswordController>();
        createPasswordController.resetToken.value = resetToken.value;
        createPasswordController.email.value = email.value;
        
        context.go(AppPath.createNewPassword);
      }
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      if (!context.mounted) return;
      
      // Check specific error types
      if (errorMessage.toLowerCase().contains('invalid') && 
          errorMessage.toLowerCase().contains('otp')) {
        CustomSnackbar.error(
          context: context,
          title: 'Invalid OTP',
          message: 'The code you entered is incorrect. Please try again.',
        );
      } else if (errorMessage.toLowerCase().contains('expired') && 
                 errorMessage.toLowerCase().contains('otp')) {
        CustomSnackbar.error(
          context: context,
          title: 'OTP Expired',
          message: 'The verification code has expired. Please request a new one.',
        );
      } else if ((errorMessage.toLowerCase().contains('already') && 
                  errorMessage.toLowerCase().contains('verified')) ||
                 (errorMessage.toLowerCase().contains('already') && 
                  errorMessage.toLowerCase().contains('activated'))) {
        // For forgot password flow, if account is already verified/activated,
        // allow user to proceed to reset password
        CustomSnackbar.success(
          context: context,
          title: 'Success',
          message: 'You can now reset your password.',
        );
        
        await Future.delayed(const Duration(milliseconds: 500));
        if (context.mounted) {
          context.go(AppPath.createNewPassword);
        }
      } else {
        CustomSnackbar.error(
          context: context,
          title: 'Verification Failed',
          message: errorMessage,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend verification code
  Future<void> onResendCode(BuildContext context) async {
    if (isResending.value) return;
    
    // Validate email before resending
    if (email.value.isEmpty || !GetUtils.isEmail(email.value)) {
      CustomSnackbar.error(
        context: context,
        title: 'Invalid Email',
        message: 'Email address is not valid.',
      );
      return;
    }
    
    try {
      // Start countdown immediately
      _startResendTimer();
      
      // Create resend OTP request
      final request = ResendOtpRequestModel(
        email: email.value,
      );
      
      // Call API
      final response = await _apiServices.resendOtp(request);

      if (context.mounted) {
        CustomSnackbar.success(
          context: context,
          title: 'OTP Sent',
          message: response.message,
        );
      }
      
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      if (!context.mounted) return;
      
      // Check specific error types
      if ((errorMessage.toLowerCase().contains('already activated') || 
           errorMessage.toLowerCase().contains('already verified'))) {
        // For forgot password, this is OK - account should be activated
        // Still send OTP for password reset
        CustomSnackbar.success(
          context: context,
          title: 'OTP Sent',
          message: 'Password reset code sent to your email.',
        );
      } else if (errorMessage.toLowerCase().contains('not found') || 
                 errorMessage.toLowerCase().contains('does not exist')) {
        CustomSnackbar.error(
          context: context,
          title: 'Email Not Found',
          message: 'No account found with this email address.',
        );
        
        // Stop timer if there's an error
        _timer?.cancel();
        isResending.value = false;
      } else {
        CustomSnackbar.error(
          context: context,
          title: 'Failed to Resend',
          message: errorMessage.isEmpty ? 'Could not send OTP. Please try again.' : errorMessage,
        );
        
        // Stop timer if there's an error
        _timer?.cancel();
        isResending.value = false;
      }
    }
  }
  
  /// Start countdown timer
  void _startResendTimer() {
    isResending.value = true;
    resendTimer.value = 60;
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        isResending.value = false;
        timer.cancel();
      }
    });
  }
}
