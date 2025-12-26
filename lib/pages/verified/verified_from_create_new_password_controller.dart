import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_route/app_path.dart';
import '../../utils/toast_message/toast_message.dart';

/// Controller for VerifiedScreen (from Create New Password flow) - handles verified screen logic
class VerifiedControllerFromCreateNewPassword extends GetxController {
  // Observable states
  final RxBool isLoading = false.obs;

  /// Handle login to account button press
  Future<void> onLoginToAccountPressed(BuildContext context) async {
    try {
      isLoading.value = true;

      // Add a small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to login screen
      context.go(AppPath.login);
    } catch (e) {
      ToastMessage.error(
        'Failed to navigate: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
