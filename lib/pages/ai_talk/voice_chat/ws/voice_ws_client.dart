import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket client for voice chat - handles bidirectional communication
class VoiceWsClient {
  WebSocketChannel? _channel;
  final _controller = StreamController<dynamic>.broadcast();

  /// Stream of messages from server (text and binary)
  Stream<dynamic> get stream => _controller.stream;
  
  /// Expose the WebSocket channel for direct access (needed for MicStreamer)
  WebSocketChannel? get channel => _channel;

  /// Connect to WebSocket server
  Future<void> connect(Uri uri, {String? accessToken}) async {
    try {
      print('🔌 Connecting to: $uri');
      _channel = WebSocketChannel.connect(uri);
      
      // Listen and forward all messages
      _channel!.stream.listen(
        (data) {
          _controller.add(data);
        },
        onError: (error) {
          print('❌ WS Error: $error');
          _controller.addError(error);
        },
        onDone: () {
          print('🔌 WS Closed');
          _controller.close();
        },
      );
      
      print('✅ Connected to WebSocket');
    } catch (e) {
      print('❌ Connection failed: $e');
      rethrow;
    }
  }

  /// Send JSON message to server
  void sendJson(Map<String, dynamic> msg) {
    if (_channel == null) {
      print('⚠️ Cannot send - not connected');
      return;
    }
    
    try {
      final jsonString = jsonEncode(msg);
      print('📤 Sending JSON to server:');
      print('   Type: ${msg['type']}');
      print('   Full message: $jsonString');
      
      _channel!.sink.add(jsonString);
      
      print('✅ JSON message sent successfully');
    } catch (e) {
      print('❌ Send error: $e');
    }
  }

  /// Send audio chunk to server (as raw binary - NOT JSON)
  void sendAudio(Uint8List pcmChunk) {
    if (_channel == null) {
      return;
    }

    try {
      // Send RAW BINARY audio (server expects this, not JSON)
      // Format: PCM16, 16kHz, mono, 640 bytes per frame (20ms)
      _channel!.sink.add(pcmChunk);
      
      // Log occasionally (every ~100ms)
      if (DateTime.now().millisecond % 100 < 20) {
        print('📤 Audio (binary): ${pcmChunk.length} bytes');
      }
    } catch (e) {
      print('❌ Audio send error: $e');
    }
  }

  /// Close WebSocket connection
  Future<void> close() async {
    try {
      await _channel?.sink.close();
      await _controller.close();
      _channel = null;
      print('🔌 Closed');
    } catch (e) {
      print('❌ Close error: $e');
    }
  }
}

