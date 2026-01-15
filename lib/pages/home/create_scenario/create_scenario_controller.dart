import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/toast_message/toast_message.dart';
import '../../../service/auth/api_service/api_services.dart';
import '../../../service/auth/models/create_scenario_request_model.dart';
import '../../../core/app_route/app_path.dart';
import '../../../data/global/shared_preference.dart';
import '../../history/history_controller.dart';

/// Controller for Create Scenario Screen
class CreateScenarioController extends GetxController {
  // Observable states
  final RxBool isLoading = false.obs;
  
  // Form fields
  final RxString scenarioTitle = ''.obs;
  final RxString description = ''.obs;
  final RxString difficultyLevel = 'Easy'.obs;  // Display value (will be converted to lowercase for API)
  
  // Difficulty options - Display names (API expects: easy, medium, hard - lowercase)
  final List<String> difficultyOptions = ['Easy', 'Medium', 'Hard'];

  /// Update scenario title
  void updateTitle(String value) {
    scenarioTitle.value = value;
  }

  /// Update description
  void updateDescription(String value) {
    description.value = value;
  }

  /// Update difficulty level
  void updateDifficulty(String value) {
    difficultyLevel.value = value;
  }

  /// Validate and start scenario
  void startScenario(BuildContext context) async {
    if (scenarioTitle.value.isEmpty) {
      ToastMessage.error('Please enter a scenario title');
      return;
    }

    if (description.value.isEmpty) {
      ToastMessage.error('Please enter a description');
      return;
    }

    try {
      isLoading.value = true;
      print('🔷 Starting scenario creation...');

      // Get access token
      final accessToken = SharedPreferencesUtil.getAccessToken();
      
      if (accessToken == null || accessToken.isEmpty) {
        ToastMessage.error('Please login first');
        isLoading.value = false;
        return;
      }

      print('✅ Access token found: ${accessToken.substring(0, 20)}...');

      // Map difficulty level to lowercase (API expects: easy, medium, hard)
      final difficultyLevelValue = difficultyLevel.value.toLowerCase();

      print('📝 Scenario details:');
      print('   Title: ${scenarioTitle.value}');
      print('   Description: ${description.value}');
      print('   Difficulty (UI): ${difficultyLevel.value}');
      print('   Difficulty (API): $difficultyLevelValue');

      // Create request model
      final request = CreateScenarioRequestModel(
        scenarioTitle: scenarioTitle.value,
        description: description.value,
        difficultyLevel: difficultyLevelValue,
        conversationLength: 'medium', // Default to medium
      );

      print('📤 Request JSON: ${request.toJson()}');

      // Call API
      final apiService = ApiServices();
      final response = await apiService.createScenario(
        request: request,
        accessToken: accessToken,
      );

      print('✅ Scenario created successfully!');
      print('   ID: ${response.id}');

      ToastMessage.success('Scenario created successfully!');
      
      // Refresh history controller to show new scenario
      try {
        final historyController = Get.find<HistoryController>();
        await historyController.fetchUserScenarios();
      } catch (e) {
        print('⚠️ History controller not found, will refresh on next visit');
      }
      
      // Navigate to history screen
      if (context.mounted) {
        context.go(AppPath.history);
      }

    } catch (e) {
      print('❌ Error creating scenario: $e');
      ToastMessage.error(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize with default values
  }
}
