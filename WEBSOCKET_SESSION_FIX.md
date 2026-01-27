# WebSocket Session Flow Fix - Removed Duplicate stt_start

## ✅ Issue Fixed

**Problem:** The `stt_start` message was being sent **twice**:
1. Once in `_connectToWebSocket()` (✅ correct location)
2. Again in `_startMicrophone()` (❌ duplicate - now removed)

This caused the server to receive duplicate session initialization messages, which could lead to:
- Session confusion
- Multiple session IDs
- Unexpected behavior

## 🔧 Changes Made

### Before (WRONG):
```dart
Future<void> _startMicrophone() async {
  // ... connection check ...
  
  // ❌ DUPLICATE: stt_start already sent in _connectToWebSocket()
  final sttStartMsg = {
    'type': 'stt_start',
    'session_id': sessionId,
    'voice': 'onyx',
    'audio': {
      'codec': 'pcm16',
      'sr': 16000,
      'ch': 1,
      'frame_ms': 20
    }
  };
  _wsClient?.sendJson(sttStartMsg); // ❌ Sent twice!
  
  // ... mic streamer setup ...
}
```

### After (CORRECT):
```dart
Future<void> _startMicrophone() async {
  // ... connection check ...
  
  // ✅ CORRECT: Just start MicStreamer
  // stt_start already sent in _connectToWebSocket()
  _micStreamer = MicStreamer(channel: _wsClient!.channel!);
  await _micStreamer!.init();
  await _micStreamer!.start();
  
  // ... mic frame handling ...
}
```

## 📋 Correct WebSocket Flow

### 1️⃣ **Connection Phase** (`_connectToWebSocket()`)
```
┌────────────────────────────────────────────┐
│ 1. Connect WebSocket                       │
│    ws://10.10.7.114:8000/ws/chat?token=... │
├────────────────────────────────────────────┤
│ 2. Send stt_start (ONCE!)                  │
│    {                                       │
│      "type": "stt_start",                  │
│      "session_id": "flutter_...",          │
│      "voice": "onyx",                      │
│      "scenario_id": "..."                  │
│    }                                       │
├────────────────────────────────────────────┤
│ 3. Wait for stt_ready                      │
│    Server responds:                        │
│    {                                       │
│      "type": "stt_ready",                  │
│      "session_id": "..."                   │
│    }                                       │
└────────────────────────────────────────────┘
```

### 2️⃣ **Microphone Start Phase** (`_startMicrophone()`)
```
┌────────────────────────────────────────────┐
│ ✅ stt_start already sent - skip!          │
├────────────────────────────────────────────┤
│ 1. Check WebSocket is connected            │
│ 2. Create MicStreamer (reuse SAME channel) │
│ 3. Initialize recorder                     │
│ 4. Start capturing audio                   │
│ 5. Stream PCM16 frames to server           │
│    (only if isSessionReady = true)         │
└────────────────────────────────────────────┘
```

## 🎯 Key Points

### ✅ **Session Initialization Happens Once**
- `stt_start` is sent **ONLY** in `_connectToWebSocket()`
- This happens **BEFORE** user presses mic button
- Server is ready when mic button is pressed

### ✅ **Microphone Button Only Controls Audio**
- When pressed ON: Start MicStreamer, begin audio capture
- When pressed OFF: Stop MicStreamer, stop audio capture
- **Does NOT** send `stt_start` again

### ✅ **Single WebSocket for Everything**
- stt_start message → WebSocket A
- Audio frames → WebSocket A (SAME!)
- TTS responses ← WebSocket A (SAME!)

## 🔍 Why This Matters

### **Before (with duplicate):**
```
Time: T0 - Connect WebSocket
Time: T1 - Send stt_start #1 → Server creates session_1
Time: T2 - Receive stt_ready for session_1
Time: T3 - User presses mic button
Time: T4 - Send stt_start #2 → Server creates session_2 ❌
Time: T5 - Audio frames go to session_2
Time: T6 - TTS responses might go to session_1 ❌ MISMATCH!
```

### **After (single stt_start):**
```
Time: T0 - Connect WebSocket
Time: T1 - Send stt_start #1 → Server creates session_1 ✅
Time: T2 - Receive stt_ready for session_1
Time: T3 - User presses mic button
Time: T4 - Start streaming audio to session_1 ✅
Time: T5 - TTS responses come from session_1 ✅ MATCH!
```

## 📊 Session Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│ INITIALIZATION (onReady)                                │
├─────────────────────────────────────────────────────────┤
│ 1. Connect WebSocket                                    │
│ 2. Send stt_start (ONCE) ◄── ONLY HERE!                │
│ 3. Wait for stt_ready                                   │
│ 4. Set isSessionReady = true                            │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│ USER PRESSES MIC BUTTON                                 │
├─────────────────────────────────────────────────────────┤
│ 1. Create MicStreamer (reuse WebSocket channel)         │
│ 2. Initialize recorder                                  │
│ 3. Start audio capture                                  │
│ 4. Stream PCM16 frames → Server                         │
│ 5. Receive TTS audio ← Server (SAME connection!)        │
└─────────────────────────────────────────────────────────┘
```

## ✅ Verification Checklist

- [x] `stt_start` sent only ONCE in `_connectToWebSocket()`
- [x] `_startMicrophone()` does NOT send `stt_start`
- [x] MicStreamer reuses SAME WebSocket channel
- [x] Audio frames sent only after `isSessionReady = true`
- [x] TTS responses arrive on same WebSocket
- [x] No session ID mismatch
- [x] Code compiles without errors

## 🧪 Testing

### Expected Console Output:
```
╔═══════════════════════════════════════════════════════════╗
║     STEP 1: SENDING stt_start TO SERVER                  ║
╚═══════════════════════════════════════════════════════════╝
📤 Sending JSON: {"type":"stt_start",...}
✅ stt_start sent to server

╔═══════════════════════════════════════════════════════════╗
║     STEP 2: WAITING FOR stt_ready RESPONSE               ║
╚═══════════════════════════════════════════════════════════╝

📥 Message Type: TEXT (JSON)
🏷️  Parsed Type: stt_ready
✅✅✅ stt_ready RECEIVED! ✅✅✅
✅ isSessionReady is now: true

[User presses mic button]

╔═══════════════════════════════════════════════════════════╗
║       STARTING AUDIO CAPTURE (stt_start already sent)    ║
╚═══════════════════════════════════════════════════════════╝
✅ Reusing existing WebSocket channel (SAME as stt_start)
🎙️  Creating MicStreamer with SAME WebSocket
▶️  Starting audio capture...
✅ Audio capture started

📤 Sent 0.6 KB to server (frame #10)
🎤 STT PARTIAL (Live): "hello"
🎯 STT FINAL (Complete): "hello how are you"
🔊 TTS START - AI about to speak
📨 Message Type: BINARY (TTS Audio)  ◄── AI voice on SAME connection!
```

## 📝 Summary

**What was removed:**
- Duplicate `stt_start` message send in `_startMicrophone()`
- Duplicate session ID generation
- Unnecessary 100ms delay

**What remains:**
- Single `stt_start` in `_connectToWebSocket()` ✅
- MicStreamer creation and initialization ✅
- Audio frame streaming logic ✅
- Barge-in detection ✅

**Result:**
- Clean, single-session flow
- No duplicate messages
- Proper session tracking
- TTS responses arrive correctly

---

**Date:** January 26, 2026  
**Status:** ✅ Fixed and Verified  
**Files Modified:** `voice_chat_controller.dart`
