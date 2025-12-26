import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controller for Message Screen - handles chat messages and interactions
class MessageScreenController extends GetxController {
  // Observable list of messages
  final messages = <ChatMessage>[].obs;
  
  // Text editing controller for input field
  final TextEditingController messageController = TextEditingController();
  
  // Observable for loading state
  final isLoading = false.obs;
  
  // Observable for recording state
  final isRecording = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load initial demo messages
    _loadDemoMessages();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  /// Load demo messages for the conversation
  void _loadDemoMessages() {
    messages.addAll([
      ChatMessage(
        text: "I'm traveling for work.",
        isUser: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      ),
      ChatMessage(
        text: "Nice. What kind of work do you do?",
        isUser: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 4)),
      ),
      ChatMessage(
        text: "I'm a designer.",
        isUser: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 3)),
      ),
      ChatMessage(
        text: "That sounds interesting. Are you working on any project right now that you're excited about?",
        isUser: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 2)),
      ),
      ChatMessage(
        text: "Yes, I'm working on a mobile app.",
        isUser: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 1)),
      ),
      ChatMessage(
        text: "Very cool. What part of designing mobile apps do you enjoy the most?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ]);
  }

  /// Send a text message
  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    // Clear input field
    messageController.clear();

    // Simulate AI response after a delay
    Future.delayed(Duration(seconds: 1), () {
      _simulateAIResponse(text);
    });
  }

  /// Simulate AI response (replace with actual API call)
  void _simulateAIResponse(String userMessage) {
    // Add AI response
    messages.add(ChatMessage(
      text: "That's interesting! Tell me more about that.",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  /// Toggle voice recording
  void toggleRecording() {
    isRecording.value = !isRecording.value;
    
    if (isRecording.value) {
      // Start recording
      _startRecording();
    } else {
      // Stop recording
      _stopRecording();
    }
  }

  /// Start voice recording
  void _startRecording() {
    // Implement voice recording logic here
    print('Started recording...');
  }

  /// Stop voice recording
  void _stopRecording() {
    // Implement stop recording logic here
    print('Stopped recording...');
  }

  /// Handle back button press
  void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}

/// Chat Message Model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
