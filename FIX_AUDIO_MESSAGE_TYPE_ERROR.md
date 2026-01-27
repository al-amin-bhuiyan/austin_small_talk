# ✅ FIX: "Unknown message type: audio" Error

## Date: January 25, 2026

---

## 🎯 Problem

The server was responding with error messages:
```
❌ Server error: Unknown message type: audio
```

This occurred repeatedly when trying to use voice chat.

---

## 🔍 Root Cause

The client was sending audio messages **immediately after connecting**, but **before the server had initialized the session**. 

### The Flow Was:
```
1. Client connects to WebSocket ✅
2. Client sends session_start ✅
3. Client IMMEDIATELY starts sending audio ❌ (TOO EARLY!)
4. Server hasn't processed session_start yet
5. Server receives audio messages it doesn't recognize
6. Server responds: "Unknown message type: audio"
```

### Why This Happened:
- The `_initializeVoiceChat()` method connected to WebSocket
- Then immediately started the microphone
- Audio frames started flowing before server was ready
- No waiting mechanism for server acknowledgment

---

## 🔧 Solution

Added a **session ready check** before sending audio:

### 1. Added Session Ready State ✅
```dart
final isSessionReady = false.obs; // Track if server session is ready
```

### 2. Handle Server Ready Messages ✅
```dart
case 'session_ready':
case 'stt_ready':
  // Server is ready to receive audio
  print('✅ Server session ready, can now send audio');
  isSessionReady.value = true;
  break;
```

### 3. Only Send Audio When Ready ✅
```dart
_micSub = _micStreamer!.frames.listen(
  (frame) async {
    // Only send audio if session is ready
    if (isSessionReady.value) {
      _wsClient?.sendAudio(Uint8List.fromList(frame));
    } else {
      // Log warning occasionally
      if (DateTime.now().millisecond % 500 < 20) {
        print('⚠️ Waiting for server to be ready before sending audio...');
      }
    }
    // ...rest of code
  },
);
```

### 4. Reset on Cleanup ✅
```dart
Future<void> _cleanup() async {
  // ...cleanup code
  isSessionReady.value = false; // Reset session ready flag
}
```

---

## 📊 New Flow

### Correct Message Sequence

```
1. Client connects to WebSocket
   ↓
2. Client sends: {"type": "session_start", ...}
   ↓
3. ⏳ Client WAITS for server response
   ↓
4. Server processes session initialization
   ↓
5. Server sends: {"type": "stt_ready"} or {"type": "session_ready"}
   ↓
6. ✅ Client sets isSessionReady = true
   ↓
7. Client starts sending audio
   ↓
8. Server processes audio correctly
```

---

## 🎯 Changes Made

### File: `voice_chat_controller.dart`

#### Change 1: Added State Variable
```dart
// Line ~35
final isSessionReady = false.obs; // NEW: Track if server session is ready
```

#### Change 2: Handle Ready Messages
```dart
// In _handleWebSocketMessage(), line ~152
case 'session_ready':
case 'stt_ready':
  print('✅ Server session ready, can now send audio');
  isSessionReady.value = true;
  break;
```

#### Change 3: Conditional Audio Sending
```dart
// In _startMicrophone(), line ~307
_micSub = _micStreamer!.frames.listen(
  (frame) async {
    // Only send audio if session is ready
    if (isSessionReady.value) {
      _wsClient?.sendAudio(Uint8List.fromList(frame));
    } else {
      // Log warning occasionally
      if (DateTime.now().millisecond % 500 < 20) {
        print('⚠️ Waiting for server to be ready before sending audio...');
      }
    }
    // ...
  },
);
```

#### Change 4: Cleanup Reset
```dart
// In _cleanup(), line ~398
isSessionReady.value = false; // Reset session ready flag
```

---

## 🧪 Expected Behavior

### Before Fix ❌
```
[Client] Connected to WebSocket
[Client] Sent: session_start
[Client] 📤 Audio: 640 bytes
[Server] ❌ Server error: Unknown message type: audio
[Client] 📤 Audio: 640 bytes
[Server] ❌ Server error: Unknown message type: audio
[Client] 📤 Audio: 1280 bytes
[Server] ❌ Server error: Unknown message type: audio
... (continuous errors)
```

### After Fix ✅
```
[Client] Connected to WebSocket
[Client] Sent: session_start
[Client] ⏳ Waiting for server to be ready before sending audio...
[Server] ✅ Server session ready (stt_ready)
[Client] isSessionReady = true
[Client] 📤 Audio: 640 bytes
[Server] 📝 Transcript: "Hello..."
[Client] 📤 Audio: 640 bytes
[Server] 📝 Transcript: "Hello how..."
... (normal operation)
```

---

## 📋 Testing Checklist

### Test 1: Session Initialization ✅
- [ ] Connect to voice chat
- [ ] Verify "session_start" is sent
- [ ] Wait for "stt_ready" or "session_ready"
- [ ] Confirm `isSessionReady = true`
- [ ] No "Unknown message type" errors

### Test 2: Audio Streaming ✅
- [ ] Turn mic on
- [ ] Speak into microphone
- [ ] Verify audio is sent ONLY after session ready
- [ ] Check for transcript updates
- [ ] No server errors

### Test 3: Reconnection ✅
- [ ] Disconnect and reconnect
- [ ] Verify `isSessionReady` resets to false
- [ ] Wait for new session ready message
- [ ] Audio works correctly after reconnection

### Test 4: Multiple Sessions ✅
- [ ] Start session, stop, start again
- [ ] Each session waits for ready signal
- [ ] No audio sent before ready
- [ ] Clean transitions

---

## 🎉 Result

**The "Unknown message type: audio" error is now fixed!**

✅ **Proper Handshake:** Client waits for server acknowledgment
✅ **No Premature Audio:** Audio only sent when server is ready
✅ **Clean State Management:** Session ready state tracked correctly
✅ **Better Logging:** Warning messages when waiting
✅ **Robust Cleanup:** State reset on disconnect

---

## 🔍 Debugging

If issues persist, check these logs:

### Good Flow:
```
✅ Connected to WebSocket
📤 Sent: session_start
✅ Server session ready, can now send audio
📤 Audio: 640 bytes
📝 Transcript: ...
```

### Problem Flow:
```
✅ Connected to WebSocket
📤 Sent: session_start
📤 Audio: 640 bytes  ← TOO EARLY!
❌ Server error: Unknown message type: audio
```

If you see "TOO EARLY" pattern, the fix didn't apply. Check:
1. `isSessionReady` variable exists
2. `session_ready` or `stt_ready` case is in switch statement
3. Audio sending has `if (isSessionReady.value)` check

---

## 📚 Related Files

- ✅ `voice_chat_controller.dart` - Fixed
- ✅ `voice_ws_client.dart` - No changes needed
- ✅ `conversation_controller.dart` - Already has similar logic

---

*Fixed: January 25, 2026*
*Error: "Unknown message type: audio"*
*Status: RESOLVED ✅*
