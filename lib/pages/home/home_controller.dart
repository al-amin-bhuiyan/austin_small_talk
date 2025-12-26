import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../utils/toast_message/toast_message.dart';
import 'widgets/scenario_dialog.dart';

/// Controller for Home Screen - handles home page logic and scenario selection
class HomeController extends GetxController {
  // Observable states
  final RxBool isLoading = false.obs;
  final RxString userName = 'Sophia Adams'.obs;

  /// Handle scenario card tap
  void onScenarioTap(BuildContext context, String scenarioType, String scenarioIcon, String scenarioTitle) {
    print('🎯 onScenarioTap called - Type: $scenarioType, Title: $scenarioTitle');
    // Show scenario dialog
    showScenarioDialog(context, scenarioType, scenarioIcon, scenarioTitle);
  }

  /// Show scenario dialog
  void showScenarioDialog(BuildContext context, String scenarioType, String scenarioIcon, String scenarioTitle) {
    print('📱 showScenarioDialog called - About to show dialog');
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        print('🏗️ Dialog builder called');
        return ScenarioDialog(
          scenarioType: scenarioType,
          scenarioIcon: scenarioIcon,
          scenarioTitle: scenarioTitle,
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
