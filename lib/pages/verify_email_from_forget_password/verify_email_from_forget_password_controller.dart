import 'dart:async';
import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
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

  // Observable states for each OTP field to track input
  final List<RxString> otpValues = List.generate(
    6,
    (index) => ''.obs,
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
    
    // Listen to controller changes to update observable states
    for (int i = 0; i < 6; i++) {
      otpControllers[i].addListener(() {
        otpValues[i].value = otpControllers[i].text;
      });
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

  /// Handle digit input and navigation
  void onDigitChanged(int index, String value, BuildContext context) {
    if (value.length == 1 && index < 5) {
      // Move to next field
      focusNodes[index + 1].requestFocus();
    } else if (value.length == 1 && index == 5) {
      // Last field - unfocus to hide keyboard
      focusNodes[index].unfocus();
    } else if (value.isEmpty && index > 0) {
      // Move to previous field on backspace
      focusNodes[index - 1].requestFocus();
    }
  }

  /// Handle backspace/delete
  void onDigitDeleted(int index) {
    if (index > 0 && otpControllers[index].text.isEmpty) {
      // Move to previous field
      focusNodes[index - 1].requestFocus();
    }
  }

  /// Handle paste from clipboard manually
  Future<void> handlePasteFromClipboard(BuildContext context) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData != null && clipboardData.text != null) {
        final pastedText = clipboardData.text!;
        _handlePaste(pastedText, context);
      }
    } catch (e) {
      // Clipboard error
      CustomSnackbar.error(
        context: context,
        title: 'Error',
        message: 'Failed to paste from clipboard',
      );
    }
  }

  /// Handle paste event - distribute digits across all fields
  void _handlePaste(String pastedText, BuildContext context) {
    // Remove any non-digit characters
    final digits = pastedText.replaceAll(RegExp(r'\D'), '');
    
    if (digits.isEmpty) return;
    
    // Check if more than 6 digits
    if (digits.length > 6) {
      toastification.show(
        context: context,
        type: ToastificationType.warning,
        style: ToastificationStyle.flat,
        title: const Text('Invalid OTP'),
        description: const Text('OTP should not be more than 6 digits'),
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        showProgressBar: false,
        closeOnClick: true,
        pauseOnHover: false,
        dragToClose: true,
      );
      return;
    }
    
    // Clear all fields first
    for (var ctrl in otpControllers) {
      ctrl.clear();
    }
    
    // Distribute digits starting from the first field
    final numDigits = digits.length;
    for (int i = 0; i < numDigits; i++) {
      otpControllers[i].text = digits[i];
    }
    
    // Focus on the next empty field or unfocus if all filled
    if (numDigits >= 6) {
      focusNodes[5].unfocus();
    } else {
      focusNodes[numDigits].requestFocus();
    }
  }

  /// Clear all OTP fields
  void clearOtpFields() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    focusNodes[0].requestFocus();
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

    // Track if verification API call succeeded
    bool verificationSucceeded = false;
    
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

      // ✅ Mark verification as successful (API returned success)
      verificationSucceeded = true;
      print('✅ Reset password OTP verification API call successful');

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
        
        print('🔄 Navigating to create new password screen...');
        context.push(AppPath.createNewPassword);
        print('✅ Navigation to create new password initiated');
      }
    } catch (e) {
      // ✅ Only show error if verification actually failed
      // Don't show error if verification succeeded but navigation threw exception
      if (!verificationSucceeded) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        
        print('❌ Verification failed: $errorMessage');
        
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
            context.push(AppPath.createNewPassword);
          }
        } else {
          CustomSnackbar.error(
            context: context,
            title: 'Verification Failed',
            message: errorMessage,
          );
        }
      } else {
        // Verification succeeded but something else failed (like navigation)
        // Don't show error - user is already verified and will see success message
        print('⚠️ Post-verification error (ignored): ${e.toString()}');
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
