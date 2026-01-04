import 'dart:async';
import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../service/auth/api_service/api_services.dart';
import '../../service/auth/models/verify_otp_request_model.dart';
import '../../service/auth/models/resend_otp_request_model.dart';
import '../../utils/custom_snackbar/custom_snackbar.dart';

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

  /// Handle verify button press
  Future<void> onVerifyPressed(BuildContext context) async {
    if (!isOtpComplete()) {
      CustomSnackbar.error(
        context: context,
        title: 'Incomplete Code',
        message: 'Please enter all 6 digits',
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

      if (context.mounted) {
        CustomSnackbar.success(
          context: context,
          title: 'Success',
          message: response.message,
        );
      }

      // Navigate to next screen based on flag
      if (context.mounted) {
        if (flag.value) {
          // From forgot password flow
          context.push(AppPath.createNewPassword);
        } else {
          // From signup flow
          context.push(AppPath.verifiedfromverifyemail);
        }
      }
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      if (!context.mounted) return;
      
      // Check if it's an invalid OTP error
      if (errorMessage.toLowerCase().contains('invalid') && 
          errorMessage.toLowerCase().contains('otp')) {
        CustomSnackbar.error(
          context: context,
          title: 'Invalid OTP',
          message: errorMessage,
        );
      } else if (errorMessage.toLowerCase().contains('expired') && 
                 errorMessage.toLowerCase().contains('otp')) {
        CustomSnackbar.error(
          context: context,
          title: 'OTP Expired',
          message: errorMessage,
        );
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
      
      // Check if account is already activated
      if (errorMessage.toLowerCase().contains('already activated')) {
        CustomSnackbar.info(
          context: context,
          title: 'Account Already Activated',
          message: errorMessage,
        );
      } else {
        CustomSnackbar.error(
          context: context,
          title: 'Failed',
          message: errorMessage,
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
