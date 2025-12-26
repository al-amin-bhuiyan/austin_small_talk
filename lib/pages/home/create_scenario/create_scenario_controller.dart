import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../utils/toast_message/toast_message.dart';

/// Controller for Create Scenario Screen
class CreateScenarioController extends GetxController {
  // Observable states
  final RxBool isLoading = false.obs;
  
  // Form fields
  final RxString scenarioTitle = ''.obs;
  final RxString description = ''.obs;
  final RxString difficultyLevel = 'Beginner'.obs;
  final RxDouble conversationLength = 0.5.obs; // 0.0 to 1.0
  
  // Difficulty options
  final List<String> difficultyOptions = ['Beginner', 'Medium', 'Hard'];

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

  /// Update conversation length
  void updateConversationLength(double value) {
    conversationLength.value = value;
  }

  /// Validate and start scenario
  void startScenario(BuildContext context) {
    if (scenarioTitle.value.isEmpty) {
      ToastMessage.error('Please enter a scenario title');
      return;
    }

    if (description.value.isEmpty) {
      ToastMessage.error('Please enter a description');
      return;
    }

    // TODO: Navigate to conversation screen with custom scenario
    ToastMessage.success('Starting scenario: ${scenarioTitle.value}');
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize with default values
  }
}
