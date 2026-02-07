import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_route/app_path.dart';
import '../../utils/custom_snackbar/custom_snackbar.dart';

/// Controller for VerifiedScreen (from Create New Password flow) - handles verified screen logic
class VerifiedControllerFromCreateNewPassword extends GetxController {
  // Observable states
  final RxBool isLoading = false.obs;

  /// Handle login to account button press
  Future<void> onLoginToAccountPressed(BuildContext context) async {
    if (isLoading.value) return; // Prevent double tap
    
    isLoading.value = true;

    try {
      // Add a small delay for better UX
      await Future.delayed(const Duration(milliseconds: 300));

      if (!context.mounted) {
        print('⚠️ Context not mounted - aborting navigation');
        return;
      }

      print('🔄 Navigating to login screen...');
      
      // Navigate to login screen (user needs to login with new password)
      context.push(AppPath.login);
      
      print('✅ Navigation to login initiated');
    } catch (e, stackTrace) {
      print('❌ Navigation error: $e');
      print('Stack trace: $stackTrace');
      
      if (!context.mounted) return;
      
      CustomSnackbar.error(
        context: context,
        title: 'Navigation Error',
        message: 'Unable to navigate. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
