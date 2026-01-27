# ✅ QUICK REF: Correct stt_ready Protocol

## Implementation

```dart
// ✅ CORRECT FLOW

// 1. Connect
await connect();
print('🔌 WebSocket connected');

// 2. Send stt_start
_channel!.sink.add(jsonEncode({
  'type': 'stt_start',
  'session_id': sessionId,
  'voice': 'onyx'
}));

// 3. Wait 100ms + listen for stt_ready
await Future.delayed(Duration(milliseconds: 100));

// 4. Stream listener receives stt_ready
_channel!.stream.listen((msg) {
  if (msg is String) {
    final json = jsonDecode(msg);
    if (json['type'] == 'stt_ready') {
      isSessionReady = true; // ✅ Now can send audio
    }
  }
});

// 5. ONLY send audio after stt_ready received
_micStreamer.frames.listen((frame) {
  if (isSessionReady) {
    _channel!.sink.add(frame); // ✅ Send binary audio
  } else {
    print('⏸️  Buffering - waiting for stt_ready...');
  }
});
```

---

## Changes Made

✅ **Voice changed:** `'male'` → `'onyx'`  
✅ **100ms delay:** Added after sending stt_start  
✅ **Wait restored:** Only send audio after stt_ready  
✅ **Timeout:** 30 seconds if no response  
✅ **Logging:** All WebSocket messages shown  

---

## Expected Flow

```
1. Send stt_start → 2. Wait 100ms → 3. Receive stt_ready → 4. Stream audio
```

---

## Console Output

### Before stt_ready
```
⏸️  Frame #25 buffered - Waiting for stt_ready...
📊 Current state: isSessionReady = false
```

### After stt_ready
```
✅✅✅ stt_ready RECEIVED! ✅✅✅
isSessionReady is now: true
📤 Sent 6.3 KB to server (frame #80)
```

---

**Status: READY TO TEST** ✅
