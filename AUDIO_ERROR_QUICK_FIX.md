# ✅ QUICK FIX: "Unknown message type: audio"

## Problem
```
❌ Server error: Unknown message type: audio (repeated)
```

## Cause
Client sent audio **before** server was ready

## Solution

### 1. Added Session Ready Flag
```dart
final isSessionReady = false.obs;
```

### 2. Wait for Server Ready
```dart
case 'session_ready':
case 'stt_ready':
  isSessionReady.value = true;
```

### 3. Conditional Audio Sending
```dart
if (isSessionReady.value) {
  _wsClient?.sendAudio(frame);
} else {
  print('⚠️ Waiting for server...');
}
```

## Flow

```
Connect → Send session_start → Wait for stt_ready → Send audio ✅
```

## Result

✅ No more "Unknown message type" errors
✅ Proper session initialization
✅ Audio sent only when server is ready

---

**Status: FIXED** ✅
