import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../core/app_route/app_path.dart';
import '../../data/global/shared_preference.dart';
import '../../service/auth/api_service/api_services.dart';
import '../../service/auth/api_constant/api_constant.dart';
import '../../utils/toast_message/toast_message.dart';
import '../ai_talk/voice_chat/service/voice_chat_manager.dart';

/// Controller for Profile Screen
class ProfileController extends GetxController {
  // Services
  final ApiServices _apiServices = ApiServices();

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
    
    // Navigate to login page - replace navigation stack (no flicker)
    context.go(AppPath.login);
    
    // Show success message
    ToastMessage.success('Logged out successfully', title: 'Logout');
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize profile data
    loadUserProfile();
  }

  /// Load user profile data from API
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      
      // Get access token
      final accessToken = SharedPreferencesUtil.getAccessToken();
      
      if (accessToken == null || accessToken.isEmpty) {
        print('❌ No access token found for profile');
        isLoading.value = false;
        return;
      }

      print('📡 Fetching user profile...');
      
      // Call API
      final profile = await _apiServices.getUserProfile(
        accessToken: accessToken,
      );

      // Update user data
      userName.value = profile.name;
      userEmail.value = profile.email;
      userAvatar.value = profile.getFullImageUrl(ApiConstant.baseUrl) ?? '';
      
      print('✅ User profile loaded: ${profile.name}');
      print('📸 Profile image: ${userAvatar.value}');
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      ToastMessage.error('Failed to load profile');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh profile data - called by pull-to-refresh
  Future<void> refreshProfileData() async {
    print('');
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║              REFRESHING PROFILE DATA                       ║');
    print('╚═══════════════════════════════════════════════════════════╝');
    
    await loadUserProfile();
    
    print('✅ Profile data refreshed successfully');
    print('═══════════════════════════════════════════════════════════');
  }
}