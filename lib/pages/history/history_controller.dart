import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../utils/toast_message/toast_message.dart';
import '../../service/auth/api_service/api_services.dart';
import '../../service/auth/models/scenario_model.dart';
import '../../data/global/shared_preference.dart';

/// Controller for History Screen - handles chat history logic
class HistoryController extends GetxController {
  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isScenariosLoading = false.obs;
  final RxString searchQuery = ''.obs;
  
  // User created scenarios
  final RxList<ScenarioModel> userScenarios = <ScenarioModel>[].obs;
  
  // Sample conversation history data
  final RxList<ConversationItem> conversations = <ConversationItem>[
    ConversationItem(
      id: '1',
      icon: 'plan',
      title: 'On a Plane',
      preview: 'You seem to travel often. What do you want to...',
      time: '10:24 AM',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ConversationItem(
      id: '2',
      icon: 'social_event',
      title: 'Social Event',
      preview: 'What kind of events do you usually attend?',
      time: 'Yesterday',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ConversationItem(
      id: '3',
      icon: 'workplace',
      title: 'Workplace',
      preview: 'Today\'s topic: Handling unexpected question...',
      time: '2 days ago',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ConversationItem(
      id: '4',
      icon: 'create_your_own_scenario',
      title: 'Create Scenario',
      preview: 'Job interview for nurse - your answer...',
      time: '1 week ago',
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ].obs;

  /// Filter conversations based on search query
  List<ConversationItem> get filteredConversations {
    if (searchQuery.value.isEmpty) {
      return conversations;
    }
    return conversations.where((conversation) {
      return conversation.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          conversation.preview.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Handle conversation tap
  void onConversationTap(String conversationId,BuildContext context) {
    context.push(AppPath.createScenario);
    // TODO: Navigate to conversation detail screen
    ToastMessage.info('Opening conversation: $conversationId', title: 'Conversation');
  }

  /// Handle new scenario button
  void onNewScenario(BuildContext context) {
    // TODO: Navigate to scenario selection or creation

    context.push(AppPath.createScenario);
    ToastMessage.info('Create a new conversation', title: 'New Scenario');
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
  }

  /// Fetch user created scenarios
  Future<void> fetchUserScenarios() async {
    try {
      isScenariosLoading.value = true;
      print('📡 Fetching user scenarios...');

      // Get access token
      final accessToken = SharedPreferencesUtil.getAccessToken();
      
      if (accessToken == null || accessToken.isEmpty) {
        print('❌ No access token found, skipping scenarios fetch');
        isScenariosLoading.value = false;
        return;
      }

      print('✅ Access token found');

      // Call API
      final apiService = ApiServices();
      final scenarios = await apiService.getScenarios(accessToken: accessToken);

      userScenarios.value = scenarios;
      print('✅ Fetched ${scenarios.length} scenarios');

    } catch (e, stackTrace) {
      print('❌ Error fetching scenarios: $e');
      print('Stack trace: $stackTrace');
      // Clear scenarios on error
      userScenarios.value = [];
    } finally {
      isScenariosLoading.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
    // onReady is called after the widget is fully rendered
    // This is safe for API calls
    final token = SharedPreferencesUtil.getAccessToken();
    if (token != null && token.isNotEmpty) {
      fetchUserScenarios();
    }
  }
}

/// Conversation item model
class ConversationItem {
  final String id;
  final String icon;
  final String title;
  final String preview;
  final String time;
  final DateTime timestamp;

  ConversationItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.preview,
    required this.time,
    required this.timestamp,
  });
}
