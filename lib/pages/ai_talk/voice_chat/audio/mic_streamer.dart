import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Microphone Audio Streamer
/// Captures audio from mic and sends RAW PCM16 bytes to server
/// Format: PCM16, 16kHz, mono, 640 bytes per frame (20ms)
class MicStreamer {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final StreamController<Uint8List> _frames = StreamController.broadcast();
  bool _isInitialized = false;

  // Constructor accepts channel for compatibility but audio is sent in controller
  MicStreamer({required WebSocketChannel channel});

  Stream<Uint8List> get frames => _frames.stream;

  Future<void> init() async {
    print('🎙️  Initializing microphone recorder...');

    try {
      // ✅ Check microphone permission first
      print('🔐 Checking microphone permission...');
      final status = await Permission.microphone.status;
      print('   Current status: $status');

      if (!status.isGranted) {
        print('⚠️  Microphone permission not granted - requesting...');
        final result = await Permission.microphone.request();
        print('   Permission request result: $result');

        if (!result.isGranted) {
          print('❌ Microphone permission denied by user');
          throw Exception(
            'Microphone permission denied. Please enable microphone access in settings.',
          );
        }
        print('✅ Microphone permission granted');
      } else {
        print('✅ Microphone permission already granted');
      }

      // ✅ Close any existing session before opening new one
      try {
        print('⚠️  Attempting to close any existing recorder session...');
        await _recorder.closeRecorder();
        print('✅ Previous recorder session closed');

        // Wait for audio resources to be fully released
        await Future.delayed(Duration(milliseconds: 200));
        print('✅ Audio resources released');
      } catch (e) {
        // Recorder wasn't open - that's fine
        print('   (No existing session to close)');
      }

      print('🔓 Opening new recorder session...');
      print('🔓 Opening new recorder session...');
      await _recorder.openRecorder();
      _isInitialized = true;
      print('✅ Recorder opened successfully');
      print('   Status: Ready to start recording');
    } catch (e) {
      print('❌ Failed to initialize recorder: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> start() async {
    print('▶️  Starting microphone recording...');

    if (!_isInitialized) {
      print('❌ Cannot start - recorder not initialized');
      throw Exception('Recorder not initialized. Call init() first.');
    }

    try {
      print('🎙️  Starting recorder...');
      print('   Format: PCM16, 16kHz, mono');
      print('   Frame size: 640 bytes (20ms)');

      // Start recording to stream
      await _recorder.startRecorder(
        toStream: _frames.sink,
        codec: Codec.pcm16,
        numChannels: 1, // Mono channel
        sampleRate: 16000, // 16kHz sample rate to match backend
      );

      print('✅ Microphone started');

      // Audio frames are sent directly in the controller
      // No need to listen and send here - cleaner architecture
    } catch (e) {
      print('❌ Failed to start recorder: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    print('🛑 Stopping microphone...');

    try {
      if (_recorder.isRecording) {
        await _recorder.stopRecorder();
        print('✅ Microphone stopped');
      } else {
        print('⚠️  Recorder not recording - nothing to stop');
      }
    } catch (e) {
      print('❌ Error stopping recorder: $e');
      // Don't rethrow - allow cleanup to continue
    }
  }

  Future<void> dispose() async {
    print('🧹 Disposing microphone resources...');

    try {
      // Stop if still recording
      if (_recorder.isRecording) {
        await stop();
        // Wait for resources to be released
        await Future.delayed(Duration(milliseconds: 100));
      }

      // ✅ Only close if initialized to prevent "Recorder already close" error
      if (_isInitialized) {
        try {
          await _recorder.closeRecorder();
          _isInitialized = false;
          print('✅ Recorder closed');
        } catch (e) {
          print('⚠️  Recorder close error (may already be closed): $e');
        }
      } else {
        print('⚠️  Recorder already closed, skipping');
      }

      // Close stream if not already closed
      if (!_frames.isClosed) {
        try {
          await _frames.close();
          print('✅ Stream closed');
        } catch (e) {
          print('⚠️  Stream close error: $e');
        }
      }

      print('✅ Microphone disposed');
    } catch (e) {
      print('❌ Error disposing recorder: $e');
      // Don't rethrow - we're cleaning up anyway
    }
  }
}
