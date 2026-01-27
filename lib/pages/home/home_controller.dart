import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:austin_small_talk/data/global/shared_preference.dart';
import 'package:austin_small_talk/data/global/scenario_data.dart';
import 'package:austin_small_talk/service/auth/api_service/api_services.dart';
import 'package:austin_small_talk/service/auth/api_constant/api_constant.dart';
import 'package:austin_small_talk/service/auth/models/daily_scenario_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../utils/toast_message/toast_message.dart';
import 'widgets/scenario_dialog.dart';

/// Controller for Home Screen - handles home page logic and scenario selection
class HomeController extends GetxController {
  // Services
  final ApiServices _apiServices = ApiServices();

  // Observable states
  final RxBool isLoading = false.obs;
  final RxString userName = 'Sophia Adams'.obs;
  final RxString userProfileImage = ''.obs;
  final RxList<DailyScenarioModel> dailyScenarios = <DailyScenarioModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    fetchDailyScenarios();
  }

  /// Fetch user profile from API
  Future<void> fetchUserProfile() async {
    try {
      // Get access token
      final accessToken = SharedPreferencesUtil.getAccessToken();
      
      if (accessToken == null || accessToken.isEmpty) {
        print('❌ No access token found for profile');
        return;
      }

      print('📡 Fetching user profile...');
      
      // Call API
      final profile = await _apiServices.getUserProfile(
        accessToken: accessToken,
      );

      // Update user data
      userName.value = profile.name;
      userProfileImage.value = profile.getFullImageUrl(ApiConstant.baseUrl) ?? '';
      
      print('✅ User profile loaded: ${profile.name}');
      print('📸 Profile image: ${userProfileImage.value}');
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      // Keep default values on error
    }
  }

  /// Fetch daily scenarios from API
  Future<void> fetchDailyScenarios() async {
    try {
      isLoading.value = true;
      
      // Get access token
      final accessToken = SharedPreferencesUtil.getAccessToken();
      
      if (accessToken == null || accessToken.isEmpty) {
        print('❌ No access token found');
        isLoading.value = false;
        return;
      }

      print('📡 Fetching daily scenarios...');
      
      // Call API
      final response = await _apiServices.getDailyScenarios(
        accessToken: accessToken,
      );

      if (response.status == 'success') {
        dailyScenarios.value = response.scenarios;
        print('✅ Fetched ${dailyScenarios.length} daily scenarios');
      }
    } catch (e) {
      print('❌ Error fetching daily scenarios: $e');
      // Show error message to user
      ToastMessage.error('Failed to load scenarios');
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle scenario card tap
  void onScenarioTap(BuildContext context, String scenarioId, String scenarioIcon, String scenarioTitle, String scenarioDescription) {
    print('🎯 onScenarioTap called - ID: $scenarioId, Title: $scenarioTitle');
    
    // Create scenario data object
    final scenarioData = ScenarioData(
      scenarioId: scenarioId,
      scenarioType: scenarioTitle,
      scenarioIcon: scenarioIcon,
      scenarioTitle: scenarioTitle,
      scenarioDescription: scenarioDescription,
    );
    
    // Show scenario dialog
    showScenarioDialog(context, scenarioData);
  }

  /// Show scenario dialog
  void showScenarioDialog(BuildContext context, ScenarioData scenarioData) {
    print('📱 showScenarioDialog called - About to show dialog for: ${scenarioData.scenarioTitle}');
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        print('🏗️ Dialog builder called');
        return ScenarioDialog(
          scenarioData: scenarioData,
        );
      },
    );
  }

  /// Handle create your own scenario
  void onCreateOwnScenario(BuildContext context) {
    context.push(AppPath.createScenario);
  }

  /// Handle notification icon tap
  void onNotificationTap(BuildContext context) {
    context.push(AppPath.notification);
  }

  /// Update user name
  void updateUserName(String name) {
    userName.value = name;
  }
}
