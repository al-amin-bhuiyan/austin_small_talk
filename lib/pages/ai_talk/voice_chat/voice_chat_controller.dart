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
import 'package:http/http.dart' as ApiService;
import 'package:siri_wave/siri_wave.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../service/auth/models/user_profile_response_model.dart';
import 'audio/audio_session_config.dart';
import 'audio/barge_in_detector.dart';
import 'audio/mic_streamer.dart';
import 'audio/tts_player.dart';
import 'audio/voice_activity_detector.dart';

class VoiceChatController extends GetxController {
  final String sessionId = const Uuid().v4();
  final _wsClient = VoiceWsClient();

  WebSocketChannel? _channel;
  StreamSubscription? _wsSub;
  final userProfileImage = Rxn<String>();
  bool _isInitializing = false;

  MicStreamer? _micStreamer;
  TtsPlayer? _ttsPlayer;
  BargeInDetector? _bargeInDetector;

  final IOS9SiriWaveformController siriController = IOS9SiriWaveformController(
    amplitude: 0.5,
    speed: 0.2,
  );

  final isMicOn = false.obs;
  final isProcessing = false.obs;
  final isSpeaking = false.obs;
  final isConnected = false.obs;
  final isSessionReady = false.obs;
  final recognizedText = ''.obs;
  final messages = <ChatMessage>[].obs;
  final currentAmplitude = 0.5.obs;

  String _lastFinalText = '';
  DateTime? _lastFinalTimestamp;

  final useVad = true.obs;
  final framesSent = 0.obs;
  final framesSkipped = 0.obs;
  final bandwidthSaved = '0 KB'.obs;

  StreamSubscription? _micSub;
  ScenarioData? scenarioData;
  Timer? _animationTimer;
  bool _lastVadSpeechEnded = false; // ✅ Prevent duplicate audio_end

  @override
  void onInit() {
    print('═══════════════════════════════════════════════════════════');
    print('🚀 VoiceChatController.onInit()');
    print('═══════════════════════════════════════════════════════════');
    super.onInit();
    _startContinuousAnimation();
    // ✅ Profile image is handled by GlobalProfileController - no need to fetch here
  }

  @override
  void onReady() {
    print('═══════════════════════════════════════════════════════════');
    print('🎯 VoiceChatController.onReady()');
    print('═══════════════════════════════════════════════════════════');
    super.onReady();
    if (_isInitializing) {
      print('⚠️ Already initializing - skipping');
      return;
    }
    _initializeVoiceChat();
  }

  void onResumed() {
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║         PAGE RESUMED - CHECKING CONNECTION STATE          ║');
    print('╚═══════════════════════════════════════════════════════════╝');

    final needsReconnect = _channel == null ||
        _channel!.closeCode != null ||
        !isConnected.value;

    if (needsReconnect && !_isInitializing) {
      print('⚠️ WebSocket disconnected - reconnecting...');
      _initializeVoiceChat();
    } else if (_isInitializing) {
      print('⏳ Already initializing - skipping');
    } else {
      print('✅ WebSocket still connected');
    }
  }

  @override
  void onClose() {
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║       VOICE CHAT CLOSING - CLEANUP                        ║');
    print('╚═══════════════════════════════════════════════════════════╝');
    _cleanup();
    super.onClose();
  }

  void setScenarioData(ScenarioData data) {
    print('📋 Setting Scenario: ${data.scenarioTitle}');

    final isDifferentScenario = scenarioData != null &&
        scenarioData!.scenarioId != data.scenarioId;

    if (isDifferentScenario) {
      messages.clear();
    }
    scenarioData = data;
  }

  Future<void> _initializeVoiceChat() async {
    if (_isInitializing) return;
    _isInitializing = true;

    print('═══════════════════════════════════════════════════════════');
    print('🎬 INITIALIZING VOICE CHAT');
    print('═══════════════════════════════════════════════════════════');

    try {
      print('📦 Step 1/4: Configuring Audio Session');
      await AudioSessionConfigHelper.configureForVoiceChat();

      print('📦 Step 2/4: Creating TTS Player');
      _ttsPlayer = TtsPlayer(sampleRate: 24000, numChannels: 1);
      await _ttsPlayer!.init();

      print('📦 Step 3/4: Creating Barge-in Detector');
      _bargeInDetector = BargeInDetector(baseThreshold: 0.20, requiredFrames: 3);

      print('📦 Step 4/4: Connecting to WebSocket');
      await _connectToWebSocket();

      print('✅ VOICE CHAT READY');
      _isInitializing = false;
    } catch (e, stackTrace) {
      print('❌ INITIALIZATION FAILED: $e');
      print(stackTrace);
      _isInitializing = false;
      _showError('Failed to initialize: $e');
    }
  }

  String _buildWsUrl() {
    return ApiConstant.voiceChatWs;
  }

  Future<void> _connectToWebSocket() async {
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║        CONNECTING TO WEBSOCKET                            ║');
    print('╚═══════════════════════════════════════════════════════════╝');

    try {
      final wsUrl = _buildWsUrl();
      print('🔌 URL: $wsUrl');

      final accessToken = SharedPreferencesUtil.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token');
      }

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      print('✅ WebSocket channel created');

      _wsSub = _channel!.stream.listen(
            (msg) => _handleWebSocketMessage(msg),
        onError: (error) {
          print('❌ WebSocket error: $error');
          isConnected.value = false;
        },
        onDone: () {
          print('🔌 WebSocket closed');
          isConnected.value = false;
        },
        cancelOnError: false,
      );

      isConnected.value = true;
      print('✅ WEBSOCKET CONNECTED');
      print('📋 Session ID: $sessionId');

    } catch (e, stackTrace) {
      print('❌ CONNECTION FAILED: $e');
      isConnected.value = false;
      throw Exception('Failed to connect: $e');
    }
  }

  void _handleWebSocketMessage(dynamic msg) {
    // ═══════════════════════════════════════════════════════════════
    // BINARY MESSAGE = TTS AUDIO
    // ═══════════════════════════════════════════════════════════════
    if (msg is Uint8List || msg is List<int>) {

      final Uint8List audioData = msg is Uint8List ? msg : Uint8List.fromList(msg);
      print('🔊 TTS Audio: ${audioData.length} bytes');

      _ttsPlayer?.addFrame(audioData);

      if (!isSpeaking.value) {
        isSpeaking.value = true;
        currentAmplitude.value = 0.8;
        siriController.amplitude = 0.8;
      }
      return;
    }

    // ═══════════════════════════════════════════════════════════════
    // JSON MESSAGE = CONTROL MESSAGES
    // ═══════════════════════════════════════════════════════════════
    if (msg is String) {
      print('📨 JSON: $msg');

      try {
        final data = jsonDecode(msg) as Map<String, dynamic>;
        final type = data['type'] as String?;

        switch (type) {
          case 'stt_ready':
            print('✅ STT READY - Server ready to receive audio');
            isSessionReady.value = true;
            break;

          case 'stt_partial':
            final text = data['text'] as String? ?? '';
            print('📝 Partial: $text');
            recognizedText.value = text;
            break;

          case 'stt_final':
            final text = data['text'] as String? ?? '';
            print('✅ Final STT: $text');

            // ✅ Prevent duplicate messages
            final now = DateTime.now();
            final isDuplicate = text == _lastFinalText &&
                _lastFinalTimestamp != null &&
                now.difference(_lastFinalTimestamp!).inMilliseconds < 2000;

            if (text.isNotEmpty && !isDuplicate) {
              recognizedText.value = text;
              _addUserMessage(text);
              _lastFinalText = text;
              _lastFinalTimestamp = now;
            } else if (isDuplicate) {
              print('⚠️ Duplicate STT ignored: $text');
            }
            isProcessing.value = true;
            break;

          case 'ai_reply_text':
            final text = data['text'] as String? ?? '';
            print('🤖 AI Reply: $text');
            _addAiMessage(text);
            isProcessing.value = false;
            break;

          case 'tts_start':
            print('🔊 TTS Starting...');
            isSpeaking.value = true;
            _ttsPlayer?.onSentenceStart();
            
            // ✅ ECHO CANCELLATION: Suppress VAD during AI playback
            _micStreamer?.vad.setPlaybackState(true);
            print('🔇 VAD suppressed during AI speech');
            break;

          case 'tts_end':
            print('🔊 TTS Ended');
            isSpeaking.value = false;
            _ttsPlayer?.onSentenceEnd();
            currentAmplitude.value = 0.5;
            siriController.amplitude = 0.5;
            
            // ✅ ECHO CANCELLATION: Wait 500ms before resuming VAD
            // This prevents picking up residual speaker audio
            Future.delayed(Duration(milliseconds: 500), () {
              _micStreamer?.vad.setPlaybackState(false);
              print('🎤 VAD resumed - ready for user speech');
            });
            break;

          case 'cancelled':
            print('🛑 Cancelled by server');
            isSpeaking.value = false;
            isProcessing.value = false;
            
            // ✅ Resume VAD after cancellation
            _micStreamer?.vad.setPlaybackState(false);
            print('🎤 VAD resumed after cancellation');
            break;

          case 'error':
            final message = data['message'] as String? ?? 'Unknown error';
            print('❌ Server error: $message');
            _showError(message);
            break;

          default:
            print('❓ Unknown type: $type');
        }
      } catch (e) {
        print('❌ JSON parse error: $e');
      }
    }
  }

  void _handleInterruption() {
    isSpeaking.value = false;
    _ttsPlayer?.stop();
    currentAmplitude.value = 0.5;
    siriController.amplitude = 0.5;
    
    // ✅ Resume VAD immediately on interruption (user is speaking)
    _micStreamer?.vad.setPlaybackState(false);
    print('🎤 VAD resumed after interruption');
  }

  void _addUserMessage(String text) {
    messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
  }

  void _addAiMessage(String text) {
    messages.add(ChatMessage(text: text, isUser: false, timestamp: DateTime.now()));
  }

  Future<void> toggleMicrophone() async {
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║            🎤 MICROPHONE BUTTON PRESSED                   ║');
    print('╚═══════════════════════════════════════════════════════════╝');
    print('📊 Current: ${isMicOn.value ? "ON" : "OFF"}');

    if (isMicOn.value) {
      await _stopMicrophone();
    } else {
      await _startMicrophone();
    }
  }

  Future<void> _startMicrophone() async {
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║              STARTING MICROPHONE                          ║');
    print('╚═══════════════════════════════════════════════════════════╝');

    if (!isConnected.value || _channel == null || _channel!.closeCode != null) {
      print('❌ WebSocket not healthy - cannot start microphone');
      _showError('Connection lost - please try again');
      return;
    }

    try {
      // STEP 0: Cleanup previous (EXTENDED DELAY)
      if (_micStreamer != null) {
        print('⚠️ Cleaning up previous MicStreamer...');
        await _micSub?.cancel();
        await _micStreamer!.stop();
        await _micStreamer!.dispose();
        _micStreamer = null;
      }
      // ✅ INCREASED DELAY - Give OS time to release audio resources
      await Future.delayed(Duration(milliseconds: 300));

      // STEP 1: Send stt_start
      print('📤 Sending stt_start...');
      final startMessage = {
        'type': 'stt_start',
        'session_id': sessionId,
        'voice': 'onyx',
        if (scenarioData != null) 'scenario_id': scenarioData!.scenarioId,
        'audio': {
          'codec': 'pcm16',
          'sr': 16000,
          'ch': 1,
          'frame_ms': 20,
        },
      };
      _channel?.sink.add(jsonEncode(startMessage));
      print('✅ stt_start sent');

      // STEP 2: Wait for stt_ready
      print('⏳ Waiting for stt_ready...');
      int waitCount = 0;
      while (!isSessionReady.value && waitCount < 30) {
        await Future.delayed(Duration(milliseconds: 100));
        waitCount++;
      }

      if (!isSessionReady.value) {
        throw Exception('Server not ready after 3s timeout');
      }
      print('✅ stt_ready received');

      // STEP 3: Create MicStreamer and WAIT for initialization
      print('🎙️ Creating MicStreamer (PCM16, 16kHz, mono)...');
      _micStreamer = MicStreamer(channel: _channel!);

      // ✅ WAIT for init to complete
      await _micStreamer!.init();
      print('✅ MicStreamer initialized');

      // ✅ ADDITIONAL DELAY - Ensure recorder is fully open
      await Future.delayed(Duration(milliseconds: 100));

      // STEP 4: Start recording
      print('🎙️ Starting recorder...');
      await _micStreamer!.start();
      print('✅ MicStreamer started');

      // STEP 5: Listen to frames
      int frameCount = 0;
      int audioBytesSent = 0;

      _micSub = _micStreamer!.frames.listen(
            (frame) async {
          frameCount++;

          if (frameCount <= 5) {
            print('🎙️ Frame #$frameCount: ${frame.length} bytes');
          } else if (frameCount % 50 == 0) {
            print('🎙️ Frame #$frameCount: ${frame.length} bytes (total: ${(audioBytesSent / 1024).toStringAsFixed(1)} KB)');
          }

          bool shouldSendFrame = true;
          if (useVad.value) {
            final vadResult = _micStreamer!.processFrameWithVad(frame);
            shouldSendFrame = vadResult.shouldSend;

            if (vadResult.speechStarted) {
              print('🎤 VAD: Speech started');
              _lastVadSpeechEnded = false;
            }

            if (vadResult.speechEnded && !_lastVadSpeechEnded) {
              print('🔇 VAD: Speech ended - sending audio_end');
              _channel?.sink.add(jsonEncode({'type': 'audio_end'}));
              _lastVadSpeechEnded = true;
            }

            updateVadStats(_micStreamer!.framesSent, _micStreamer!.framesSkipped);
          }

          if (shouldSendFrame && _channel != null) {
            try {
              _channel!.sink.add(frame);
              audioBytesSent += frame.length;
            } catch (e) {
              print('❌ Failed to send frame: $e');
            }
          }

          // Barge-in detection
          if (isSpeaking.value && _bargeInDetector != null) {
            final shouldInterrupt = _bargeInDetector!.processPcm16Frame(
              Uint8List.fromList(frame),
              isAiSpeaking: true,
            );
            if (shouldInterrupt) {
              print('🛑 BARGE-IN DETECTED!');
              await _ttsPlayer?.stop();

              if (isConnected.value && _channel != null) {
                print('📤 Sending cancel to backend...');
                _channel?.sink.add(jsonEncode({'type': 'cancel'}));
              }

              _bargeInDetector!.reset();
              isSpeaking.value = false;
              await Future.delayed(Duration(milliseconds: 50));
            }
          }

          currentAmplitude.value = 0.7;
          siriController.amplitude = 0.7;
        },
        onError: (error) {
          print('❌ Mic stream error: $error');
          _showError('Microphone error: $error');
        },
        onDone: () {
          print('🎤 Mic stream closed');
        },
      );

      isMicOn.value = true;
      _startAnimationTimer();
      print('✅ MICROPHONE STARTED - STREAMING TO SERVER');

    } catch (e, stackTrace) {
      print('❌ Failed to start microphone: $e');
      print(stackTrace);
      _showError('Failed to start microphone: ${e.toString()}');

      // ✅ Cleanup on failure
      await _micSub?.cancel();
      if (_micStreamer != null) {
        await _micStreamer!.stop();
        await _micStreamer!.dispose();
        _micStreamer = null;
      }
      isMicOn.value = false;
    }
  }


  Future<void> _stopMicrophone() async {
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║              STOPPING MICROPHONE                          ║');
    print('╚═══════════════════════════════════════════════════════════╝');

    try {
      // Cancel frame listener
      await _micSub?.cancel();
      _micSub = null;

      // Stop and dispose mic streamer
      if (_micStreamer != null) {
        await _micStreamer!.stop();
        await _micStreamer!.dispose();
        _micStreamer = null;
      }

      // ✅ Note: audio_end is sent by VAD when speech ends
      // No need to send duplicate audio_end here

      // Stop TTS if playing
      await _ttsPlayer?.stop();
      _ttsPlayer?.clear();

      // Reset states
      isSessionReady.value = false;
      isMicOn.value = false;
      _lastVadSpeechEnded = false; // ✅ Reset for next session
      _stopAnimationTimer();
      currentAmplitude.value = 0.5;
      siriController.amplitude = 0.5;

      print('✅ MICROPHONE STOPPED');

    } catch (e) {
      print('❌ Error stopping microphone: $e');
    }
  }

  void _startContinuousAnimation() {
    siriController.amplitude = 0.3;
    siriController.speed = 0.1;
  }

  void _startAnimationTimer() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      if (isMicOn.value) {
        final variation = (DateTime.now().millisecondsSinceEpoch % 1000) / 1000;
        siriController.amplitude = 0.5 + (variation * 0.3);
      }
    });
  }

  void _stopAnimationTimer() {
    _animationTimer?.cancel();
    _animationTimer = null;
    siriController.amplitude = 0.3;
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  void goBack(BuildContext context) async {
    await _cleanup();
    if (context.mounted) {
      context.pop();
    }
  }

  Future<void> _cleanup() async {
    print('🧹 Cleaning up...');

    _animationTimer?.cancel();
    await _micSub?.cancel();

    if (_micStreamer != null) {
      await _micStreamer!.stop();
      await _micStreamer!.dispose();
      _micStreamer = null;
    }

    await _ttsPlayer?.dispose();
    _ttsPlayer = null;

    await _wsSub?.cancel();
    await _channel?.sink.close();
    _channel = null;

    isConnected.value = false;
    isMicOn.value = false;
    isSessionReady.value = false;
    _isInitializing = false;

    print('✅ Cleanup complete');
  }

  void updateVadStats(int sent, int skipped) {
    framesSent.value = sent;
    framesSkipped.value = skipped;
    bandwidthSaved.value = '${(skipped * 640 / 1024).toStringAsFixed(1)} KB';
  }

  void toggleVad() {
    useVad.value = !useVad.value;
    if (useVad.value) {
      _micStreamer?.enableVad();
    } else {
      _micStreamer?.disableVad();
    }
    print('🔧 VAD: ${useVad.value ? "ENABLED" : "DISABLED"}');
  }

  void resetVadStats() {
    framesSent.value = 0;
    framesSkipped.value = 0;
    bandwidthSaved.value = '0 KB';
    _micStreamer?.resetStats();
  }

  Future<void> _loadUserProfileImage() async {
    try {
      print('📸 Loading user profile image...');
      final accessToken = SharedPreferencesUtil.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        print('⚠️ No access token available');
        return;
      }

      final apiService = ApiServices();
      final profile = await apiService.getUserProfile(accessToken: accessToken);

      if (profile.image != null && profile.image!.isNotEmpty) {
        // Construct full URL: base_url + image_path
        final fullImageUrl = '${ApiConstant.baseUrl}${profile.image}';
        userProfileImage.value = fullImageUrl;
        print('✅ Profile image loaded: $fullImageUrl');
      } else {
        print('⚠️ No profile image in response');
      }
    } catch (e) {
      print('❌ Failed to load profile image: $e');
    }
  }


  Future<void> refreshVoiceChat() async {
    await _cleanup();
    await Future.delayed(Duration(milliseconds: 200));
    await _initializeVoiceChat();
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
