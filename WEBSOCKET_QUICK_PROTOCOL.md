# ✅ WEBSOCKET PROTOCOL - QUICK REFERENCE

## What Flutter Sends

### 1. Session Start (Once)
```dart
{
  "type": "stt_start",
  "session_id": "timestamp",
  "voice": "female",
  "scenario_id": "scenario_123"
}
```

### 2. Audio Stream (Continuous)
```dart
Uint8List audioChunk; // 640 bytes
channel.sink.add(audioChunk); // RAW BINARY
```

### 3. Cancel (Optional)
```dart
{"type": "cancel"}
```

---

## What Server Sends

### Control
- `stt_ready` - Ready to receive audio
- `stt_partial` - Partial transcript
- `stt_final` - Final transcript
- `ai_reply_text` - AI's response text

### TTS
- `tts_start` - AI started speaking
- `tts_sentence_start` - New sentence
- `audio` - Audio chunk (base64 or binary)
- `tts_sentence_end` - Sentence done
- `tts_complete` - AI finished

### Other
- `interrupted` - Barge-in occurred
- `cancelled` - Cancel confirmed
- `error` - Error message

---

## Key Changes

✅ **Message type:** `session_start` → `stt_start`  
✅ **Audio format:** Base64 JSON → Raw binary  
✅ **VAD:** Server auto-detects speech end  
✅ **Barge-in:** Automatic support  

---

## Audio Format

- **Codec:** PCM16
- **Sample Rate:** 16000 Hz
- **Channels:** 1 (mono)
- **Frame Size:** 640 bytes (20ms)
- **Transmission:** Raw binary (NO JSON)

---

**Status: COMPLETE** ✅
