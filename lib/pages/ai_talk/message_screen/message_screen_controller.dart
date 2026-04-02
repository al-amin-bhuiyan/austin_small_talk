import 'dart:convert';
import 'dart:async';
import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:austin_small_talk/data/global/scenario_data.dart';
import 'package:austin_small_talk/pages/history/history_controller.dart';
import 'package:austin_small_talk/service/auth/api_service/api_services.dart';
import 'package:austin_small_talk/utils/custom_snackbar/custom_snackbar.dart';
import 'package:austin_small_talk/utils/nav_bar/nav_bar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller for Message Screen - handles chat messages and interactions
/// ✅ OPTIMIZED: Smart session management with instant storage loading
class MessageScreenController extends GetxController {
  // API Service
  final ApiServices _apiServices = ApiServices();

  // Observable list of messages
  final messages = <ChatMessage>[].obs;

  // Text editing controller for input field
  final TextEditingController messageController = TextEditingController();

  // Observable for loading state
  final isLoading = false.obs;

  // Observable for sending message state
  final isSending = false.obs;

  // Scenario data
  ScenarioData? scenarioData;

  // Session ID from API
  String? _sessionId;
  String? _scenarioId;

  // Track if session is already initialized
  bool _sessionInitialized = false;

  // Debounce timer for storage saves
  Timer? _saveDebounceTimer;
  static const _saveDebounceDuration = Duration(milliseconds: 500);

  @override
  void onInit() {
    super.onInit();
    print('🎬 MessageScreenController initialized');
  }

  /// Set scenario data and initialize chat session
  /// ✅ SMART FLOW: Load from storage first (instant), then call API if new
  void setScenarioData(ScenarioData data) {
    print('═══════════════════════════════════════════');
    print('🎯 SET SCENARIO DATA');
    print('═══════════════════════════════════════════');

    // Check if switching to different scenario
    final isDifferentScenario = _scenarioId != null && _scenarioId != data.scenarioId;

    if (isDifferentScenario) {
      print('🔄 Different scenario - clearing previous session');
      _clearSession();
    }

    scenarioData = data;
    _scenarioId = data.scenarioId;

    print('📝 Scenario: ${data.scenarioTitle}');
    print('🔑 ID: $_scenarioId');
    print('📌 Source: ${data.sourceScreen}');

    // ✅ Initialize chat session with smart loading
    _initializeChatSession();

    print('═══════════════════════════════════════════');
  }

  /// Initialize chat session - handles both new and existing chats
  Future<void> _initializeChatSession() async {
    print('🔄 Initializing chat session...');

    // Step 1: Try to load existing session from storage (INSTANT)
    final hasStoredSession = await _loadSessionFromStorage();

    if (hasStoredSession) {
      // ✅ EXISTING CHAT - Messages loaded instantly
      print('📂 EXISTING CHAT: ${messages.length} messages loaded instantly');
      print('✅ Session ID: $_sessionId');
      print('✅ Ready for continue chat API');
      _sessionInitialized = true;
      isLoading.value = false;
      update();
      return;
    }

    // Step 2: No stored session - Start NEW chat with API
    print('🆕 NEW CHAT: No stored session found');
    print('🚀 Calling START CHAT API...');
    await _startNewChatSession();
  }

  /// Start a NEW chat session via API (only for new conversations)
  Future<void> _startNewChatSession() async {
    if (_scenarioId == null || _scenarioId!.isEmpty) {
      print('❌ No scenario ID - cannot start chat');
      isLoading.value = false;
      return;
    }

    // Check if already initialized
    if (_sessionInitialized && _sessionId != null) {
      print('✅ Session already active: $_sessionId');
      return;
    }

    try {
      isLoading.value = true;

      print('═══════════════════════════════════════════');
      print('📤 START CHAT API');
      print('═══════════════════════════════════════════');
      print('Scenario ID: $_scenarioId');

      // ✅ Call START CHAT API
      final response = await _apiServices.startChatSession(_scenarioId!);

      print('✅ START CHAT SUCCESS');
      print('📋 Session ID: ${response.sessionId}');

      // Save session ID
      _sessionId = response.sessionId;
      _sessionInitialized = true;

      // Extract welcome message
      final welcomeMessage = response.aiMessage.metadata?.rawAiResponse?.welcomeMessage;
      print('💬 Welcome: $welcomeMessage');

      if (welcomeMessage != null && welcomeMessage.isNotEmpty) {
        // Add welcome message to chat
        final messageId = DateTime.now().millisecondsSinceEpoch.toString();
        messages.add(ChatMessage(
          id: messageId,
          text: welcomeMessage,
          isUser: false,
          timestamp: DateTime.now(),
        ));

        print('✅ Welcome message added (ID: $messageId)');

        // ✅ Save to storage immediately (parallel, non-blocking)
        _saveSessionToStorageImmediate();
      }

      // ✅ Stop loading immediately - user can start typing now
      isLoading.value = false;
      print('✅ New chat session ready');
      print('═══════════════════════════════════════════');

    } catch (e) {
      print('❌ START CHAT ERROR: $e');
      isLoading.value = false;
      _handleStartChatError(e);
    }
  }

  /// Clear session data (used when switching scenarios)
  void _clearSession() {
    _sessionId = null;
    _sessionInitialized = false;
    messages.clear();

    // Clear from storage
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('chat_session_${_scenarioId}');
      prefs.remove('chat_messages_${_scenarioId}');
    });
  }

  /// Save current session to storage (debounced to prevent excessive saves)
  void _saveSessionToStorageDebounced() {
    // Cancel previous timer if exists
    _saveDebounceTimer?.cancel();

    // Set new timer
    _saveDebounceTimer = Timer(_saveDebounceDuration, () {
      _saveSessionToStorageImmediate();
    });
  }

  /// Save current session to storage immediately
  Future<void> _saveSessionToStorageImmediate() async {
    if (_scenarioId == null || _sessionId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Save session ID
      await prefs.setString('chat_session_$_scenarioId', _sessionId!);

      // Save messages
      final messagesJson = messages.map((msg) => {
        'id': msg.id,
        'text': msg.text,
        'isUser': msg.isUser,
        'timestamp': msg.timestamp.toIso8601String(),
      }).toList();

      await prefs.setString('chat_messages_$_scenarioId', jsonEncode(messagesJson));

      print('💾 Session saved to storage (${messages.length} messages)');
    } catch (e) {
      print('⚠️ Failed to save session: $e');
    }
  }

  /// Load session from storage
  Future<bool> _loadSessionFromStorage() async {
    if (_scenarioId == null) return false;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load session ID
      final savedSessionId = prefs.getString('chat_session_$_scenarioId');
      if (savedSessionId == null) return false;

      // Load messages
      final messagesJsonString = prefs.getString('chat_messages_$_scenarioId');
      if (messagesJsonString == null) return false;

      final messagesJson = jsonDecode(messagesJsonString) as List;
      final loadedMessages = messagesJson.map((json) => ChatMessage(
        id: json['id'],
        text: json['text'],
        isUser: json['isUser'],
        timestamp: DateTime.parse(json['timestamp']),
      )).toList();

      // Restore session
      _sessionId = savedSessionId;
      messages.assignAll(loadedMessages);

      print('📂 Loaded ${loadedMessages.length} messages from storage');
      return true;

    } catch (e) {
      print('⚠️ Failed to load session: $e');
      return false;
    }
  }

  @override
  void onClose() {
    // Cancel debounce timer and save immediately before closing
    _saveDebounceTimer?.cancel();
    if (_sessionId != null && _scenarioId != null) {
      _saveSessionToStorageImmediate();
    }
    
    messageController.dispose();
    super.onClose();
  }

  /// Send a message - handles session recovery and timeout
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // ✅ Session validation with auto-recovery
    if (_sessionId == null) {
      print('⚠️ No session ID - attempting recovery...');
      
      // Try to recover from storage
      final recovered = await _loadSessionFromStorage();
      
      if (!recovered) {
        // Still no session - start new one
        print('🆕 Creating new session...');
        await _startNewChatSession();
        
        // Retry if session is ready
        if (_sessionId != null) {
          return sendMessage();
        } else {
          _showErrorMessage('Error', 'Unable to start chat session. Please try again.');
          return;
        }
      }
    }

    try {
      // ✅ OPTIMISTIC UI UPDATE - Add user message immediately
      final userMessageId = DateTime.now().millisecondsSinceEpoch.toString();
      messages.add(ChatMessage(
        id: userMessageId,
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));

      // Clear input immediately for better UX
      messageController.clear();

      // Set sending state
      isSending.value = true;

      print('═══════════════════════════════════════════');
      print('📤 CONTINUE CHAT API');
      print('═══════════════════════════════════════════');
      print('Session ID: $_sessionId');
      print('Message: $text');

      // ✅ Call CONTINUE CHAT API (session_id in URL)
      final response = await _apiServices.sendChatMessage(_sessionId!, text);

      print('✅ CONTINUE CHAT SUCCESS');
      print('💬 AI Response: ${response.aiMessage.textContent}');

      // Add AI response
      final aiText = response.aiMessage.textContent;
      if (aiText.isNotEmpty) {
        final aiMessageId = DateTime.now().millisecondsSinceEpoch.toString();
        messages.add(ChatMessage(
          id: aiMessageId,
          text: aiText,
          isUser: false,
          timestamp: DateTime.now(),
        ));

        print('✅ AI message added (ID: $aiMessageId)');

        // ✅ Save to storage (debounced, non-blocking)
        _saveSessionToStorageDebounced();
      }

      isSending.value = false;
      print('✅ Message sent successfully');
      print('═══════════════════════════════════════════');

    } catch (e) {
      print('❌ SEND MESSAGE ERROR: $e');
      isSending.value = false;

      String errorMessage = e.toString().replaceAll('Exception: ', '');

      // ✅ Handle "Session is not active. Status: timeout"
      if (errorMessage.contains('Session is not active') || 
          errorMessage.contains('timeout') ||
          errorMessage.contains('No ChatSession matches')) {
        
        print('⚠️ SESSION TIMEOUT - Creating new session...');
        
        // Clear expired session
        _clearSession();
        
        _showWarningMessage(
          'Session Expired',
          'Starting a new conversation...',
        );

        // Start fresh session
        await _startNewChatSession();

        // Retry the message
        messageController.text = text;
        return sendMessage();
      }

      // ✅ Handle other errors
      _handleSendMessageError(errorMessage, text);
    }
  }

  /// Handle errors during send message
  void _handleSendMessageError(String errorMessage, String originalText) {
    String userFriendlyMessage = errorMessage;

    if (errorMessage.contains('scenario_not_found')) {
      userFriendlyMessage = 'This scenario is no longer available.';
      
      // Add system message
      final systemMessageId = DateTime.now().millisecondsSinceEpoch.toString();
      messages.add(ChatMessage(
        id: systemMessageId,
        text: '⚠️ This scenario is no longer available. Please return to home and select a different scenario.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      
    } else if (errorMessage.contains('Network error') || errorMessage.contains('SocketException')) {
      userFriendlyMessage = 'Network error. Please check your internet connection.';
      
    } else if (errorMessage.contains('taking too long') || errorMessage.contains('TIMED OUT')) {
      // Timeout - keep user message visible
      _showWarningMessage(
        'Slow Response',
        'AI is taking too long. Your message was sent - please wait.',
      );
      return; // Don't remove message
    }

    // Show error
    _showErrorMessage('Error', userFriendlyMessage);

    // Remove failed user message and restore text
    if (messages.isNotEmpty && messages.last.isUser) {
      messages.removeLast();
      messageController.clear();
      messageController.text = originalText;
      messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: originalText.length),
      );
    }
  }

  /// Handle errors during start chat
  void _handleStartChatError(dynamic e) {
    String errorMessage = e.toString().replaceAll('Exception: ', '');
    String userFriendlyMessage = errorMessage;

    if (errorMessage.contains('scenario_not_found') || 
        (errorMessage.contains('Scenario') && errorMessage.contains('not found'))) {
      userFriendlyMessage = 'This scenario is no longer available.';
      
      // Add error message to chat
      final systemMessageId = DateTime.now().millisecondsSinceEpoch.toString();
      messages.add(ChatMessage(
        id: systemMessageId,
        text: '⚠️ This scenario is no longer available.\n\nPlease return to home and select a different scenario.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      
    } else if (errorMessage.contains('Session expired') || errorMessage.contains('401')) {
      userFriendlyMessage = 'Your session has expired. Please log in again.';
      
    } else if (errorMessage.contains('Network error') || errorMessage.contains('SocketException')) {
      userFriendlyMessage = 'Unable to connect. Please check your internet connection.';
      
    } else {
      userFriendlyMessage = 'Failed to start conversation. Please try again.';
    }

    _showErrorMessage('Error', userFriendlyMessage);
  }

  /// Show error message to user
  void _showErrorMessage(String title, String message) {
    try {
      if (Get.context != null) {
        CustomSnackbar.error(
          context: Get.context!,
          title: title,
          message: message,
        );
      }
    } catch (e) {
      print('⚠️ Could not show error snackbar: $e');
    }
  }

  /// Show warning message to user
  void _showWarningMessage(String title, String message) {
    try {
      if (Get.context != null) {
        CustomSnackbar.warning(
          context: Get.context!,
          title: title,
          message: message,
        );
      }
    } catch (e) {
      print('⚠️ Could not show warning snackbar: $e');
    }
  }

  /// Navigate to voice chat
  void toggleRecording(BuildContext context) {
    context.push(AppPath.voiceChat, extra: scenarioData);
  }

  /// Handle back navigation
  void goBack(BuildContext context) {
    // Determine target tab based on source screen
    int targetTabIndex = scenarioData?.sourceScreen == 'history' ? 1 : 0;
    
    // Set tab and refresh if needed
    final navBarController = Get.find<NavBarController>();
    navBarController.returnToTab(targetTabIndex);
    
    if (targetTabIndex == 1) {
      try {
        Get.find<HistoryController>().refreshHistoryData();
      } catch (_) {}
    }
    
    context.pop();
  }
}

/// Chat Message Model
class ChatMessage {
  final String id; // Unique identifier for each message
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// Extension for refresh functionality
extension MessageScreenControllerRefresh on MessageScreenController {
  /// Refresh message screen data - called by pull-to-refresh
  /// ✅ FIXED: Don't clear messages on refresh, just save and sync
  Future<void> refreshMessageData() async {
    print('');
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║          REFRESHING MESSAGE SCREEN DATA                    ║');
    print('╚═══════════════════════════════════════════════════════════╝');

    try {
      // ✅ First, save current messages to storage (preserve them!)
      if (_sessionId != null && _scenarioId != null && messages.isNotEmpty) {
        print('💾 Saving ${messages.length} messages before refresh...');
        await _saveSessionToStorageImmediate();
      }

      // ✅ Don't clear or reload messages - they're already in memory!
      // Just trigger UI update
      print('🔄 Messages preserved: ${messages.length} messages');
      print('✅ Refresh complete - messages are safe!');
      print('═══════════════════════════════════════════════════════════');
    } catch (e) {
      print('❌ Error in refresh: $e');
      print('═══════════════════════════════════════════════════════════');
    }
  }
}