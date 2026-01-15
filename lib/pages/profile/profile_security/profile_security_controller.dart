import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_route/app_path.dart';
import '../../../utils/toast_message/toast_message.dart';
import '../../../service/auth/api_service/api_services.dart';
import '../../../data/global/shared_preference.dart';

class ProfileSecurityController extends GetxController {
  // Observable security settings
  final RxBool loginActivity = true.obs;
  final RxBool emailPhoneVerification = true.obs;
  final RxBool isLoading = false.obs;

  /// Toggle login activity tracking
  void toggleLoginActivity(bool value) {
    loginActivity.value = value;
    _saveSettings();
  }

  /// Toggle email & phone verification
  void toggleEmailPhoneVerification(bool value) {
    emailPhoneVerification.value = value;
    _saveSettings();
  }
  
  Future<void> performLogout(BuildContext context) async {
    print('🔷 Logging out user...');
    
    // Clear ALL SharedPreferences data (tokens, user data, conversations)
    print('   - Clearing SharedPreferences...');
    await SharedPreferencesUtil.logout(keepRememberMe: false);
    print('   ✅ SharedPreferences cleared');

    // Clear GetX controllers and data
    print('   - Clearing GetX controllers...');
    Get.deleteAll(force: true);
    print('   ✅ GetX controllers cleared');
    
    print('✅ Logout complete');

    // Show success message
    ToastMessage.success('Logged out successfully', title: 'Logout');
    
    // Small delay for toast
    await Future.delayed(Duration(milliseconds: 300));

    // Navigate to login page
    if (context.mounted) {
      context.go(AppPath.login);
    }
  }

  /// Navigate to change password screen
  void onChangePassword(BuildContext context) {
    context.push(AppPath.changePassword);
  }

  /// Delete account
  void onDeleteAccount(BuildContext context) {
    Get.defaultDialog(
      title: 'Delete Account',
      middleText: 'Are you sure you want to delete your account? This action cannot be undone.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        performDeleteAccount(context);
      },
    );
  }

  /// Perform account deletion after confirmation
  Future<void> performDeleteAccount(BuildContext context) async {
    try {
      isLoading.value = true;
      print('🔷 Starting account deletion...');

      // Get access token
      final accessToken = SharedPreferencesUtil.getAccessToken();
      
      if (accessToken == null || accessToken.isEmpty) {
        ToastMessage.error("Please login first");
        isLoading.value = false;
        return;
      }

      print('✅ Access token found: ${accessToken.substring(0, 20)}...');

      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          },
        );
      }


      // Call API
      final apiService = ApiServices();
      String successMessage = 'Account deleted successfully';
      
      try {
        final response = await apiService.deleteAccount(
          accessToken: accessToken,
        );
        print('✅ Account deleted successfully!');
        print('   Message: ${response.message}');
        successMessage = response.message;
      } catch (e) {
        print('❌ Error from API: $e');
        
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        
        // Check if it's an authentication error or user not found
        // In these cases, we still want to logout the user
        if (errorMessage.contains('token') || 
            errorMessage.contains('Token') || 
            errorMessage.contains('invalid') ||
            errorMessage.contains('expired') ||
            errorMessage.contains('User not found') ||
            errorMessage.contains('user_not_found')) {
          
          print('ℹ️ Token/user issue detected - proceeding with logout');
          successMessage = 'Account data cleared. Logging you out...';
        } else {
          // For other errors, don't logout - show error and return
          print('❌ Unexpected error - not proceeding with logout');
          rethrow;
        }
      }

      // Close loading dialog
      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
      }
      
      // Always logout after delete account (whether API succeeded or token was invalid)
      print('🗑️ Starting complete data cleanup...');
      
      // Clear ALL SharedPreferences data (tokens, user info, conversations, etc.)
      print('   - Clearing SharedPreferences (tokens, user data, conversations)...');
      await SharedPreferencesUtil.logout(keepRememberMe: false);
      print('   ✅ SharedPreferences cleared');
      
      // Clear ALL GetX controllers and cached data
      print('   - Clearing GetX controllers...');
      Get.deleteAll(force: true);
      print('   ✅ GetX controllers cleared');
      
      print('✅ Complete data cleanup finished');
      
      // Show success message
      ToastMessage.success(successMessage);
      
      // Wait for toast to show
      await Future.delayed(Duration(milliseconds: 800));
      
      // Navigate to login screen
      if (context.mounted) {
        print('🔄 Navigating to login screen...');
        context.go(AppPath.login);
      }

    } catch (e) {
      print('❌ Error deleting account: $e');
      
      isLoading.value = false;
      
      // Close loading dialog if open
      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
      }
      
      // Show error message
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      ToastMessage.error(errorMessage);
    }
  }

  /// Save security settings
  void _saveSettings() {
    // TODO: Save settings to local storage or API
    print('Security settings saved');
  }

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  /// Load security settings
  void _loadSettings() {
    // TODO: Load settings from local storage or API
  }
}
