import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:austin_small_talk/data/global/scenario_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../utils/toast_message/toast_message.dart';
import '../../service/auth/api_service/api_services.dart';
import '../../service/auth/models/scenario_model.dart';
import '../../service/auth/models/chat_history_model.dart';
import '../../data/global/shared_preference.dart';

/// Controller for History Screen - handles chat history logic
class HistoryController extends GetxController {
  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isScenariosLoading = false.obs;
  final RxString searchQuery = ''.obs;
  
  // User created scenarios
  final RxList<ScenarioModel> userScenarios = <ScenarioModel>[].obs;
  
  // Chat history sessions from API
  final RxList<ChatSessionHistory> chatSessions = <ChatSessionHistory>[].obs;
  
  // API Service
  final ApiServices _apiServices = ApiServices();

  @override
  void onInit() {
    super.onInit();
    fetchChatHistory();
  }

  /// Fetch chat history from API
  Future<void> fetchChatHistory() async {
    try {
      isLoading.value = true;
      
      // Get access token
      final accessToken = SharedPreferencesUtil.getAccessToken();
      
      if (accessToken == null || accessToken.isEmpty) {
        print('❌ No access token found');
        isLoading.value = false;
        return;
      }

      print('📡 Fetching chat history...');
      
      // Call API
      final response = await _apiServices.getChatHistory(
        accessToken: accessToken,
      );

      if (response.status == 'success') {
        chatSessions.value = response.sessions;
        print('✅ Fetched ${chatSessions.length} chat sessions');
      }
    } catch (e) {
      print('❌ Error fetching chat history: $e');
      ToastMessage.error('Failed to load chat history');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get conversations from chat sessions
  List<ConversationItem> get conversations {
    return chatSessions.map((session) {
      // Use scenario emoji if available and not empty, otherwise use default
      final icon = (session.scenarioEmoji != null && session.scenarioEmoji!.isNotEmpty) 
          ? session.scenarioEmoji! 
          : '💬';
      
      // Use scenario title if available and not empty, otherwise use default
      final title = (session.scenarioTitle != null && session.scenarioTitle!.isNotEmpty) 
          ? session.scenarioTitle! 
          : 'Chat Session';
      
      // Use scenario description from API response
      String description = (session.scenarioDescription != null && session.scenarioDescription!.isNotEmpty)
          ? session.scenarioDescription!
          : 'Practice conversation';
      
      // Format last activity date
      String timeFormatted = _formatDate(session.lastActivityAt);
      
      return ConversationItem(
        id: session.sessionId,
        icon: icon,
        title: title,
        description: description,
        preview: '', // Not used in new design
        time: timeFormatted,
        timestamp: session.lastActivityAt,
        isEmoji: true,
        messageCount: session.messageCount,
        difficulty: session.scenarioDifficulty ?? '',
      );
    }).toList();
  }
  
  /// Format date in readable format (e.g., "Jan 26, 2026")
  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // If today, show time
    if (difference.inDays == 0) {
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } 
    // If yesterday
    else if (difference.inDays == 1) {
      return 'Yesterday';
    } 
    // If within last 7 days
    else if (difference.inDays < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[dateTime.weekday - 1];
    } 
    // Otherwise show date
    else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    }
  }

  /// Filter conversations based on search query
  List<ConversationItem> get filteredConversations {
    final convos = conversations;
    if (searchQuery.value.isEmpty) {
      return convos;
    }
    return convos.where((conversation) {
      return conversation.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          conversation.preview.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Handle conversation tap
  void onConversationTap(String sessionId, BuildContext context) async {
    try {
      print('');
      print('╔═══════════════════════════════════════════╗');
      print('║    HISTORY CONVERSATION TAPPED             ║');
      print('╚═══════════════════════════════════════════╝');
      print('🎯 Session ID: $sessionId');
      
      // Get access token
      final accessToken = SharedPreferencesUtil.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        print('❌ No access token found');
        ToastMessage.error('Please log in again');
        return;
      }
      
      print('✅ Access token found');
      print('📡 Fetching session history from API...');
      
      // Show loading using BuildContext instead of Get
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
      );
      
      // Fetch session history with messages
      final sessionHistory = await _apiServices.getSessionHistory(
        accessToken: accessToken,
        sessionId: sessionId,
      );
      
      // Close loading
      Navigator.of(context).pop();
      
      print('✅ Session history loaded successfully');
      print('📋 Session Details:');
      print('   - Scenario ID: ${sessionHistory.session.scenarioId}');
      print('   - Scenario Title: ${sessionHistory.session.scenarioTitle}');
      print('   - Messages Count: ${sessionHistory.session.messages.length}');
      print('   - Difficulty: ${sessionHistory.session.scenarioDifficulty}');
      
      // Create ScenarioData from session
      final scenarioData = ScenarioData(
        scenarioId: sessionHistory.session.scenarioId ?? '',
        scenarioType: sessionHistory.session.scenarioTitle ?? 'Chat Session',
        scenarioIcon: sessionHistory.session.scenarioEmoji ?? '💬',
        scenarioTitle: sessionHistory.session.scenarioTitle ?? 'Chat Session',
        scenarioDescription: sessionHistory.session.scenarioDescription ?? '',
        difficulty: sessionHistory.session.scenarioDifficulty ?? '',
        sourceScreen: 'history', // Track that user came from History
      );
      
      print('📦 ScenarioData created:');
      print('   - ID: ${scenarioData.scenarioId}');
      print('   - Title: ${scenarioData.scenarioTitle}');
      print('   - Icon: ${scenarioData.scenarioIcon}');
      print('   - Source Screen: ${scenarioData.sourceScreen}');
      
      // Navigate to message screen with existing session data
      print('🚀 Navigating to MessageScreen...');
      print('📍 Path: ${AppPath.messageScreen}');
      
      context.push(
        AppPath.messageScreen,
        extra: {
          'scenarioData': scenarioData,
          'existingSessionId': sessionId,
          'existingMessages': sessionHistory.session.messages,
        },
      );
      
      print('✅ Navigation command executed');
      print('═══════════════════════════════════════════');
    } catch (e, stackTrace) {
      // Close loading if still open - use Navigator instead of Get
      try {
        Navigator.of(context).pop();
      } catch (_) {
        // Dialog might not be open, ignore error
      }
      
      print('');
      print('❌❌❌ ERROR IN onConversationTap ❌❌❌');
      print('Error: $e');
      print('Stack trace:');
      print(stackTrace);
      print('═══════════════════════════════════════════');
      
      ToastMessage.error('Failed to load conversation');
    }
  }

  /// Handle new scenario button
  void onNewScenario(BuildContext context) {
    print('🎨 Creating new scenario');
    context.push(AppPath.createScenario);
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
  final String description;
  final String preview;
  final String time;
  final DateTime timestamp;
  final bool isEmoji;
  final int messageCount;
  final String difficulty;

  ConversationItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.preview,
    required this.time,
    required this.timestamp,
    this.isEmoji = false,
    this.messageCount = 0,
    this.difficulty = '',
  });
}
