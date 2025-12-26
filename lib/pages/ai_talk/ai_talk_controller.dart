import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_route/app_path.dart';

class AiTalkController extends GetxController {
  var isListening = false.obs;
  var isProcessing = false.obs;
  var inputText = ''.obs;
  var hasText = false.obs; // Track if text field has text
  var showNavBar = true.obs; // Track nav bar visibility
  
  // TextEditingController for the input field
  final TextEditingController textController = TextEditingController();
  final FocusNode textFocusNode = FocusNode();
  
  // WaveBlob animation properties - keep these relatively stable
  double waveScale = 1.0;
  double waveAmplitude = 4250.0;
  bool autoScale = true;
  
  Timer? _animationTimer;

  @override
  void onInit() {
    super.onInit();
    // Listen to text changes
    textController.addListener(_onTextChanged);
    // Listen to focus changes
    textFocusNode.addListener(_onFocusChanged);
    // Start animation timer for WaveBlob
    _startAnimationTimer();
  }

  void _onTextChanged() {
    hasText.value = textController.text.trim().isNotEmpty;
  }

  void _onFocusChanged() {
    // Hide nav bar and show bottom input when text field is focused
    if (textFocusNode.hasFocus) {
      showNavBar.value = false;
    } else {
      // Show nav bar when text field loses focus and is empty
      if (!hasText.value) {
        showNavBar.value = true;
      }
    }
  }

  void startListening() {
    isListening.value = true;
    // TODO: Implement voice recording logic
  }

  void stopListening() {
    isListening.value = false;
    // TODO: Stop voice recording
  }

  void toggleListening() {
    if (isListening.value) {
      stopListening();
    } else {
      startListening();
    }
  }

  void sendMessage(String message, {BuildContext? context}) {
    if (message.trim().isEmpty) return;
    inputText.value = message;
    
    // Clear the text field after sending
    textController.clear();
    
    // Remove focus and show nav bar
    textFocusNode.unfocus();
    showNavBar.value = true;
    
    // Navigate to message screen to start conversation
    if (context != null) {
      context.push(AppPath.messageScreen);
    }
  }
  
  /// Send message from text field
  void onSendPressed(BuildContext context) {
    final message = textController.text.trim();
    if (message.isNotEmpty) {
      sendMessage(message, context: context);
    }
  }
  
  /// Navigate to voice chat screen
  void goToVoiceChat(BuildContext context) {
    context.push(AppPath.voiceChat);
  }
  
  /// Navigate to message screen
  void goToMessageScreen(BuildContext context) {
    context.push(AppPath.messageScreen);
  }

  void _startAnimationTimer() {
    _animationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // Just trigger rebuild - WaveBlob handles animation internally
      update();
    });
  }

  @override
  void onClose() {
    stopListening();
    textController.removeListener(_onTextChanged);
    textFocusNode.removeListener(_onFocusChanged);
    textController.dispose();
    textFocusNode.dispose();
    _animationTimer?.cancel();
    super.onClose();
  }
}
