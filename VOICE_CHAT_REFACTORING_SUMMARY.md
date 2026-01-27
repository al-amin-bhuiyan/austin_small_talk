# Voice Chat Refactoring - Simplified Architecture

## ✅ Changes Made

### 🎯 **Simplified WebSocket Flow**

**Before (Complex):**
- Used custom `VoiceWsClient` wrapper
- `stt_start` sent on page load
- Audio streaming in separate method
- Multiple layers of abstraction

**After (Simple):**
- Direct `WebSocketChannel` usage
- `stt_start` sent when mic button pressed
- Single WebSocket for everything
- Clean, straightforward flow

---

## 📋 New Flow

### **Phase 1: Page Load (onReady)**
```
1. Configure audio session
2. Create TTS player
3. Create barge-in detector
4. Connect WebSocket
5. Set up message listener
✅ Ready - Waiting for user to press mic button
```

### **Phase 2: User Presses Mic Button**
```
1. Send stt_start message (JSON)
   {
     "type": "stt_start",
     "session_id": "flutter_...",
     "voice": "onyx",
     "scenario_id": "..."
   }

2. Wait for stt_ready response

3. Create MicStreamer (using SAME WebSocket)

4. Start audio capture

5. Stream PCM16 audio frames (640 bytes each)
   → Sent as RAW BINARY to server
```

### **Phase 3: Server Responds**
```
Server → Flutter:
- JSON: stt_ready, stt_partial, stt_final
- BINARY: TTS audio (PCM16, 24kHz)
- JSON: tts_start, tts_end, ai_reply_text
```

---

## 🔧 **Key Components**

### **1. WebSocketChannel** (Direct Usage)
```dart
// Create connection
_channel = WebSocketChannel.connect(Uri.parse(wsUrl));

// Send JSON
_channel?.sink.add(jsonEncode(message));

// Send binary audio
_channel?.sink.add(pcm16Bytes);

// Listen to messages
_channel!.stream.listen((msg) {
  if (msg is Uint8List) {
    // Binary TTS audio
  } else if (msg is String) {
    // JSON control messages
  }
});
```

### **2. MicStreamer** (Audio Capture)
```dart
// Create with WebSocket channel
_micStreamer = MicStreamer(channel: _channel!);

// Start recording
await _micStreamer!.init();
await _micStreamer!.start();

// Listen to audio frames
_micStreamer!.frames.listen((frame) {
  // Send RAW PCM16 directly to WebSocket
  _channel?.sink.add(frame);
});
```

### **3. TtsPlayer** (Audio Playback)
```dart
// Create player
_ttsPlayer = TtsPlayer(sampleRate: 24000, numChannels: 1);

// Add incoming audio frames
_ttsPlayer?.addFrame(audioData);

// Auto-plays when enough buffered
```

---

## 📊 **Message Handling**

### **Binary Messages** (TTS Audio)
```dart
if (msg is Uint8List || msg is List<int>) {
  final Uint8List audioData = msg is Uint8List ? msg : Uint8List.fromList(msg);
  _ttsPlayer?.addFrame(audioData);
  isSpeaking.value = true;
}
```

### **JSON Messages** (Control)
```dart
if (msg is String) {
  final jsonMsg = jsonDecode(msg);
  switch (jsonMsg['type']) {
    case 'stt_ready':
      isSessionReady.value = true;
      break;
    case 'stt_final':
      _addUserMessage(jsonMsg['text']);
      break;
    case 'tts_start':
      _ttsPlayer?.clear();
      isSpeaking.value = true;
      break;
    // ... etc
  }
}
```

---

## 🎤 **Microphone Control**

### **Start Microphone**
```dart
1. Check WebSocket connected ✅
2. Send stt_start JSON message
3. Wait 500ms for stt_ready
4. Create MicStreamer with SAME WebSocket
5. Initialize and start recording
6. Listen to frames and send to server
7. Set isMicOn = true
```

### **Stop Microphone**
```dart
1. Cancel mic subscription
2. Stop MicStreamer
3. Dispose MicStreamer
4. Set isMicOn = false
```

---

## 🛑 **Barge-in Detection**

```dart
// Check if user speaks while AI is talking
if (isSpeaking.value) {
  final shouldInterrupt = _bargeInDetector!.processPcm16Frame(frame);
  
  if (shouldInterrupt) {
    // Stop AI audio
    await _ttsPlayer?.stop();
    
    // Send cancel to server
    _channel?.sink.add(jsonEncode({'type': 'cancel'}));
    
    // Reset states
    _bargeInDetector!.reset();
    isSpeaking.value = false;
  }
}
```

---

## 🧹 **Cleanup**

```dart
Future<void> _cleanup() async {
  // 1. Cancel subscriptions
  await _micSub?.cancel();
  await _wsSub?.cancel();
  
  // 2. Stop & dispose audio components
  await _micStreamer?.stop();
  await _micStreamer?.dispose();
  await _ttsPlayer?.stop();
  await _ttsPlayer?.dispose();
  
  // 3. Close WebSocket
  await _channel?.sink.close();
  
  // 4. Cancel animation timer
  _animationTimer?.cancel();
  
  // 5. Reset states
  isMicOn.value = false;
  isConnected.value = false;
  isSpeaking.value = false;
  isSessionReady.value = false;
}
```

---

## ✅ **Benefits of New Architecture**

### **1. Simplicity**
- No custom WebSocket wrapper
- Direct `WebSocketChannel` usage
- Less code, easier to understand

### **2. Reliability**
- Single WebSocket connection
- Clear message flow
- No connection mismatch issues

### **3. Performance**
- Less abstraction overhead
- Direct binary audio transfer
- Efficient message handling

### **4. Maintainability**
- Standard Flutter WebSocket API
- Easy to debug
- Well-documented flow

---

## 🧪 **Testing Checklist**

- [x] ✅ WebSocket connects successfully
- [x] ✅ `stt_start` sent when mic pressed
- [x] ✅ `stt_ready` received from server
- [x] ✅ Audio frames sent as raw binary
- [x] ✅ TTS audio received as binary
- [x] ✅ JSON control messages parsed correctly
- [x] ✅ Barge-in detection works
- [x] ✅ Cleanup properly disposes resources
- [x] ✅ No unused imports or warnings

---

## 📚 **Key Files**

| File | Purpose | Lines of Code |
|------|---------|---------------|
| `voice_chat_controller.dart` | Main controller - simplified | ~730 |
| `mic_streamer.dart` | Audio capture | ~76 |
| `tts_player.dart` | Audio playback | ~150 |
| `barge_in_detector.dart` | Interrupt detection | ~50 |

**Total: ~1000 lines** (vs ~1500 before)

---

## 🎯 **Server Protocol**

### **Flutter → Server**
| Message | Type | Format |
|---------|------|--------|
| Session start | JSON | `{"type": "stt_start", ...}` |
| Audio frames | Binary | Raw PCM16 (640 bytes) |
| Cancel | JSON | `{"type": "cancel"}` |

### **Server → Flutter**
| Message | Type | Format |
|---------|------|--------|
| Session ready | JSON | `{"type": "stt_ready", ...}` |
| STT partial | JSON | `{"type": "stt_partial", ...}` |
| STT final | JSON | `{"type": "stt_final", ...}` |
| TTS audio | Binary | Raw PCM16 (640 bytes) |
| TTS control | JSON | `{"type": "tts_start/end", ...}` |
| AI reply | JSON | `{"type": "ai_reply_text", ...}` |

---

**Date:** January 26, 2026  
**Status:** ✅ Refactored and Verified  
**Architecture:** Simplified Direct WebSocket  
**Server:** ws://10.10.7.114:8000/ws/chat
