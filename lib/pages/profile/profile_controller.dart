import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../core/app_route/app_path.dart';
import '../../utils/toast_message/toast_message.dart';

/// Controller for Profile Screen
class ProfileController extends GetxController {
  // Observable states
  final RxBool isLoading = false.obs;
  
  // User info
  final RxString userName = 'Sophia Adams'.obs;
  final RxString userEmail = 'sophia@gmail.com'.obs;
  final RxString userAvatar = ''.obs;

  /// Handle Edit Profile tap
  void onEditProfile(BuildContext context) {
    // TODO: Navigate to edit profile screen
    context.push(AppPath.editProfile);
    ToastMessage.info('Navigate to edit profile screen', title: 'Edit Profile');
  }

  /// Handle Subscription tap
  void onSubscription(BuildContext context) {
    // TODO: Navigate to subscription screen
    context.push(AppPath.subscription);
    ToastMessage.info('Navigate to subscription screen', title: 'Subscription');
  }

  /// Handle Notification tap
  void onNotification(BuildContext context) {
    context.push(AppPath.profileNotification);
  }

  /// Handle Security tap
  void onSecurity(BuildContext context) {
    context.push(AppPath.profileSecurity);
  }

  /// Handle Support & Help tap
  void onSupportHelp(BuildContext context) {
    // TODO: Navigate to support screen
    context.push(AppPath.supportandhelp);
    ToastMessage.info('Navigate to support center', title: 'Support & Help');
  }

  /// Handle Logout tap
  void onLogout(BuildContext context) {
    // Show custom logout dialog - implementation in profile.dart
    // This method is called from profile.dart which will show the custom dialog
  }

  /// Handle actual logout after confirmation
  void performLogout(BuildContext context) {
    // Clear all user data
    userName.value = '';
    userEmail.value = '';
    userAvatar.value = '';
    
    // Clear GetX controllers and data
    Get.deleteAll(force: true);
    
    // Navigate to login page
    context.push(AppPath.login);
    
    // Show success message
    ToastMessage.success('Logged out successfully', title: 'Logout');
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize profile data
    loadUserProfile();
  }

  /// Load user profile data
  void loadUserProfile() {
    // TODO: Load from API or local storage
  }
}
