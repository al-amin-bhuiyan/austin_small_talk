import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_route/app_path.dart';
import '../../../utils/toast_message/toast_message.dart';

class ProfileSecurityController extends GetxController {
  // Observable security settings
  final RxBool loginActivity = true.obs;
  final RxBool emailPhoneVerification = true.obs;

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
  void performLogout(BuildContext context) {



    // Clear GetX controllers and data
    Get.deleteAll(force: true);

    // Navigate to login page
    context.push(AppPath.login);

    // Show success message
    ToastMessage.success('Logged out successfully', title: 'Logout');
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
        // TODO: Implement delete account logic
        ToastMessage.error('Your account has been deleted', title: 'Account Deleted');
      },
    );
  }

  /// Perform account deletion after confirmation
  void performDeleteAccount(BuildContext context) {
    // Clear all user data
    loginActivity.value = false;
    emailPhoneVerification.value = false;
    
    // Clear GetX controllers and data
    Get.deleteAll(force: true);
    
    // Navigate to login page
    context.go(AppPath.login);
    
    // Show error/warning message
    ToastMessage.error('Your account has been deleted', title: 'Account Deleted');
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
