import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:austin_small_talk/pages/ai_talk/voice_chat/audio/tts_player.dart';
import 'package:uuid/uuid.dart';

import '../audio/barge_in_detector.dart';
import '../audio/mic_streamer.dart';
import '../audio/tts_player.dart';
import '../ws/voice_ws_client.dart';

enum VoiceState { idle, connecting, listening, processing, aiSpeaking }

/// Conversation Controller - Manages voice chat session lifecycle
/// Handles WebSocket communication, microphone streaming, and TTS playback
class ConversationController {
  // Session ID - generated once per controller instance
  final String sessionId = const Uuid().v4();

  final VoiceWsClient ws;
  final MicStreamer mic;
  final TtsPlayer player;
  final BargeInDetector bargeIn;

  VoiceState state = VoiceState.idle;

  StreamSubscription? _wsSub;
  StreamSubscription? _micSub;

  // Callbacks for state changes
  Function(VoiceState state)? onStateChange;
  Function(String text)? onTranscript;
  Function(String text)? onAiReply;
  Function(String error)? onError;

  ConversationController({
    required this.ws,
    required this.mic,
    required this.player,
    required this.bargeIn,
    this.onStateChange,
    this.onTranscript,
    this.onAiReply,
    this.onError,
  });

  Future<void> startSession({
    required Uri wsUri,
    required String scenario,
    String? scenarioId,
    String? accessToken,
  }) async {
    _updateState(VoiceState.connecting);

    try {
      // Connect with authentication
      await ws.connect(wsUri, accessToken: accessToken);
      print('✅ Connected to voice server');

      // Initialize TTS player
      await player.init();
      print('✅ TTS Player initialized');

      // Send session start message
      ws.sendJson({
        'type': 'stt_start',
        'session_id':
            sessionId, // Use UUID session ID (same for entire session)
        'voice': 'female', // Options: male, female, onyx, nova
        if (scenarioId != null) 'scenario_id': scenarioId,
      });
      print('📤 Sent stt_start for scenario: $scenario');
      print('📋 Session ID: $sessionId');

      // Listen to WebSocket messages
      int receivedMessageCount = 0;
      _wsSub = ws.stream.listen(
        (msg) async {
          receivedMessageCount++;
          await _handleWebSocketMessage(msg, receivedMessageCount);
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          onError?.call('WebSocket error: $error');
          _updateState(VoiceState.idle);
          _handleSessionClose();
        },
        onDone: () {
          print('🔌 WebSocket connection closed');
          print('📊 Total messages received: $receivedMessageCount');
          _updateState(VoiceState.idle);
          _handleSessionClose();
        },
      );

      // Start microphone
      print('🎤 Initializing microphone...');
      await mic.init();
      await mic.start();
      print('✅ Microphone started');

      int frameCount = 0;
      _micSub = mic.frames.listen(
        (frame) async {
          frameCount++;
          // Log periodically
          if (frameCount <= 5 || frameCount % 50 == 0) {
            print('🎙️ Mic frame #$frameCount: ${frame.length} bytes');
          }

          // Send audio to server
          ws.sendAudio(frame);

          // Check for barge-in if AI is speaking
          if (state == VoiceState.aiSpeaking) {
            final shouldInterrupt = bargeIn.processPcm16Frame(frame);
            if (shouldInterrupt) {
              print('🛑 Barge-in detected! Interrupting AI...');
              await _handleBargeIn();
            }
          }
        },
        onError: (error) {
          print('❌ Microphone error: $error');
          onError?.call('Microphone error: $error');
        },
        onDone: () {
          print('🎤 Microphone stream closed');
        },
      );

      _updateState(VoiceState.listening);
      print('✅ Voice session started successfully');
    } catch (e) {
      print('❌ Error starting session: $e');
      onError?.call('Failed to start session: $e');
      _updateState(VoiceState.idle);
    }
  }

  /// Handle incoming WebSocket messages
  Future<void> _handleWebSocketMessage(dynamic msg, int messageCount) async {
    if (msg is String) {
      // JSON message
      try {
        final jsonMsg = jsonDecode(msg) as Map<String, dynamic>;
        final type = jsonMsg['type'];

        print('📥 Message #$messageCount: $type');

        switch (type) {
          case 'stt_ready':
            print('✅ STT Ready - session: ${jsonMsg['session_id']}');
            _updateState(VoiceState.listening);
            break;

          case 'state':
            _handleStateMessage(jsonMsg['value']);
            break;

          case 'stt_partial':
            final text = jsonMsg['text'] ?? '';
            print('📝 STT Partial: $text');
            onTranscript?.call(text);
            break;

          case 'stt_final':
            final text = jsonMsg['text'] ?? '';
            print('🎯 STT Final: $text');
            onTranscript?.call(text);
            break;

          case 'ai_reply_text':
            final text = jsonMsg['text'] ?? '';
            print('🤖 AI Reply: $text');
            onAiReply?.call(text);
            break;

          case 'tts_start':
            print('🔊 TTS Started');
            _updateState(VoiceState.aiSpeaking);
            break;

          case 'tts_sentence_start':
            print('📝 TTS Sentence Start');

            _updateState(VoiceState.aiSpeaking);
            break;

          case 'audio':
            _handleAudioMessage(jsonMsg);
            break;

          case 'tts_sentence_end':
            print('✅ TTS Sentence End');

            break;

          case 'tts_end':
          case 'tts_complete':
            print('✅ TTS Complete');
            _updateState(VoiceState.listening);
            break;

          case 'interrupted':
            print('🛑 Server confirmed interruption');
            _updateState(VoiceState.listening);
            break;

          case 'cancelled':
            print('✅ Server confirmed cancellation');
            _updateState(VoiceState.listening);
            break;

          case 'error':
            final errorMsg = jsonMsg['message'] ?? 'Unknown error';
            print('❌ Server error: $errorMsg');
            onError?.call(errorMsg);
            break;

          default:
            print('❓ Unknown message type: $type');
        }
      } catch (e) {
        print('❌ Error parsing JSON message: $e');
      }
    } else if (msg is Uint8List) {
      // Binary audio data
      print('📥 Binary audio #$messageCount: ${msg.length} bytes');
      player.addFrame(msg);
      _updateState(VoiceState.aiSpeaking);
    } else {
      print('❓ Unknown message format: ${msg.runtimeType}');
    }
  }

  /// Handle state change message from server
  void _handleStateMessage(String stateValue) {
    print('🔄 State change from server: $stateValue');
    switch (stateValue) {
      case 'listening':
        _updateState(VoiceState.listening);
        break;
      case 'processing':
        _updateState(VoiceState.processing);
        break;
      case 'ai_speaking':
        _updateState(VoiceState.aiSpeaking);
        break;
      default:
        print('❓ Unknown state: $stateValue');
    }
  }

  /// Handle audio data message
  void _handleAudioMessage(Map<String, dynamic> jsonMsg) {
    try {
      final audioData = jsonMsg['data'];
      if (audioData != null) {
        final pcmBytes = base64Decode(audioData);
        print('🔊 Received audio: ${pcmBytes.length} bytes');
        player.addFrame(Uint8List.fromList(pcmBytes));
        _updateState(VoiceState.aiSpeaking);
      }
    } catch (e) {
      print('❌ Error decoding audio: $e');
    }
  }

  /// Handle barge-in (user interrupting AI)
  Future<void> _handleBargeIn() async {
    // Stop local audio playback immediately
    await player.stop();

    // Send cancel message to server
    ws.sendJson({'type': 'cancel'});

    // Reset barge-in detector
    bargeIn.reset();

    // Update state back to listening
    _updateState(VoiceState.listening);

    print('✅ Barge-in handled, back to listening');
  }

  /// Update state and notify listeners
  void _updateState(VoiceState newState) {
    if (state != newState) {
      state = newState;
      onStateChange?.call(newState);
      print('🔄 State updated: $newState');
    }
  }

  /// Stop the voice session
  Future<void> stopSession() async {
    print('🛑 Stopping voice session...');

    await _micSub?.cancel();
    await _wsSub?.cancel();
    await mic.stop();
    await player.stop();
    await ws.close();

    _updateState(VoiceState.idle);
    print('✅ Voice session stopped');
  }

  /// Handle session cleanup after errors or completion
  void _handleSessionClose() {
    _micSub?.cancel();
    _wsSub?.cancel();
    mic.stop();
    player.stop();
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stopSession();
    await player.dispose();
    await mic.dispose();
  }
}
