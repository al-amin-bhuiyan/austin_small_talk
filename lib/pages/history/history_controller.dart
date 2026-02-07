import 'dart:convert';
import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:austin_small_talk/data/global/scenario_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../utils/toast_message/toast_message.dart';
import '../../service/auth/api_service/api_services.dart';
import '../../service/auth/models/chat_history_model.dart';
import '../../data/global/shared_preference.dart';

/// Controller for History Screen - handles chat history logic
class HistoryController extends GetxController {
  // Observable states
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

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
        // ✅ Deduplicate sessions by session_id (prevent multiple items for same conversation)
        final uniqueSessions = <String, ChatSessionHistory>{};
        for (var session in response.sessions) {
          uniqueSessions[session.sessionId] = session;
        }

        chatSessions.value = uniqueSessions.values.toList();
        print('✅ Fetched ${response.sessions.length} sessions, ${chatSessions.length} unique');
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

      // ✅ Get message count from local storage (more accurate and up-to-date)
      final localMessageCount = getLocalMessageCount(session.scenarioId);
      final messageCount = localMessageCount > 0 ? localMessageCount : session.messageCount;

      // ✅ Get last message time from local storage
      final localLastMessageTime = getLocalLastMessageTime(session.scenarioId);
      final lastActivityTime = localLastMessageTime ?? session.lastActivityAt;

      // Format last activity date
      String timeFormatted = _formatDate(lastActivityTime);

      return ConversationItem(
        id: session.sessionId,
        icon: icon,
        title: title,
        description: description,
        preview: '', // Not used in new design
        time: timeFormatted,
        timestamp: lastActivityTime,
        isEmoji: true,
        messageCount: messageCount,
        difficulty: session.scenarioDifficulty ?? '',
      );
    }).toList();
  }

  /// Get message count from local storage for a scenario (PUBLIC - used by UI)
  int getLocalMessageCount(String? scenarioId) {
    if (scenarioId == null || scenarioId.isEmpty) return 0;

    try {
      final prefs = SharedPreferencesUtil.instance;
      final messagesJsonString = prefs.getString('chat_messages_$scenarioId');

      if (messagesJsonString != null && messagesJsonString.isNotEmpty) {
        final messagesJson = jsonDecode(messagesJsonString) as List;
        return messagesJson.length;
      }
    } catch (e) {
      print('⚠️ Error reading local message count for $scenarioId: $e');
    }

    return 0;
  }

  /// Get last message timestamp from local storage (PUBLIC - used by UI)
  DateTime? getLocalLastMessageTime(String? scenarioId) {
    if (scenarioId == null || scenarioId.isEmpty) return null;

    try {
      final prefs = SharedPreferencesUtil.instance;
      final messagesJsonString = prefs.getString('chat_messages_$scenarioId');

      if (messagesJsonString != null && messagesJsonString.isNotEmpty) {
        final messagesJson = jsonDecode(messagesJsonString) as List;
        if (messagesJson.isNotEmpty) {
          final lastMessage = messagesJson.last;
          return DateTime.parse(lastMessage['timestamp']);
        }
      }
    } catch (e) {
      print('⚠️ Error reading local last message time for $scenarioId: $e');
    }

    return null;
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

  /// Handle conversation tap - OPTIMIZED for instant navigation
  void onConversationTap(String sessionId, BuildContext context) async {
    try {
      print('');
      print('╔═══════════════════════════════════════════╗');
      print('║    HISTORY CONVERSATION TAPPED             ║');
      print('╚═══════════════════════════════════════════');
      print('🎯 Session ID: $sessionId');

      // Find the session in our cached list
      final session = chatSessions.firstWhereOrNull(
        (s) => s.sessionId == sessionId,
      );

      if (session == null) {
        print('❌ Session not found in cache');
        ToastMessage.error('Session not found');
        return;
      }

      print('✅ Session found in cache');
      print('📋 Session Details:');
      print('   - Scenario ID: ${session.scenarioId}');
      print('   - Scenario Title: ${session.scenarioTitle}');
      print('   - Difficulty: ${session.scenarioDifficulty}');

      // Create ScenarioData from cached session
      final scenarioData = ScenarioData(
        scenarioId: session.scenarioId ?? '',
        scenarioType: session.scenarioTitle ?? 'Chat Session',
        scenarioIcon: session.scenarioEmoji ?? '💬',
        scenarioTitle: session.scenarioTitle ?? 'Chat Session',
        scenarioDescription: session.scenarioDescription ?? '',
        difficulty: session.scenarioDifficulty ?? '',
        sourceScreen: 'history', // Track that user came from History
      );

      print('📦 ScenarioData created:');
      print('   - ID: ${scenarioData.scenarioId}');
      print('   - Title: ${scenarioData.scenarioTitle}');
      print('   - Icon: ${scenarioData.scenarioIcon}');
      print('   - Source Screen: ${scenarioData.sourceScreen}');

      // ✅ OPTIMIZED: Navigate immediately - MessageScreen will load from local storage
      print('🚀 Navigating to MessageScreen (instant - using local storage)...');
      print('📍 Path: ${AppPath.messageScreen}');

      context.push(
        AppPath.messageScreen,
        extra: scenarioData, // Just pass ScenarioData - MessageScreen loads from storage
      );

      print('✅ Navigation command executed instantly!');
      print('   MessageScreen will load messages from local storage');
      print('═══════════════════════════════════════════');
    } catch (e, stackTrace) {
      print('');
      print('❌❌❌ ERROR IN onConversationTap ❌❌❌');
      print('Error: $e');
      print('Stack trace:');
      print(stackTrace);
      print('═══════════════════════════════════════════');

      ToastMessage.error('Failed to open conversation');
    }
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
  }

  /// Refresh all history data
  Future<void> refreshHistoryData() async {
    print('');
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║              REFRESHING HISTORY DATA                       ║');
    print('╚═══════════════════════════════════════════════════════════╝');

    try {
      // Fetch chat history
      await fetchChatHistory();

      print('✅ History data refreshed successfully');
      print('   - Chat sessions: ${chatSessions.length}');
      print('═══════════════════════════════════════════════════════════');
    } catch (e) {
      print('❌ Error refreshing history data: $e');
      print('═══════════════════════════════════════════════════════════');
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