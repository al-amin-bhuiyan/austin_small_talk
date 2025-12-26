import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/app_route/app_path.dart';

/// Voice Chat Controller - Handles voice interactions with AI
class VoiceChatController extends GetxController {
  // Speech to Text
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  // Observable states
  final isListening = false.obs;
  final isProcessing = false.obs;
  final isSpeaking = false.obs;
  final recognizedText = ''.obs;
  final messages = <ChatMessage>[].obs;
  
  // Wave animation properties
  final scale = 1.0.obs;
  final amplitude = 4250.0.obs;
  
  Timer? _animationTimer;
  
  @override
  void onInit() {
    super.onInit();
    _initializeSpeech();
    _initializeTts();
  }
  
  /// Initialize Speech to Text
  Future<void> _initializeSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
            _stopAnimation();
            if (recognizedText.value.isNotEmpty) {
              _processUserMessage();
            }
          }
        },
        onError: (error) {
          print('Speech error: $error');
          isListening.value = false;
          _stopAnimation();
        },
      );
      
      if (!available) {
        print('Speech recognition not available');
      }
    } catch (e) {
      print('Error initializing speech: $e');
    }
  }
  
  /// Initialize Text to Speech
  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setStartHandler(() {
      isSpeaking.value = true;
    });
    
    _flutterTts.setCompletionHandler(() {
      isSpeaking.value = false;
    });
    
    _flutterTts.setErrorHandler((msg) {
      isSpeaking.value = false;
      print('TTS Error: $msg');
    });
  }
  
  /// Start listening to user voice
  Future<void> startListening() async {
    if (!isListening.value) {
      recognizedText.value = '';
      isListening.value = true;
      _startAnimation();
      
      await _speech.listen(
        onResult: (result) {
          recognizedText.value = result.recognizedWords;
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
        ),
      );
    }
  }
  
  /// Stop listening
  Future<void> stopListening() async {
    if (isListening.value) {
      await _speech.stop();
      isListening.value = false;
      _stopAnimation();
      
      if (recognizedText.value.isNotEmpty) {
        _processUserMessage();
      }
    }
  }
  
  /// Toggle listening state
  Future<void> toggleListening() async {
    if (isListening.value) {
      await stopListening();
    } else {
      await startListening();
    }
  }
  
  /// Process user message and generate AI response
  Future<void> _processUserMessage() async {
    if (recognizedText.value.trim().isEmpty) return;
    
    // Add user message
    messages.add(ChatMessage(
      text: recognizedText.value,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    
    String userText = recognizedText.value;
    recognizedText.value = '';
    
    // Show processing state
    isProcessing.value = true;
    
    // Simulate AI thinking
    await Future.delayed(Duration(seconds: 1));
    
    // Generate dummy AI response
    String aiResponse = _generateAIResponse(userText);
    
    // Add AI message
    messages.add(ChatMessage(
      text: aiResponse,
      isUser: false,
      timestamp: DateTime.now(),
    ));
    
    isProcessing.value = false;
    
    // Speak the AI response
    await _speakText(aiResponse);
  }
  
  /// Generate dummy AI response
  String _generateAIResponse(String userText) {
    // Simple response generation based on keywords
    String lowerText = userText.toLowerCase();
    
    if (lowerText.contains('hello') || lowerText.contains('hi')) {
      return "Hello! How can I help you today?";
    } else if (lowerText.contains('how are you')) {
      return "I'm doing great, thank you for asking! How about you?";
    } else if (lowerText.contains('work') || lowerText.contains('job')) {
      return "That sounds interesting! Tell me more about your work.";
    } else if (lowerText.contains('name')) {
      return "I'm your AI assistant. You can call me Small Talk AI.";
    } else if (lowerText.contains('help')) {
      return "I'm here to help you practice small talk conversations. Just speak naturally!";
    } else {
      return "That's interesting! Can you tell me more about that?";
    }
  }
  
  /// Speak text using TTS
  Future<void> _speakText(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('Error speaking: $e');
    }
  }
  
  /// Start wave animation
  void _startAnimation() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      // Animation is handled by WaveBlob widget
      update();
    });
  }
  
  /// Stop wave animation
  void _stopAnimation() {
    _animationTimer?.cancel();
  }
  
  /// Navigate back to AI Talk
  void goBack(BuildContext context) {
    stopListening();
    context.go(AppPath.aitalk);
  }
  
  @override
  void onClose() {
    _animationTimer?.cancel();
    _speech.cancel();
    _flutterTts.stop();
    super.onClose();
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
