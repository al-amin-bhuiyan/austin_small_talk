import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:austin_small_talk/data/global/scenario_data.dart';
import 'package:austin_small_talk/data/global/shared_preference.dart';
import 'package:austin_small_talk/pages/ai_talk/voice_chat/ws/voice_ws_client.dart';
import 'package:austin_small_talk/service/auth/api_constant/api_constant.dart';
import 'package:austin_small_talk/service/auth/api_service/api_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:siri_wave/siri_wave.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../service/auth/models/user_profile_response_model.dart';
import 'audio/audio_session_config.dart';
import 'audio/barge_in_detector.dart';
import 'audio/mic_streamer.dart';
import 'audio/tts_player.dart';

/// Voice Chat Controller - WebSocket-based voice interaction with AI
class VoiceChatController extends GetxController {
  // Session ID - generated once per controller instance
  final String sessionId = const Uuid().v4();
  final _wsClient = VoiceWsClient();

  // WebSocket
  WebSocketChannel? _channel;
  StreamSubscription? _wsSub;
  final userProfileImage = Rxn<String>();

  // Audio components
  MicStreamer? _micStreamer;
  TtsPlayer? _ttsPlayer;
  BargeInDetector? _bargeInDetector;

  // Siri Wave Controller
  final IOS9SiriWaveformController siriController = IOS9SiriWaveformController(
    amplitude: 0.5,
    speed: 0.2,
  );

  // Observable states
  final isMicOn = false.obs;
  final isProcessing = false.obs;
  final isSpeaking = false.obs;
  final isConnected = false.obs;
  final isSessionReady = false.obs;
  final recognizedText = ''.obs;
  final messages = <ChatMessage>[].obs;
  final currentAmplitude = 0.5.obs;

  // Subscriptions
  StreamSubscription? _micSub;

  // Scenario data
  ScenarioData? scenarioData;

  // Animation timer
  Timer? _animationTimer;

  @override
  void onInit() {
    print('═══════════════════════════════════════════════════════════');
    print('🚀 VoiceChatController.onInit() - Controller Initializing');
    print('═══════════════════════════════════════════════════════════');
    super.onInit();
    _startContinuousAnimation();
    print('✅ onInit() complete - Animation started');
    print('💡 WebSocket will connect when page appears (onReady)');
    _loadUserProfileImage();

  }

  @override
  void onReady() {
    print('═══════════════════════════════════════════════════════════');
    print('🎯 VoiceChatController.onReady() - Page Appeared');
    print('═══════════════════════════════════════════════════════════');
    super.onReady();
    // Initialize audio components and connect WebSocket when page appears
    _initializeVoiceChat();
    print('✅ onReady() complete - Voice chat initializing');
  }

  /// Called when page reappears after being hidden (e.g., after back button)
  void onResumed() {
    print('');
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║         PAGE RESUMED - CHECKING CONNECTION STATE          ║');
    print('╚═══════════════════════════════════════════════════════════╝');

    // Check if WebSocket is disconnected and needs reconnection
    if (!isConnected.value) {
      print('⚠️  WebSocket disconnected - reconnecting...');
      _initializeVoiceChat();
    } else {
      print('✅ WebSocket still connected - no action needed');
    }
  }

  @override
  void onClose() {
    print('');
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║       VOICE CHAT PAGE CLOSING - CLEANUP STARTING          ║');
    print('╚═══════════════════════════════════════════════════════════╝');
    // Cleanup everything when page closes
    _cleanup();
    super.onClose();
    print('✅ Controller disposed - All resources cleaned');
    print('═══════════════════════════════════════════════════════════');
  }

  void setScenarioData(ScenarioData data) {
    print('═══════════════════════════════════════════════════════════');
    print('📋 Setting Scenario Data:');
    print('   Title: ${data.scenarioTitle}');
    print('   ID: ${data.scenarioId}');
    print('   Difficulty: ${data.difficulty}');

    // Check if this is a different scenario than the current one
    final isDifferentScenario = scenarioData != null &&
                                scenarioData!.scenarioId != data.scenarioId;

    if (isDifferentScenario) {
      print('🔄 DIFFERENT SCENARIO DETECTED IN VOICE CHAT');
      print('   Previous: ${scenarioData!.scenarioId}');
      print('   New: ${data.scenarioId}');
      print('   Clearing previous messages...');

      // Clear previous chat messages
      messages.clear();
      print('   ✅ Messages cleared (${messages.length} remaining)');
    } else if (scenarioData != null && scenarioData!.scenarioId == data.scenarioId) {
      print('✅ Same scenario - keeping existing messages (${messages.length} messages)');
    } else {
      print('🆕 First time setting scenario data');
    }

    print('═══════════════════════════════════════════════════════════');
    scenarioData = data;
  }

  Future<void> _initializeVoiceChat() async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🎬 INITIALIZING VOICE CHAT (PAGE APPEARED)');
    print('═══════════════════════════════════════════════════════════');

    try {
      print('📦 Step 1/4: Configuring Audio Session');
      await AudioSessionConfigHelper.configureForVoiceChat();
      print('   ✅ Audio session configured');

      print('📦 Step 2/4: Creating TTS Player');
      _ttsPlayer = TtsPlayer(sampleRate: 24000, numChannels: 1);
      await _ttsPlayer!.init();
      print('   ✅ TTS Player created (16kHz, mono)');

      print('📦 Step 3/4: Creating Barge-in Detector');
      _bargeInDetector = BargeInDetector(threshold: 0.15, requiredFrames: 3);
      print('   ✅ Barge-in detector created (threshold: 0.15, frames: 3)');

      print('📦 Step 4/4: Connecting to WebSocket Server');
      await _connectToWebSocket();

      print('');
      print('✅✅✅ VOICE CHAT READY - PAGE IS ACTIVE ✅✅✅');
      print('💡 Mic will start when user presses the mic button');
      print('═══════════════════════════════════════════════════════════');
    } catch (e, stackTrace) {
      print('');
      print('❌❌❌ INITIALIZATION FAILED ❌❌❌');
      print('Error: $e');
      print('Stack trace:');
      print(stackTrace);
      print('═══════════════════════════════════════════════════════════');
      _showError('Failed to initialize voice chat: $e');
    }
  }

  String _buildWsUrl() {
    // Use voice chat WebSocket URL from API constants (voice server: ws://10.10.7.114:8000/ws/chat)
    final accessToken = SharedPreferencesUtil.getAccessToken() ?? '';
    return '${ApiConstant.voiceChatWs}?token=$accessToken';
  }

  Future<void> _connectToWebSocket() async {
    print('');
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║        CONNECTING TO WEBSOCKET (PAGE APPEARED)            ║');
    print('╚═══════════════════════════════════════════════════════════╝');

    try {
      final wsUrl = _buildWsUrl();
      print('🔌 WebSocket URL: $wsUrl');
      print('📍 Connecting...');

      // Create WebSocket connection
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      print('✅ WebSocket channel created');

      print('👂 Setting up message listener...');
      _wsSub = _channel!.stream.listen(
        (msg) {
          print('📥 Message received from server');
          _handleWebSocketMessage(msg);
        },
        onError: (error) {
          print('');
          print('❌❌❌ WEBSOCKET ERROR ❌❌❌');
          print('Error: $error');
          print('═══════════════════════════════════════════════════════════');
          isConnected.value = false;
        },
        onDone: () {
          print('');
          print('🔌 WebSocket connection closed (page may have closed)');
          print('═══════════════════════════════════════════════════════════');
          isConnected.value = false;
        },
      );
      print('✅ Message listener active');

      isConnected.value = true;
      print('');
      print('╔═══════════════════════════════════════════════════════════╗');
      print('║      ✅ WEBSOCKET CONNECTED - READY FOR VOICE CHAT ✅     ║');
      print('╚═══════════════════════════════════════════════════════════╝');
      print('📋 Session ID: $sessionId');
      print('🎤 Press mic button to start talking');
      print('═══════════════════════════════════════════════════════════');
    } catch (e) {
      print('❌ WebSocket connection failed: $e');
      throw Exception('Failed to connect to voice server');
    }
  }

  void _handleWebSocketMessage(dynamic msg) {
    print('');
    print('┌───────────────────────────────────────────────────────────┐');
    print('│           INCOMING WEBSOCKET MESSAGE                      │');
    print('└───────────────────────────────────────────────────────────┘');

    // ═══════════════════════════════════════════════════════════════
    // 1️⃣ BINARY MESSAGE = TTS AUDIO (PCM16, 16kHz, mono, 640 bytes/frame)
    // ═══════════════════════════════════════════════════════════════
    if (msg is Uint8List || msg is List<int>) {
      final Uint8List audioData = msg is Uint8List
          ? msg
          : Uint8List.fromList(msg);

      print('📨 Message Type: BINARY (TTS Audio)');
      print('📏 Audio Length: ${audioData.length} bytes');
      print('🎵 Format: PCM16, 16kHz, mono');

      // ✅ Add raw PCM16 audio to player
      _ttsPlayer?.addFrame(audioData);

      // Update speaking state
      if (!isSpeaking.value) {
        isSpeaking.value = true;
        currentAmplitude.value = 0.8;
        siriController.amplitude = 0.8;
        print('🔊 isSpeaking = true (AI started speaking)');
      }

      print('✅ Audio frame added to TTS player');
      print('═══════════════════════════════════════════════════════════');
      return; // Exit - audio handled
    }

    // ═══════════════════════════════════════════════════════════════
    // 2️⃣ JSON MESSAGE = CONTROL MESSAGES (stt_ready, stt_final, etc.)
    // ═══════════════════════════════════════════════════════════════
    if (msg is String) {
      print('📨 Message Type: TEXT (JSON)');
      print('📏 Message Length: ${msg.length} characters');

      if (msg.length <= 500) {
        print('📄 Full Message: $msg');
      } else {
        print('📄 Message (truncated): ${msg.substring(0, 500)}...');
      }

      try {
        final jsonMsg = jsonDecode(msg) as Map<String, dynamic>;
        final type = jsonMsg['type'];
        print('🏷️  Parsed Type: $type');
        print('');

        switch (type) {
          // ─────────────────────────────────────────────────────────
          // SESSION READY
          // ─────────────────────────────────────────────────────────
          case 'stt_ready':
          case 'session_ready':
            print(
              '╔═══════════════════════════════════════════════════════════╗',
            );
            print('║      ✅✅✅ stt_ready RECEIVED! ✅✅✅                      ║');
            print(
              '╚═══════════════════════════════════════════════════════════╝',
            );
            print('📋 Session ID: ${jsonMsg['session_id'] ?? 'N/A'}');
            print('🎯 Setting isSessionReady = true');
            isSessionReady.value = true;
            print('✅ isSessionReady is now: ${isSessionReady.value}');
            print('');
            print(
              '╔═══════════════════════════════════════════════════════════╗',
            );
            print(
              '║     STEP 3: NOW READY TO SEND AUDIO                      ║',
            );
            print(
              '╚═══════════════════════════════════════════════════════════╝',
            );
            print('🎤 Microphone can now stream audio to server');
            print('📡 Audio frames will be sent starting from next frame');
            print(
              '═══════════════════════════════════════════════════════════',
            );
            break;

          // ─────────────────────────────────────────────────────────
          // STT PARTIAL (Live transcription)
          // ─────────────────────────────────────────────────────────
          case 'stt_partial':
            final text = jsonMsg['text'] ?? '';
            recognizedText.value = text;
            print('🎤 STT PARTIAL (Live): "$text"');
            print(
              '═══════════════════════════════════════════════════════════',
            );
            break;

          // ─────────────────────────────────────────────────────────
          // STT FINAL (Complete transcription)
          // ─────────────────────────────────────────────────────────
          case 'stt_final':
            final text = jsonMsg['text'] ?? '';
            print('🎯 STT FINAL (Complete): "$text"');
            _addUserMessage(text);
            recognizedText.value = '';
            print('✅ User message added to chat history');
            print(
              '═══════════════════════════════════════════════════════════',
            );
            break;

          // ─────────────────────────────────────────────────────────
          // TTS START
          // ─────────────────────────────────────────────────────────
          case 'tts_start':
            print('🔊 TTS START - AI about to speak');
            print('   Response ID: ${jsonMsg['response_id'] ?? 'N/A'}');
            _ttsPlayer?.clear();
            isSpeaking.value = true;
            currentAmplitude.value = 0.8;
            siriController.amplitude = 0.8;
            print('   🧹 Audio buffer cleared');
            print('   🔊 isSpeaking = true');
            print(
              '═══════════════════════════════════════════════════════════',
            );
            break;

          // ─────────────────────────────────────────────────────────
          // TTS SENTENCE START
          // ─────────────────────────────────────────────────────────
          case 'tts_sentence_start':
            final text = jsonMsg['text'] ?? '';
            print('📝 TTS SENTENCE START');
            print('   Text: "$text"');
            _ttsPlayer?.onSentenceStart();
            isSpeaking.value = true;
            currentAmplitude.value = 0.8;
            siriController.amplitude = 0.8;
            print('   ✅ Sentence buffer prepared');
            print(
              '═══════════════════════════════════════════════════════════',
            );
            break;

          // ─────────────────────────────────────────────────────────
          // TTS SENTENCE END
          // ─────────────────────────────────────────────────────────
          case 'tts_sentence_end':
            final text = jsonMsg['text'] ?? '';
            print('✅ TTS SENTENCE END');
            print('   Text: "$text"');
            _ttsPlayer?.onSentenceEnd();
            print('   🔊 Playing buffered audio');
            print(
              '═══════════════════════════════════════════════════════════',
            );
            break;

          // ─────────────────────────────────────────────────────────
          // AI REPLY TEXT
          // ─────────────────────────────────────────────────────────
          case 'ai_reply_text':
            final text = jsonMsg['text'] ?? '';
            print('🤖 AI REPLY TEXT: "$text"');
            _addAiMessage(text);
            print('   ✅ AI message added to chat history');
            print(
              '═══════════════════════════════════════════════════════════',
            );
            break;

          // ─────────────────────────────────────────────────────────
          // TTS END/COMPLETE
          // ─────────────────────────────────────────────────────────
          case 'tts_end':
          case 'tts_complete':
            print('✅ TTS COMPLETE - AI finished speaking');
            print('   Response ID: ${jsonMsg['response_id'] ?? 'N/A'}');
            isSpeaking.value = false;
            currentAmplitude.value = 0.5;
            siriController.amplitude = 0.5;
            print('   🔊 isSpeaking = false');
            print('   👂 Back to listening mode');
            print(
              '═══════════════════════════════════════════════════════════',
            );
            break;

          // ─────────────────────────────────────────────────────────
          // CANCELLED
          // ─────────────────────────────────────────────────────────
          case 'cancelled':
            print('🚫 CANCELLED - Request cancelled by server');
            print(
              '═══════════════════════════════════════════════════════════',
            );
            break;

          // ─────────────────────────────────────────────────────────
          // INTERRUPTED (Barge-in)
          // ─────────────────────────────────────────────────────────
          case 'interrupted':
            print('🛑 INTERRUPTED - User barged in during AI speech');
            print('   Response ID: ${jsonMsg['response_id'] ?? 'N/A'}');
            _handleInterruption();
            print('   ✅ Interruption handled');
            print(
              '═══════════════════════════════════════════════════════════',
            );
            break;

          // ─────────────────────────────────────────────────────────
          // ERROR
          // ─────────────────────────────────────────────────────────
          case 'error':
            final errorMsg = jsonMsg['message'] ?? 'Unknown error';
            print('❌ SERVER ERROR: $errorMsg');
            _showError(errorMsg);
            print(
              '═══════════════════════════════════════════════════════════',
            );
            break;

          // ─────────────────────────────────────────────────────────
          // UNKNOWN MESSAGE TYPE
          // ─────────────────────────────────────────────────────────
          default:
            print('⚠️  UNKNOWN MESSAGE TYPE: $type');
            print('   Full message: $jsonMsg');
            print(
              '═══════════════════════════════════════════════════════════',
            );
        }
      } catch (e, stackTrace) {
        print('❌ ERROR PARSING JSON MESSAGE');
        print('   Error: $e');
        print('   Raw message: $msg');
        print('   Stack trace:');
        print(stackTrace);
        print('═══════════════════════════════════════════════════════════');
      }
    } else {
      print('❓ UNKNOWN MESSAGE FORMAT');
      print('   Type: ${msg.runtimeType}');
      print('═══════════════════════════════════════════════════════════');
    }
  }

  void _handleInterruption() {
    isSpeaking.value = false;
    _ttsPlayer?.stop();
    currentAmplitude.value = 0.5;
    siriController.amplitude = 0.5;
  }

  void _addUserMessage(String text) {
    messages.add(
      ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
    );
  }

  void _addAiMessage(String text) {
    messages.add(
      ChatMessage(text: text, isUser: false, timestamp: DateTime.now()),
    );
  }

  /// Toggle microphone ON/OFF - ONLY way to control mic
  Future<void> toggleMicrophone() async {
    print('');
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║            🎤 MICROPHONE BUTTON PRESSED                   ║');
    print('╚═══════════════════════════════════════════════════════════╝');
    print('📊 Current Mic State: ${isMicOn.value ? "🟢 ON" : "🔴 OFF"}');
    print('🎯 Action: ${isMicOn.value ? "Turn OFF" : "Turn ON"}');

    if (isMicOn.value) {
      // User pressed button while mic is ON → Turn it OFF
      await _stopMicrophone();
    } else {
      // User pressed button while mic is OFF → Turn it ON
      await _startMicrophone();
    }
  }

  Future<void> _startMicrophone() async {
    print('');
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║              STARTING MICROPHONE                          ║');
    print('╚═══════════════════════════════════════════════════════════╝');

    if (!isConnected.value) {
      print('❌ Cannot start microphone - Not connected to WebSocket');
      print('═══════════════════════════════════════════════════════════');
      _showError('Not connected to server');
      return;
    }

    print('✅ WebSocket is connected');

    try {
      // ╔═══════════════════════════════════════════════════════════╗
      // ║  STEP 0: Cleanup any previous recorder instance           ║
      // ╚═══════════════════════════════════════════════════════════╝
      print('');
      print('╔═══════════════════════════════════════════════════════════╗');
      print('║     STEP 0: CLEANING UP PREVIOUS INSTANCES               ║');
      print('╚═══════════════════════════════════════════════════════════╝');

      if (_micStreamer != null) {
        print('⚠️  Found existing MicStreamer - cleaning up...');
        await _micSub?.cancel();
        await _micStreamer!.stop();
        await _micStreamer!.dispose();
        _micStreamer = null;
        print('✅ Previous MicStreamer cleaned up');
      }

      // Small delay to ensure audio resources are released
      await Future.delayed(Duration(milliseconds: 100));
      print('✅ Audio resources released');

      // ╔═══════════════════════════════════════════════════════════╗
      // ║  STEP 1: Send stt_start when mic button is pressed        ║
      // ╚═══════════════════════════════════════════════════════════╝
      print('');
      print('╔═══════════════════════════════════════════════════════════╗');
      print('║     STEP 1: SENDING stt_start TO SERVER                  ║');
      print('╚═══════════════════════════════════════════════════════════╝');

      final startMessage = {
        'type': 'stt_start',
        'session_id': sessionId,
        'voice': 'onyx',
        if (scenarioData != null) 'scenario_id': scenarioData!.scenarioId,
      };

      print('📤 Sending stt_start: ${jsonEncode(startMessage)}');
      _channel?.sink.add(jsonEncode(startMessage));
      print('✅ stt_start sent to server');

      print('');
      print('╔═══════════════════════════════════════════════════════════╗');
      print('║     STEP 2: WAITING FOR stt_ready RESPONSE               ║');
      print('╚═══════════════════════════════════════════════════════════╝');
      print('⏳ Waiting for stt_ready...');

      // Wait for stt_ready
      await Future.delayed(Duration(milliseconds: 500));

      if (!isSessionReady.value) {
        print('⚠️  stt_ready not received yet, but starting mic anyway');
      }

      // ╔═══════════════════════════════════════════════════════════╗
      // ║  STEP 3: Start MicStreamer (using SAME WebSocket)         ║
      // ╚═══════════════════════════════════════════════════════════╝
      print('');
      print('╔═══════════════════════════════════════════════════════════╗');
      print('║       STEP 3: STARTING AUDIO CAPTURE                     ║');
      print('╚═══════════════════════════════════════════════════════════╝');

      print(
        '🎙️  Creating MicStreamer with SAME WebSocket (PCM16, 16kHz, mono)',
      );
      _micStreamer = MicStreamer(channel: _channel!); // ✅ Use existing channel

      print('🔧 Initializing MicStreamer...');
      await _micStreamer!.init();
      print('✅ MicStreamer initialized');

      print('▶️  Starting audio capture...');
      print('   Format: PCM16, 16kHz, mono');
      print('   Frame size: 640 bytes (20ms)');
      await _micStreamer!.start();
      print('✅ Audio capture started');

      int frameCount = 0;
      int audioBytesSent = 0;

      print('');
      print('╔═══════════════════════════════════════════════════════════╗');
      print('║         AUDIO STREAM LISTENER ACTIVATED                  ║');
      print('╚═══════════════════════════════════════════════════════════╝');

      // Listen to mic frames
      _micSub = _micStreamer!.frames.listen(
        (frame) async {
          frameCount++;

          // Log first 5 frames, then every 50th frame
          if (frameCount <= 5 || frameCount % 50 == 0) {
            print('🎙️  Frame #$frameCount received (${frame.length} bytes)');
          }

          // ✅ Send audio frames directly (ALWAYS send, no isSessionReady check needed)
          _channel?.sink.add(frame);
          audioBytesSent += frame.length;

          // Log every 10 frames sent
          if (frameCount % 10 == 0) {
            print(
              '📤 Sent ${(audioBytesSent / 1024).toStringAsFixed(1)} KB to server (frame #$frameCount)',
            );
          }

          // Check for barge-in if AI is speaking
          if (isSpeaking.value) {
            final shouldInterrupt = _bargeInDetector!.processPcm16Frame(
              Uint8List.fromList(frame),
            );
            if (shouldInterrupt) {
              print('');
              print(
                '╔═══════════════════════════════════════════════════════════╗',
              );
              print(
                '║          🛑 BARGE-IN DETECTED! 🛑                         ║',
              );
              print(
                '╚═══════════════════════════════════════════════════════════╝',
              );
              print('👤 User started speaking while AI was talking');
              print('🛑 Stopping AI audio playback...');
              await _ttsPlayer?.stop();
              print('📤 Sending cancel signal to server...');
              _channel?.sink.add(jsonEncode({'type': 'cancel'}));
              _bargeInDetector!.reset();
              isSpeaking.value = false;
              print('✅ Barge-in handled - AI stopped, listening to user');
              print(
                '═══════════════════════════════════════════════════════════',
              );
            }
          }

          // Update amplitude for animation
          currentAmplitude.value = 0.7;
          siriController.amplitude = 0.7;
        },
        onError: (error) {
          print('');
          print('❌❌❌ MICROPHONE STREAM ERROR ❌❌❌');
          print('Error: $error');
          print('═══════════════════════════════════════════════════════════');
        },
        onDone: () {
          print('');
          print('🎤 Microphone stream completed/closed');
          print('═══════════════════════════════════════════════════════════');
        },
      );

      isMicOn.value = true;
      print('');
      print('╔═══════════════════════════════════════════════════════════╗');
      print('║          ✅ MICROPHONE STARTED SUCCESSFULLY ✅            ║');
      print('╚═══════════════════════════════════════════════════════════╝');
      print('🎤 Status: ACTIVE');
      print('📡 Audio: STREAMING TO SERVER');
      print('═══════════════════════════════════════════════════════════');
    } catch (e, stackTrace) {
      print('');
      print('❌❌❌ FAILED TO START MICROPHONE ❌❌❌');
      print('Error: $e');
      print('Stack trace:');
      print(stackTrace);
      print('═══════════════════════════════════════════════════════════');
      _showError('Failed to start microphone');
    }
  }

  Future<void> _stopMicrophone() async {
    print('');
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║              STOPPING MICROPHONE                          ║');
    print('╚═══════════════════════════════════════════════════════════╝');

    try {
      print('🛑 Cancelling mic subscription...');
      await _micSub?.cancel();
      _micSub = null;
      print('✅ Subscription cancelled');

      print('🛑 Stopping MicStreamer...');
      await _micStreamer?.stop();
      print('✅ MicStreamer stopped');

      print('🧹 Disposing MicStreamer...');
      await _micStreamer?.dispose();
      _micStreamer = null;
      print('✅ MicStreamer disposed');

      isMicOn.value = false;
      currentAmplitude.value = 0.5;
      siriController.amplitude = 0.5;

      print('');
      print('╔═══════════════════════════════════════════════════════════╗');
      print('║          ✅ MICROPHONE STOPPED SUCCESSFULLY ✅            ║');
      print('╚═══════════════════════════════════════════════════════════╝');
      print('🎤 Status: INACTIVE');
      print('═══════════════════════════════════════════════════════════');
    } catch (e, stackTrace) {
      print('');
      print('❌ ERROR STOPPING MICROPHONE');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('═══════════════════════════════════════════════════════════');
    }
  }

  void _startContinuousAnimation() {
    _animationTimer?.cancel();
    // ✅ Reduced from 50ms to 100ms (10fps) to prevent BLASTBufferQueue overflow
    _animationTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      update();
    });
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(16),
    );
  }

  void goBack(BuildContext context) async {
    print('');
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║              BACK BUTTON PRESSED                          ║');
    print('╚═══════════════════════════════════════════════════════════╝');

    // ✅ Stop mic FIRST if it's active
    if (isMicOn.value) {
      print('🎤 Mic is ON - stopping before navigation...');
      await _stopMicrophone();
      print('✅ Mic stopped');
    }

    // ✅ Then cleanup and disconnect
    print('🧹 Cleaning up resources before navigation...');
    await _cleanup();
    print('✅ Cleanup complete');

    // ✅ Finally navigate away
    print('⬅️  Navigating back...');
    context.pop();
    print('✅ Navigation complete');
  }

  Future<void> _cleanup() async {
    print('');
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║    🧹 CLEANUP: PAGE CLOSING - DISCONNECTING ALL 🧹       ║');
    print('╚═══════════════════════════════════════════════════════════╝');

    print('🧹 Step 1/7: Stopping microphone (if active)...');
    if (isMicOn.value) {
      await _stopMicrophone();
    }
    await _micSub?.cancel();
    print('   ✅ Microphone stopped and cleaned');

    print('🧹 Step 2/7: Cancelling WebSocket subscription...');
    await _wsSub?.cancel();
    print('   ✅ WebSocket listener stopped');

    print('🧹 Step 3/7: Stopping MicStreamer...');
    await _micStreamer?.stop();
    print('   ✅ MicStreamer stopped');

    print('🧹 Step 4/7: Disposing MicStreamer...');
    await _micStreamer?.dispose();
    print('   ✅ MicStreamer disposed');

    print('🧹 Step 5/7: Stopping TTS Player...');
    await _ttsPlayer?.stop();
    print('   ✅ TTS Player stopped');

    print('🧹 Step 6/7: Disposing TTS Player...');
    await _ttsPlayer?.dispose();
    print('   ✅ TTS Player disposed');

    print('🧹 Step 7/7: Closing WebSocket connection...');
    await _channel?.sink.close();
    print('   ✅ WebSocket disconnected');

    _animationTimer?.cancel();

    print('🔄 Resetting all state variables...');
    isMicOn.value = false;
    isConnected.value = false;
    isSpeaking.value = false;
    isSessionReady.value = false;
    print('   ✅ All states reset to initial values');

    print('');
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║   ✅ CLEANUP COMPLETE - PAGE CLOSED SUCCESSFULLY ✅       ║');
    print('╚═══════════════════════════════════════════════════════════╝');
  }
  Future<void> _loadUserProfileImage() async {
    try {
      print('👤 Loading user profile image...');
      final accessToken = SharedPreferencesUtil.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        print('⚠️ No access token available');
        return;
      }

      final response = await ApiServices().getUserProfile(accessToken: accessToken);

      if (response.image != null && response.image!.isNotEmpty) {
        // Construct full image URL if relative path
        final imageUrl = response.image!.startsWith('http')
            ? response.image!
            : '${ApiConstant.baseUrl}${response.image}';

        userProfileImage.value = imageUrl;
        print('✅ User profile image loaded: $imageUrl');
      } else {
        print('⚠️ No profile image available');
      }
    } catch (e) {
      print('❌ Failed to load user profile image: $e');
      // Don't throw - use fallback icon
    }
  }
}

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
// ✅ ADD: Method to load user profile image

