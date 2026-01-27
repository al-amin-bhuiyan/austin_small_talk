import 'dart:convert';
import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:austin_small_talk/data/global/scenario_data.dart';
import 'package:austin_small_talk/service/auth/api_service/api_services.dart';
import 'package:austin_small_talk/service/auth/api_constant/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller for Message Screen - handles chat messages and interactions
class MessageScreenController extends GetxController {
  // API Service
  final ApiServices _apiServices = ApiServices();
  
  // Observable list of messages
  final messages = <ChatMessage>[].obs;
  
  // Track the latest AI message ID for animation
  final latestAiMessageId = ''.obs;
  
  // Track which messages have already been animated (to prevent re-animation on scroll)
  final animatedMessageIds = <String>{}.obs;
  
  // Text editing controller for input field
  final TextEditingController messageController = TextEditingController();
  
  // Observable for loading state
  final isLoading = false.obs;
  
  // Observable for sending message state
  final isSending = false.obs;
  
  // User profile image
  final userProfileImage = ''.obs;
  
  // Scenario data
  ScenarioData? scenarioData;
  
  // Session ID from API
  String? _sessionId;
  String? _scenarioId;
  
  // Track if session is already initialized to prevent duplicate API calls
  bool _sessionInitialized = false;

  @override
  void onInit() {
    super.onInit();
    print('🎬 MessageScreenController initialized');
    
    // Fetch user profile to get profile image
    _fetchUserProfile();
  }

  /// Fetch user profile to get profile image
  Future<void> _fetchUserProfile() async {
    try {
      print('═══════════════════════════════════════════');
      print('👤 Fetching user profile for message screen');
      print('═══════════════════════════════════════════');
      
      // Get access token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access');
      
      if (accessToken == null || accessToken.isEmpty) {
        print('⚠️ No access token found, skipping profile fetch');
        print('   Using default avatar image');
        return;
      }
      
      print('✅ Access token found, fetching profile...');
      
      // Fetch user profile
      final profile = await _apiServices.getUserProfile(accessToken: accessToken);
      
      print('✅ Profile fetched successfully');
      print('   Name: ${profile.name}');
      print('   Image: ${profile.image}');
      
      // Set user profile image with full URL
      if (profile.image != null && profile.image!.isNotEmpty) {
        final fullImageUrl = profile.getFullImageUrl(ApiConstant.baseUrl);
        if (fullImageUrl != null && fullImageUrl.isNotEmpty) {
          userProfileImage.value = fullImageUrl;
          print('✅ User profile image URL set: $fullImageUrl');
        } else {
          print('⚠️ Image URL is empty after getFullImageUrl()');
          print('   Using default avatar');
        }
      } else {
        print('⚠️ No profile image in API response');
        print('   Using default avatar');
      }
      
      print('═══════════════════════════════════════════');
    } catch (e, stackTrace) {
      print('');
      print('❌❌❌ ERROR FETCHING USER PROFILE ❌❌❌');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('═══════════════════════════════════════════');
      // Don't show error to user, just use default image
    }
  }

  /// Manual test method to verify API is working
  Future<void> testApiCall() async {
    print('═══════════════════════════════════════════');
    print('🧪 TEST API CALL');
    print('═══════════════════════════════════════════');
    
    try {
      final testScenarioId = 'scenario_19751c5d'; // Use a known scenario ID
      print('📤 Testing with scenario ID: $testScenarioId');
      
      final response = await _apiServices.startChatSession(testScenarioId);
      
      print('✅ TEST API CALL SUCCESS!');
      print('Session ID: ${response.sessionId}');
      print('Welcome: ${response.aiMessage.metadata?.rawAiResponse?.welcomeMessage}');
      
    } catch (e) {
      print('❌ TEST API CALL FAILED: $e');
    }
    
    print('═══════════════════════════════════════════');
  }

  /// Set scenario data and start chat session
  void setScenarioData(ScenarioData data) {
    print('═══════════════════════════════════════════');
    print('🎯 SET SCENARIO DATA CALLED');
    print('═══════════════════════════════════════════');
    
    // Check if this is a different scenario than the current one
    final isDifferentScenario = _scenarioId != null && _scenarioId != data.scenarioId;
    
    if (isDifferentScenario) {
      print('🔄 DIFFERENT SCENARIO DETECTED');
      print('   Previous: $_scenarioId');
      print('   New: ${data.scenarioId}');
      print('   Clearing previous session...');
      
      // Clear previous session data
      _clearSession();
    }
    
    scenarioData = data;
    _scenarioId = data.scenarioId;
    
    print('📝 Scenario title: ${data.scenarioTitle}');
    print('🔑 Scenario ID: $_scenarioId');
    print('═══════════════════════════════════════════');
    
    // Try to load existing session first
    _loadSessionFromStorage().then((loaded) {
      if (loaded) {
        print('✅ Loaded existing session from storage');
        _sessionInitialized = true;
      } else {
        print('🚀 No existing session - starting new chat');
        _startChatSession();
      }
    });
  }

  /// Clear session data (used when switching scenarios)
  void _clearSession() {
    _sessionId = null;
    _sessionInitialized = false;
    messages.clear();
    latestAiMessageId.value = '';
    animatedMessageIds.clear();
    
    // Clear from storage
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('chat_session_${_scenarioId}');
      prefs.remove('chat_messages_${_scenarioId}');
    });
  }

  /// Save current session to storage
  Future<void> _saveSessionToStorage() async {
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
      
      // Mark all messages as already animated
      for (var msg in loadedMessages) {
        if (!msg.isUser) {
          animatedMessageIds.add(msg.id);
        }
      }
      
      print('📂 Loaded ${loadedMessages.length} messages from storage');
      return true;
      
    } catch (e) {
      print('⚠️ Failed to load session: $e');
      return false;
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  /// Start a new chat session with the scenario (with retry logic)
  Future<void> _startChatSession({int retryCount = 0}) async {
    const maxRetries = 2; // Will try 3 times total (initial + 2 retries)
    const retryDelayMs = [1000, 2000]; // 1s, then 2s delays
    
    print('═══════════════════════════════════════════');
    print('🎬 _startChatSession() METHOD CALLED (Attempt ${retryCount + 1}/${maxRetries + 1})');
    print('═══════════════════════════════════════════');
    
    // Check if already initialized
    if (_sessionInitialized && _sessionId != null) {
      print('✅ Session already initialized - skipping API call');
      print('   Session ID: $_sessionId');
      print('   Messages: ${messages.length}');
      return;
    }
    
    print('🔍 _scenarioId value: "$_scenarioId"');
    print('═══════════════════════════════════════════');
    
    if (_scenarioId == null || _scenarioId!.isEmpty) {
      print('❌ No scenario ID available - EXITING METHOD');
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      
      print('🚀 Starting chat session with scenario: $_scenarioId');
      
      // Call API to start chat session
      final response = await _apiServices.startChatSession(_scenarioId!);
      
      print('✅ Chat session started successfully');
      print('📋 Session ID: ${response.sessionId}');
      
      // Save session ID
      _sessionId = response.sessionId;
      _sessionInitialized = true;
      
      // Extract welcome message from metadata
      final welcomeMessage = response.aiMessage.metadata?.rawAiResponse?.welcomeMessage;
      
      print('💬 Welcome message: $welcomeMessage');
      
      if (welcomeMessage != null && welcomeMessage.isNotEmpty) {
        // Generate unique ID for this message
        final messageId = DateTime.now().millisecondsSinceEpoch.toString();
        
        // Add AI welcome message to chat
        messages.add(ChatMessage(
          id: messageId,
          text: welcomeMessage,
          isUser: false,
          timestamp: DateTime.parse(response.aiMessage.createdAt),
        ));
        
        // Mark this as the latest AI message for animation
        latestAiMessageId.value = messageId;
        
        print('✅ Welcome message added to chat with ID: $messageId');
        
        // Save session to storage
        await _saveSessionToStorage();
      }
      
      isLoading.value = false;
      
    } catch (e, stackTrace) {
      print('❌ Error starting chat session: $e');
      print('📍 Stack trace: $stackTrace');
      
      // Parse error message
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      // Check if this is a 503 error that we should retry
      final is503Error = errorMessage.contains('Unable to initialize chat with AI service') || 
                         errorMessage.contains('503') || 
                         errorMessage.contains('Service Unavailable');
      
      if (is503Error && retryCount < maxRetries) {
        // Retry after delay
        final delayMs = retryDelayMs[retryCount];
        print('🔄 Retrying in ${delayMs}ms... (Attempt ${retryCount + 2}/${maxRetries + 1})');
        
        await Future.delayed(Duration(milliseconds: delayMs));
        
        // Retry the request
        return _startChatSession(retryCount: retryCount + 1);
      }
      
      // If we've exhausted retries or it's a different error, show error to user
      isLoading.value = false;
      String userFriendlyMessage = errorMessage;
      
      // Check for specific error types
      if (errorMessage.contains('scenario_not_found') || errorMessage.contains('Scenario') && errorMessage.contains('not found')) {
        userFriendlyMessage = 'This scenario is no longer available. It may have been removed or updated.';
        print('⚠️ SCENARIO NOT FOUND ERROR - This scenario has been deleted or is invalid');
        
        // Add error message to chat
        final systemMessageId = DateTime.now().millisecondsSinceEpoch.toString();
        messages.add(ChatMessage(
          id: systemMessageId,
          text: '⚠️ This scenario is no longer available.\n\nPlease return to the home screen and select a different scenario to start a new conversation.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        latestAiMessageId.value = systemMessageId;
      } else if (errorMessage.contains('Session expired') || errorMessage.contains('401')) {
        userFriendlyMessage = 'Your session has expired. Please log in again.';
      } else if (errorMessage.contains('Network error') || errorMessage.contains('SocketException')) {
        userFriendlyMessage = 'Unable to connect to server. Please check your internet connection.';
      } else {
        userFriendlyMessage = 'Failed to start conversation. Please try again.';
      }
      
      // Show error to user (wrapped in try-catch to prevent snackbar crashes)
      try {
        Get.snackbar(
          'Error',
          userFriendlyMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: Duration(seconds: 4),
          margin: EdgeInsets.all(16),
        );
      } catch (snackbarError) {
        print('⚠️ Could not show snackbar: $snackbarError');
      }
    }
  }

  /// Send a text message
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // Check if session is started
    if (_sessionId == null) {
      print('❌ No active session');
      try {
        Get.snackbar(
          'Error',
          'Chat session not started. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } catch (e) {
        print('⚠️ Could not show snackbar: $e');
      }
      return;
    }

    try {
      // Add user message to UI immediately
      messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));

      // Clear input field
      messageController.clear();

      // Set sending state
      isSending.value = true;

      print('📤 Sending message: $text');
      print('🔑 Session ID: $_sessionId');

      // Call API to send message (session_id is in URL, not body)
      final response = await _apiServices.sendChatMessage(
        _sessionId!,
        text,
      );

      print('✅ Message sent successfully');
      print('💬 AI Response: ${response.aiMessage.textContent}');

      // Add AI response to chat
      final aiText = response.aiMessage.textContent;
      if (aiText.isNotEmpty) {
        // Generate unique ID for this message
        final messageId = DateTime.now().millisecondsSinceEpoch.toString();
        
        messages.add(ChatMessage(
          id: messageId,
          text: aiText,
          isUser: false,
          timestamp: DateTime.parse(response.aiMessage.createdAt),
        ));
        
        // Mark this as the latest AI message for animation
        latestAiMessageId.value = messageId;
        
        print('✅ AI message added with ID: $messageId (will animate)');
        
        // Save messages to storage
        await _saveSessionToStorage();
      }

      isSending.value = false;

    } catch (e) {
      print('❌ Error sending message: $e');
      isSending.value = false;

      // Parse error message
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      String userFriendlyMessage = errorMessage;
      
      // Check for specific error types
      if (errorMessage.contains('scenario_not_found') || errorMessage.contains('Scenario') && errorMessage.contains('not found')) {
        userFriendlyMessage = 'This scenario is no longer available. Please go back and select a different scenario.';
        print('⚠️ SCENARIO NOT FOUND ERROR - Scenario may have been deleted or is invalid');
        
        // Add system message to chat
        final systemMessageId = DateTime.now().millisecondsSinceEpoch.toString();
        messages.add(ChatMessage(
          id: systemMessageId,
          text: '⚠️ This scenario is no longer available. Please return to the home screen and select a different scenario to start a new conversation.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        latestAiMessageId.value = systemMessageId;
      } else if (errorMessage.contains('Session expired') || errorMessage.contains('401')) {
        userFriendlyMessage = 'Your session has expired. Please log in again.';
      } else if (errorMessage.contains('Network error') || errorMessage.contains('SocketException')) {
        userFriendlyMessage = 'Network error. Please check your internet connection and try again.';
      }

      // Show error to user
      try {
        Get.snackbar(
          'Error',
          userFriendlyMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: Duration(seconds: 4),
          margin: EdgeInsets.all(16),
        );
      } catch (snackbarError) {
        print('⚠️ Could not show snackbar: $snackbarError');
      }

      // Remove the user message if it failed (except for scenario not found)
      if (messages.isNotEmpty && messages.last.isUser && !errorMessage.contains('scenario_not_found')) {
        messages.removeLast();
        // Restore the text to input field only if not scenario error
        messageController.text = text;
      }
    }
  }

  /// Navigate to voice chat
  void toggleRecording(BuildContext context) {
    // Pass scenario data to voice chat
    context.push(AppPath.voiceChat, extra: scenarioData);
  }

  /// Handle back button press - Smart navigation based on source screen
  void goBack(BuildContext context) {
    print('');
    print('╔═══════════════════════════════════════════╗');
    print('║     BACK BUTTON PRESSED - MESSAGE SCREEN   ║');
    print('╚═══════════════════════════════════════════╝');
    print('📍 Current location: ${GoRouterState.of(context).uri.path}');
    print('🔍 Can pop: ${context.canPop()}');
    print('📌 Source screen: ${scenarioData?.sourceScreen ?? "not set"}');
    
    // Determine where to navigate based on source screen
    String targetRoute;
    
    if (scenarioData?.sourceScreen != null) {
      // Use the tracked source screen
      switch (scenarioData!.sourceScreen) {
        case 'home':
          targetRoute = AppPath.home;
          print('🏠 Returning to Home (source: home)');
          break;
        case 'history':
          targetRoute = AppPath.history;
          print('📜 Returning to History (source: history)');
          break;
        case 'create_scenario':
          targetRoute = AppPath.history; // Created scenarios shown in history
          print('🎨 Returning to History (source: create_scenario)');
          break;
        default:
          targetRoute = AppPath.home;
          print('🏠 Returning to Home (unknown source: ${scenarioData!.sourceScreen})');
      }
    } else {
      // Fallback to Home if no source screen is tracked
      targetRoute = AppPath.home;
      print('🏠 Returning to Home (no source screen tracked)');
    }
    
    print('🎯 Target route: $targetRoute');
    context.go(targetRoute);
    
    print('✅ Navigation completed');
    print('═══════════════════════════════════════════');
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
