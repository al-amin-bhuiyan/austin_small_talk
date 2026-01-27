# WebSocket Connection Fix - voiceChatWs Not Hitting

## Problem Identified ❌

The WebSocket was trying to connect to the **wrong server URL**.

### Root Cause:

**Before Fix:**
```dart
// In voice_chat_manager.dart
String get _wsUrl {
  final baseUrl = ApiConstant.baseUrl  // http://10.10.7.74:8001/
      .replaceAll('http://', 'ws://')
      .replaceAll('https://', 'wss://')
      .replaceAll(RegExp(r'/+$'), '');
  
  return '$baseUrl/ws/chat';  // ❌ ws://10.10.7.74:8001/ws/chat (WRONG SERVER!)
}
```

**ApiConstant Configuration:**
```dart
// In api_constant.dart
static const String baseUrl = 'http://10.10.7.74:8001/';        // HTTP API Server
static const String wsBaseUrl = 'ws://10.10.7.114:8000/';       // Voice WebSocket Server
static const String voiceChatWs = '${wsBaseUrl}ws/chat';        // ws://10.10.7.114:8000/ws/chat
```

### The Issue:
- ❌ VoiceChatManager was using `ApiConstant.baseUrl` (HTTP API server at :8001)
- ✅ Should use `ApiConstant.voiceChatWs` (Voice WebSocket server at :8000)
- **Different servers:** API server (:8001) vs Voice server (:8000)
- **Different IPs:** 10.10.7.74 vs 10.10.7.114

## Solution Applied ✅

### Fixed Code:
```dart
// In voice_chat_manager.dart
// ✅ Use voiceChatWs from ApiConstant (correct voice server URL)
String get _wsUrl => ApiConstant.voiceChatWs;
```

### What Changed:
- ❌ **Before:** Connecting to `ws://10.10.7.74:8001/ws/chat` (HTTP API server)
- ✅ **After:** Connecting to `ws://10.10.7.114:8000/ws/chat` (Voice WebSocket server)

## Connection Flow (After Fix)

```
VoiceChatManager.initialize()
  ↓
_wsUrl = ApiConstant.voiceChatWs
  ↓
_wsUrl = "ws://10.10.7.114:8000/ws/chat" ✅
  ↓
VoiceChatService(serverUrl: _wsUrl)
  ↓
WebSocketChannel.connect(ws://10.10.7.114:8000/ws/chat?token=xxx)
  ↓
Connected to Voice Server ✅
```

## Testing

### Expected Console Output (After Fix):
```
🔌 Initializing VoiceChatManager...
🔌 Connecting to: ws://10.10.7.114:8000/ws/chat
📡 Connecting to: ws://10.10.7.114:8000/ws/chat?token=xxx
📤 Sending session_start: {...}
✅ Session ready: flutter_xxx
✅ WebSocket connected - staying connected
✅ VoiceChatManager initialized and connected
```

### Before Fix (Wrong Server):
```
❌ Connecting to: ws://10.10.7.74:8001/ws/chat  (Wrong!)
❌ WebSocket error: Connection refused / Timeout
❌ Connection failed
```

### After Fix (Correct Server):
```
✅ Connecting to: ws://10.10.7.114:8000/ws/chat  (Correct!)
✅ WebSocket connected
✅ Session ready
```

## Server Architecture

Your app uses **two separate servers**:

| Server Type | IP | Port | Protocol | Purpose |
|------------|-----|------|----------|---------|
| **HTTP API Server** | 10.10.7.74 | 8001 | HTTP/HTTPS | REST API (login, scenarios, messages) |
| **Voice WebSocket Server** | 10.10.7.114 | 8000 | WebSocket | Real-time voice chat (STT/TTS) |

### Why Two Servers?

1. **HTTP API Server (10.10.7.74:8001)**
   - Handles REST API calls
   - Login, registration, scenarios
   - Text-based chat messages
   - User profile, etc.

2. **Voice WebSocket Server (10.10.7.114:8000)**
   - Handles real-time voice communication
   - Speech-to-Text (STT)
   - Text-to-Speech (TTS)
   - Low-latency audio streaming
   - Separate server for performance

## Files Modified

### ✅ voice_chat_manager.dart
```dart
// Changed from:
String get _wsUrl {
  final baseUrl = ApiConstant.baseUrl
      .replaceAll('http://', 'ws://')
      .replaceAll('https://', 'wss://')
      .replaceAll(RegExp(r'/+$'), '');
  return '$baseUrl/ws/chat';
}

// Changed to:
String get _wsUrl => ApiConstant.voiceChatWs;
```

## Verification Steps

1. **Check Console Logs:**
   ```
   Look for: "Connecting to: ws://10.10.7.114:8000/ws/chat"
   NOT: "Connecting to: ws://10.10.7.74:8001/ws/chat"
   ```

2. **Test Voice Chat:**
   - Navigate to voice chat page
   - Check status shows "Tap mic to start"
   - Press mic button
   - Should show "Listening..." (green)
   - Speak something
   - Wait 3 seconds
   - AI should respond (cyan)

3. **Verify Connection:**
   ```dart
   // In VoiceChatManager
   print('📡 Connecting to: $_wsUrl');
   // Should output: ws://10.10.7.114:8000/ws/chat
   ```

## Summary

✅ **Fixed:** WebSocket now connects to correct voice server
✅ **URL:** `ws://10.10.7.114:8000/ws/chat` (Voice Server)
✅ **Method:** Using `ApiConstant.voiceChatWs` directly
✅ **Result:** Voice chat WebSocket connections will work correctly

The issue was simple but critical - the manager was constructing a WebSocket URL from the HTTP API server address instead of using the pre-configured voice server URL. Now it correctly uses `ApiConstant.voiceChatWs` which points to the dedicated voice WebSocket server at `10.10.7.114:8000`.
