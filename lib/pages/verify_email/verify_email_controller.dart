import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../utils/toast_message/toast_message.dart';

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
      ToastMessage.error(
        'Please enter all 6 digits',
        title: 'Incomplete Code',
      );
      return;
    }

    try {
      isLoading.value = true;

      String otpCode = getOtpCode();

      // TODO: Implement your OTP verification API call here
      // Example: await verifyOtpApi(email: email.value, otp: otpCode);
      await Future.delayed(const Duration(seconds: 2)); // Simulating API call

      ToastMessage.success(
        'Email verified successfully with code: $otpCode',
      );

      // Navigate to next screen (e.g., home)
      // Get.offAllNamed(AppPath.home);
      if(flag.value){
        context.push(AppPath.createNewPassword);
      }
      else{
        context.push(AppPath.verifiedfromverifyemail);
      }
    } catch (e) {
      ToastMessage.error(
        'Verification failed: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend verification code
  Future<void> onResendCode() async {
    try {
      // TODO: Implement resend code API call
      await Future.delayed(const Duration(seconds: 1));

      ToastMessage.success(
        'Verification code sent to ${email.value}',
      );

      // Clear existing OTP
      for (var controller in otpControllers) {
        controller.clear();
      }
      focusNodes[0].requestFocus();
    } catch (e) {
      ToastMessage.error(
        'Failed to resend code: ${e.toString()}',
      );
    }
  }
}
