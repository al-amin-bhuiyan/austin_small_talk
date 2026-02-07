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
    print('🎬 AiTalkController.onInit() - Starting animation immediately');
    // Start animation immediately - trigger first update in next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimationTimer();
    });
  }

  void _onTextChanged() {
    hasText.value = textController.text.trim().isNotEmpty;
    print('🔷 Text changed: "${textController.text}" | hasText: ${hasText.value}');
  }

  void _onFocusChanged() {
    print('🔷 Focus changed: hasFocus: ${textFocusNode.hasFocus}');
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

  /// Navigate to create scenario screen
  void goToCreateScenario(BuildContext context) {
    context.push(AppPath.createScenario);
  }

  void _startAnimationTimer() {
    print('⚡ Starting WaveBlob animation timer');
    // Trigger first update immediately
    update(['waveBlob']);
    print('✅ First animation frame rendered');

    // Then continue with periodic updates at 150ms intervals for smoother animation
    _animationTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      update(['waveBlob']);
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

  /// Refresh AI Talk screen - restart animation
  Future<void> refreshData() async {
    print('🔄 Refreshing AI Talk screen...');
    
    // Restart animation
    _animationTimer?.cancel();
    await Future.delayed(const Duration(milliseconds: 100));
    _startAnimationTimer();
    
    print('✅ AI Talk refresh complete');
  }
}

class AiTalkBlobController extends GetxController {
  final RxBool isAnimating = false.obs;
  final RxDouble blobScale = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    _startBlobAnimation();
  }

  void _startBlobAnimation() {
    isAnimating.value = true;
    _animateBlob();
  }

  Future<void> _animateBlob() async {
    while (isAnimating.value) {
      blobScale.value = 1.1;
      await Future.delayed(const Duration(milliseconds: 1500));

      blobScale.value = 1.0;
      await Future.delayed(const Duration(milliseconds: 1500));
    }
  }

  void stopAnimation() {
    isAnimating.value = false;
    blobScale.value = 1.0;
  }

  @override
  void onClose() {
    stopAnimation();
    super.onClose();
  }
}