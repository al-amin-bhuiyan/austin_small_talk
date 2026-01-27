import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

enum VoiceConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

class VoiceChatService {
  WebSocketChannel? _channel;
  FlutterSoundRecorder? _recorder;
  String? sessionId;
  String serverUrl;
  String voice;
  String? accessToken;

  // Callbacks
  Function(String text)? onSttPartial;
  Function(String text)? onSttFinal;
  Function(String text)? onAiReply;
  Function(Uint8List audio)? onTtsAudio;
  Function()? onTtsStart;
  Function()? onTtsComplete;
  Function()? onTtsSentenceStart;
  Function()? onTtsSentenceEnd;
  Function(String error)? onError;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(VoiceConnectionState state)? onStateChange;
  Function()? onInterrupted;
  // ✅ FIX #5: Permission denied callback
  Function()? onPermissionDenied;

  bool _isRecording = false;
  bool _isRecorderInitialized = false;
  bool _isClosing = false; // ✅ FIX #7: Track closing state

  // Real-time streaming
  StreamSubscription<Uint8List>? _audioStreamSubscription;
  StreamController<Uint8List>? _audioStreamController;
  int _totalBytesSent = 0;

  VoiceConnectionState _state = VoiceConnectionState.disconnected;

  VoiceConnectionState get state => _state;

  VoiceChatService({
    required this.serverUrl,
    this.voice = 'male',
    this.accessToken,
  });

  void _setState(VoiceConnectionState newState) {
    _state = newState;
    onStateChange?.call(newState);
  }

  /// Initialize recorder
  Future<void> _initializeRecorder() async {
    if (_isRecorderInitialized) return;

    try {
      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();
      _isRecorderInitialized = true;
      print('✅ Recorder initialized');
    } catch (e) {
      print('❌ Failed to initialize recorder: $e');
      throw Exception('Failed to initialize recorder: $e');
    }
  }

  /// Connect to WebSocket server
  Future<bool> connect({String? scenarioId, String? scenarioTitle}) async {
    // ✅ FIX #7: Don't connect if closing
    if (_isClosing) {
      print('⚠️ Cannot connect - service is closing');
      return false;
    }

    try {
      print('🔌 Connecting to: $serverUrl');
      _setState(VoiceConnectionState.connecting);

      await _initializeRecorder();

      final uri = Uri.parse(serverUrl);
      if (uri.scheme != 'ws' && uri.scheme != 'wss') {
        throw Exception('Invalid WebSocket URL scheme: ${uri.scheme}');
      }

      final wsUri = accessToken != null
          ? uri.replace(queryParameters: {'token': accessToken})
          : uri;

      print('📡 Connecting to: $wsUri');

      _channel = WebSocketChannel.connect(wsUri);

      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          print('❌ WebSocket error: $error');
          _setState(VoiceConnectionState.error);
          onError?.call('WebSocket error: $error');
        },
        onDone: () {
          print('👋 WebSocket closed');
          // ✅ FIX #7: Only notify if not intentionally closing
          if (!_isClosing) {
            _setState(VoiceConnectionState.disconnected);
            onDisconnected?.call();
          }
        },
      );

      sessionId = 'flutter_${DateTime.now().millisecondsSinceEpoch}';

      final startMessage = {
        'type': 'session_start',
        'session_id': sessionId,
        'voice': voice,
        if (scenarioId != null) 'scenario_id': scenarioId,
        if (scenarioTitle != null) 'scenario': scenarioTitle,
        'audio': {
          'codec': 'pcm16',
          'sr': 16000,
          'ch': 1,
          'frame_ms': 20,
        },
      };

      print('📤 Sending session_start: $startMessage');
      _channel!.sink.add(jsonEncode(startMessage));

      await Future.delayed(Duration(milliseconds: 500));

      _setState(VoiceConnectionState.connected);
      return true;
    } catch (e) {
      print('❌ Connection failed: $e');
      _setState(VoiceConnectionState.error);
      onError?.call('Connection failed: $e');
      return false;
    }
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    // ✅ FIX #7: Ignore messages if closing
    if (_isClosing) return;

    if (message is Uint8List) {
      onTtsAudio?.call(message);
      return;
    }

    if (message is String) {
      try {
        final data = jsonDecode(message);
        final type = data['type'];

        switch (type) {
          case 'stt_ready':
            print('✅ Session ready: ${data['session_id']}');
            onConnected?.call();
            break;

          case 'stt_partial':
            final text = data['text'] ?? '';
            print('🎤 STT Partial: $text');
            onSttPartial?.call(text);
            break;

          case 'stt_final':
            final text = data['text'] ?? '';
            print('🎯 STT Final: $text');
            onSttFinal?.call(text);
            break;

          case 'ai_reply_text':
            final text = data['text'] ?? '';
            print('🤖 AI Reply: $text');
            onAiReply?.call(text);
            break;

          case 'tts_start':
            print('🔊 TTS Started');
            onTtsStart?.call();
            break;

          case 'tts_sentence_start':
            print('📝 TTS Sentence Start');
            onTtsSentenceStart?.call();
            break;

          case 'tts_sentence_end':
            print('✅ TTS Sentence End');
            onTtsSentenceEnd?.call();
            break;

          case 'tts_complete':
          case 'tts_end':
            print('✅ TTS Complete');
            onTtsComplete?.call();
            break;

          case 'interrupted':
            print('🛑 Server sent interruption event');
            onInterrupted?.call();
            break;

          case 'error':
            final errorMsg = data['message'] ?? 'Unknown error';
            print('❌ Server error: $errorMsg');
            onError?.call(errorMsg);
            break;

          default:
            print('⚠️ Unknown message type: $type');
        }
      } catch (e) {
        print('❌ Error parsing message: $e');
      }
    }
  }

  /// ✅ FIX #5: Check microphone permission before starting
  Future<PermissionStatus> checkMicrophonePermission() async {
    return await Permission.microphone.status;
  }

  /// Start recording - real-time streaming
  Future<bool> startRecording() async {
    print('🎤 startRecording() called');
    
    // ✅ FIX #7: Don't start if closing
    if (_isClosing) {
      print('⚠️ Cannot start recording - service is closing');
      return false;
    }
    
    if (_isRecording) {
      print('⚠️ Already recording');
      return true;
    }
    
    // ✅ Check if WebSocket channel exists
    if (_channel == null) {
      print('❌ WebSocket channel is NULL - cannot stream audio');
      onError?.call('WebSocket not connected');
      return false;
    }

    if (!_isRecorderInitialized || _recorder == null) {
      print('🎤 Initializing recorder...');
      try {
        await _initializeRecorder();
      } catch (e) {
        print('❌ Failed to initialize recorder: $e');
        onError?.call('Failed to initialize recorder: $e');
        return false;
      }
    }

    try {
      // ✅ FIX #5: Better permission handling
      final status = await Permission.microphone.status;
      
      if (status.isDenied) {
        print('🎤 Requesting microphone permission...');
        final result = await Permission.microphone.request();
        
        if (result.isDenied) {
          print('❌ Microphone permission denied');
          onError?.call('Microphone permission denied. Please enable it in Settings.');
          onPermissionDenied?.call();
          return false;
        }
        
        if (result.isPermanentlyDenied) {
          print('❌ Microphone permission permanently denied');
          onError?.call('Microphone permission permanently denied. Please enable it in Settings.');
          onPermissionDenied?.call();
          return false;
        }
      }
      
      if (status.isPermanentlyDenied) {
        print('❌ Microphone permission permanently denied');
        onError?.call('Microphone access is blocked. Please enable it in your device Settings.');
        onPermissionDenied?.call();
        return false;
      }

      print('🎤 Starting audio stream...');
      _totalBytesSent = 0;

      _audioStreamController = StreamController<Uint8List>();

      await _recorder!.startRecorder(
        toStream: _audioStreamController!.sink,
        codec: Codec.pcm16,
        sampleRate: 16000,
        numChannels: 1,
      );
      
      print('✅ Recorder started');

      _isRecording = true;

      _audioStreamSubscription = _audioStreamController!.stream.listen(
        (audioChunk) {
          // ✅ FIX #7: Check states before sending
          if (_channel != null && _isRecording && !_isClosing) {
            try {
              _channel!.sink.add(audioChunk);
              _totalBytesSent += audioChunk.length;

              // Log every 10KB to reduce spam
              if (_totalBytesSent % 10000 < audioChunk.length) {
                print('📤 Streaming... ${(_totalBytesSent / 1000).toStringAsFixed(1)}KB sent');
              }
            } catch (e) {
              print('❌ Error sending chunk: $e');
              // ✅ FIX #7: Stop recording on send error
              stopRecording();
            }
          }
        },
        onError: (error) {
          print('❌ Stream error: $error');
          stopRecording();
        },
        onDone: () {
          print('✅ Stream completed');
        },
        cancelOnError: true, // ✅ FIX #7: Cancel on error
      );

      print('✅ REAL-TIME streaming active!');
      
      return true;

    } catch (e) {
      print('❌ Failed to start recording: $e');
      _isRecording = false;

      await _audioStreamSubscription?.cancel();
      _audioStreamSubscription = null;
      await _audioStreamController?.close();
      _audioStreamController = null;

      onError?.call('Failed to start recording: $e');
      return false;
    }
  }

  /// Stop recording
  Future<void> stopRecording() async {
    if (!_isRecording) {
      print('⚠️ Not recording - nothing to stop');
      return;
    }

    print('🛑 Stopping real-time stream...');

    try {
      _isRecording = false;

      // ✅ FIX #7: Cancel subscription first
      if (_audioStreamSubscription != null) {
        await _audioStreamSubscription!.cancel();
        _audioStreamSubscription = null;
        print('✅ Stream subscription cancelled');
      }

      if (_audioStreamController != null) {
        await _audioStreamController!.close();
        _audioStreamController = null;
        print('✅ Stream controller closed');
      }

      if (_recorder != null && _isRecorderInitialized) {
        try {
          await _recorder!.stopRecorder();
          print('✅ Recorder stopped');
        } catch (e) {
          print('⚠️ Recorder stop error (non-fatal): $e');
        }
      }

      print('📤 Total audio sent: ${(_totalBytesSent / 1000).toStringAsFixed(1)}KB');

      // ✅ FIX #7: Only send audio_end if channel is still open
      if (_channel != null && !_isClosing) {
        print('📤 Sending audio_end');
        try {
          _channel!.sink.add(jsonEncode({'type': 'audio_end'}));
        } catch (e) {
          print('⚠️ Failed to send audio_end: $e');
        }
      }

      _totalBytesSent = 0;
      print('✅ Stream stopped');

    } catch (e) {
      print('❌ Error stopping: $e');
      _isRecording = false;
      _audioStreamSubscription = null;
      _audioStreamController = null;
      _totalBytesSent = 0;
    }
  }

  /// Cancel current TTS playback
  void cancel() {
    if (_channel != null && !_isClosing) {
      print('🚫 Canceling TTS');
      try {
        _channel!.sink.add(jsonEncode({'type': 'cancel'}));
      } catch (e) {
        print('⚠️ Failed to send cancel: $e');
      }
    }
  }

  /// Send audio_end signal to trigger AI response (without stopping mic)
  void sendAudioEnd() {
    if (_channel != null && !_isClosing) {
      print('📤 Sending audio_end signal (mic still on)');
      try {
        _channel!.sink.add(jsonEncode({'type': 'audio_end'}));
      } catch (e) {
        print('⚠️ Failed to send audio_end: $e');
      }
    }
  }

  /// Disconnect from server
  Future<void> disconnect() async {
    print('👋 Disconnecting...');
    
    // ✅ FIX #7: Set closing flag first
    _isClosing = true;

    _isRecording = false;

    await _audioStreamSubscription?.cancel();
    _audioStreamSubscription = null;

    await _audioStreamController?.close();
    _audioStreamController = null;

    if (_isRecorderInitialized && _recorder != null) {
      try {
        await _recorder!.closeRecorder();
      } catch (e) {
        print('⚠️ Close error: $e');
      }
      _isRecorderInitialized = false;
      _recorder = null;
    }

    try {
      await _channel?.sink.close();
    } catch (e) {
      print('⚠️ Channel close error: $e');
    }
    _channel = null;

    _setState(VoiceConnectionState.disconnected);
    _isClosing = false;
    print('✅ Disconnected');
  }

  bool get isConnected => _state == VoiceConnectionState.connected;
  bool get isRecording => _isRecording;
}