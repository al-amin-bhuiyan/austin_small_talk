import 'dart:async';
import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../service/auth/api_service/api_services.dart';
import '../../service/auth/models/verify_otp_request_model.dart';
import '../../service/auth/models/resend_otp_request_model.dart';
import '../../utils/custom_snackbar/custom_snackbar.dart';
import '../../data/global/shared_preference.dart';

/// Controller for VerifyEmailScreen - handles email verification logic
class VerifyEmailController extends GetxController {
  // Text editing controllers for 6 OTP digits
  final RxBool flag = false.obs;
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
  
  // Resend OTP timer
  final RxInt resendTimer = 60.obs;
  final RxBool isResending = false.obs; // true when counting down
  Timer? _timer;

  // API Service
  final ApiServices _apiServices = ApiServices();

  @override
  void onInit() {
    super.onInit();
    // Get email from arguments if passed
    if (Get.arguments != null && Get.arguments is String) {
      email.value = Get.arguments;
    } else {
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

  /// Handle verify button press - SIGNUP FLOW ONLY
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

      // Create verify OTP request
      final request = VerifyOtpRequestModel(
        email: email.value,
        otp: otpCode,
      );

      // Call API
      final response = await _apiServices.verifyOtp(request);

      // Save user session if tokens are provided
      if (response.accessToken != null && response.accessToken!.isNotEmpty) {
        print('✅ Access token received, saving session...');
        await SharedPreferencesUtil.saveUserSession(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken,
          userId: response.userId,
          userName: response.userName,
          email: response.email ?? email.value,
        );
        print('✅ User session saved successfully');
      } else {
        print('⚠️ No access token in OTP verification response');
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

      // Navigate to Verified Screen (SIGNUP FLOW)
      if (context.mounted) {
        context.go(AppPath.verifiedfromverifyemail);
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
      } else if (errorMessage.toLowerCase().contains('already') && 
                 errorMessage.toLowerCase().contains('verified')) {
        // For signup, if already verified, send to login
        CustomSnackbar.info(
          context: context,
          title: 'Already Verified',
          message: 'This account is already verified. Please login.',
        );
        
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) {
          context.go(AppPath.login);
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
      if (errorMessage.toLowerCase().contains('already activated') || 
          errorMessage.toLowerCase().contains('already verified')) {
        CustomSnackbar.info(
          context: context,
          title: 'Account Already Verified',
          message: 'Your account is already activated.',
        );
      } else if (errorMessage.toLowerCase().contains('not found') || 
                 errorMessage.toLowerCase().contains('does not exist')) {
        CustomSnackbar.error(
          context: context,
          title: 'Email Not Found',
          message: 'No account found with this email address.',
        );
      } else {
        CustomSnackbar.error(
          context: context,
          title: 'Failed to Resend',
          message: errorMessage.isEmpty ? 'Could not send OTP. Please try again.' : errorMessage,
        );
      }
      
      // Stop timer if there's an error
      _timer?.cancel();
      isResending.value = false;
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
