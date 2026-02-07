import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/toast_message/toast_message.dart';
import '../../../service/auth/api_service/api_services.dart';
import '../../../service/auth/models/create_scenario_request_model.dart';
import '../../../core/app_route/app_path.dart';
import '../../../data/global/shared_preference.dart';
import '../../../data/global/scenario_data.dart';
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
    // Validate Scenario Title
    if (scenarioTitle.value.trim().isEmpty) {
      ToastMessage.error(
        'Scenario Title is required',
        title: 'Missing Field',
      );
      return;
    }

    if (scenarioTitle.value.trim().length < 3) {
      ToastMessage.error(
        'Scenario Title must be at least 3 characters',
        title: 'Invalid Title',
      );
      return;
    }

    // Validate Description
    if (description.value.trim().isEmpty) {
      ToastMessage.error(
        'Description is required',
        title: 'Missing Field',
      );
      return;
    }

    if (description.value.trim().length < 10) {
      ToastMessage.error(
        'Description must be at least 10 characters',
        title: 'Invalid Description',
      );
      return;
    }

    // Validate Difficulty Level
    if (difficultyLevel.value.isEmpty) {
      ToastMessage.error(
        'Please select a difficulty level',
        title: 'Missing Field',
      );
      return;
    }

    try {
      isLoading.value = true;
      print('🔷 Starting scenario creation...');

      // Get access token
      final accessToken = SharedPreferencesUtil.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        ToastMessage.error(
          'Please login first',
          title: 'Authentication Required',
        );
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
      print('   Scenario ID: ${response.scenarioId}');

      ToastMessage.success('Scenario created successfully!');

      // Refresh history controller to show new chat session (when user returns to history)
      try {
        final historyController = Get.find<HistoryController>();
        await historyController.refreshHistoryData();
      } catch (e) {
        print('⚠️ History controller not found, will refresh on next visit');
      }

      // Create scenario data for message screen
      final scenarioData = ScenarioData(
        scenarioId: response.scenarioId,  // ai_scenario_id from API
        scenarioTitle: response.scenarioTitle,
        scenarioDescription: response.description,
        scenarioIcon: '🎯', // Default emoji for user-created scenarios
        scenarioType: 'user_created',
        difficulty: response.difficultyLevel,
        sourceScreen: 'create_scenario', // Track that user came from Create Scenario
      );

      print('═══════════════════════════════════════════');
      print('📤 NAVIGATING TO MESSAGE SCREEN:');
      print('   Scenario ID (ai_scenario_id): ${scenarioData.scenarioId}');
      print('   Title: ${scenarioData.scenarioTitle}');
      print('   Type: ${scenarioData.scenarioType}');
      print('   Source Screen: ${scenarioData.sourceScreen}');
      print('   This ID will be used to start chat session');
      print('═══════════════════════════════════════════');

      // Navigate to message screen to start conversation
      if (context.mounted) {
        print('✅ Context is mounted, attempting navigation...');
        try {
          // Use GoRouter.of(context).push instead of context.push for better reliability
          GoRouter.of(context).push(AppPath.messageScreen, extra: scenarioData);
          print('✅ Navigation command executed');
        } catch (navError) {
          print('❌ Navigation error: $navError');
          ToastMessage.error('Failed to open chat screen');
        }
      } else {
        print('❌ Context is not mounted, cannot navigate');
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
