import 'dart:async';
import 'package:austin_small_talk/data/global/shared_preference.dart';
import 'package:austin_small_talk/pages/ai_talk/voice_chat/service/voice_chat_service.dart';
import 'package:austin_small_talk/service/auth/api_constant/api_constant.dart';
import 'package:get/get.dart';

/// Singleton Voice Chat Manager - Maintains persistent WebSocket connection
class VoiceChatManager extends GetxController {
  static VoiceChatManager? _instance;
  
  static VoiceChatManager get instance {
    _instance ??= VoiceChatManager._internal();
    return _instance!;
  }
  
  VoiceChatManager._internal();
  
  VoiceChatService? _voiceChatService;
  final isConnected = false.obs;
  final isInitialized = false.obs;
  
  Timer? _reconnectTimer;
  bool _shouldStayConnected = false;
  
  // ✅ Use voiceChatWs from ApiConstant (correct voice server URL)
  String get _wsUrl => ApiConstant.voiceChatWs;
  
  /// Initialize and connect to WebSocket (called once on app start or first use)
  Future<bool> initialize() async {
    if (isInitialized.value) {
      print('✅ VoiceChatManager already initialized');
      return isConnected.value;
    }
    
    try {
      print('🔌 Initializing VoiceChatManager...');
      print('📡 WebSocket URL: $_wsUrl');
      
      final accessToken = SharedPreferencesUtil.getAccessToken();
      
      _voiceChatService = VoiceChatService(
        serverUrl: _wsUrl,
        voice: 'male',
        accessToken: accessToken,
      );
      
      // ✅ DON'T set onConnected here - let controller handle it
      // Only use onStateChange for internal state tracking
      _voiceChatService?.onStateChange = (state) {
        final wasConnected = isConnected.value;
        isConnected.value = state == VoiceConnectionState.connected;
        
        print('🔌 Connection state changed: $state');
        
        // Handle disconnection for auto-reconnect
        if (wasConnected && !isConnected.value && _shouldStayConnected) {
          print('⚠️ WebSocket disconnected - scheduling reconnect');
          _scheduleReconnect();
        }
      };
      
      isInitialized.value = true;
      
      // Connect to WebSocket
      return await connect();
      
    } catch (e) {
      print('❌ Failed to initialize VoiceChatManager: $e');
      return false;
    }
  }
  
  /// Connect to WebSocket server
  Future<bool> connect({String? scenarioId, String? scenarioTitle}) async {
    if (isConnected.value) {
      print('✅ Already connected to WebSocket');
      return true;
    }
    
    try {
      print('🔌 Connecting to WebSocket...');
      _shouldStayConnected = true;
      
      final success = await _voiceChatService?.connect(
        scenarioId: scenarioId,
        scenarioTitle: scenarioTitle,
      );
      
      if (success == true) {
        print('✅ WebSocket connected successfully');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Connection error: $e');
      _scheduleReconnect();
      return false;
    }
  }
  
  /// Schedule auto-reconnect after disconnect
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    
    print('🔄 Scheduling reconnect in 3 seconds...');
    
    _reconnectTimer = Timer(Duration(seconds: 3), () async {
      if (_shouldStayConnected && !isConnected.value) {
        print('🔄 Attempting to reconnect...');
        await connect();
      }
    });
  }
  
  /// Get the voice chat service instance
  VoiceChatService? get service => _voiceChatService;
  
  /// Disconnect (only when app is closed or user logs out)
  Future<void> disconnect() async {
    print('👋 Disconnecting WebSocket...');
    _shouldStayConnected = false;
    _reconnectTimer?.cancel();
    
    await _voiceChatService?.disconnect();
    isConnected.value = false;
  }
  
  /// Reset (logout or app restart)
  Future<void> reset() async {
    print('🔄 Resetting VoiceChatManager...');
    await disconnect();
    
    _voiceChatService = null;
    isInitialized.value = false;
    _instance = null;
  }
  
  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
