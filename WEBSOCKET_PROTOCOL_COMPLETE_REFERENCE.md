# Voice Chat WebSocket Protocol - Complete Reference

## 🔄 Complete Flow Diagram

```
┌──────────────────────────────────────────────────────────────────────┐
│                   APP LIFECYCLE & WEBSOCKET FLOW                     │
└──────────────────────────────────────────────────────────────────────┘

╔═════════════════════════════════════════════════════════════════════╗
║ PHASE 1: PAGE LOAD (onReady) - AUTO INITIALIZATION                 ║
╚═════════════════════════════════════════════════════════════════════╝

Flutter                                    Server
  │                                           │
  │  1. Connect WebSocket                     │
  ├──────────────────────────────────────────>│
  │  ws://10.10.7.114:8000/ws/chat?token=...  │
  │                                           │
  │  2. Send stt_start (JSON)                 │
  ├──────────────────────────────────────────>│
  │  {                                        │
  │    "type": "stt_start",                   │
  │    "session_id": "flutter_1234567890",    │
  │    "voice": "onyx",                       │
  │    "scenario_id": "scenario_abc123"       │
  │  }                                        │
  │                                           │
  │  3. Receive stt_ready (JSON)              │
  │<──────────────────────────────────────────┤
  │  {                                        │
  │    "type": "stt_ready",                   │
  │    "session_id": "flutter_1234567890"     │
  │  }                                        │
  │                                           │
  │  ✅ isSessionReady = true                 │
  │  ✅ Ready for audio streaming             │
  │                                           │

╔═════════════════════════════════════════════════════════════════════╗
║ PHASE 2: USER PRESSES MIC BUTTON - AUDIO STREAMING STARTS          ║
╚═════════════════════════════════════════════════════════════════════╝

  │  4. User presses mic button               │
  │  ✅ Start MicStreamer                      │
  │  ✅ Begin capturing audio                  │
  │                                           │
  │  5. Stream audio frames (BINARY)          │
  │  Continuous stream of 640-byte chunks     │
  ├──────────────────────────────────────────>│
  │  PCM16, 16kHz, mono (20ms per frame)      │
  ├──────────────────────────────────────────>│
  ├──────────────────────────────────────────>│
  │  ...                                      │
  │                                           │
  │  6. Receive STT partial (JSON)            │
  │<──────────────────────────────────────────┤
  │  { "type": "stt_partial", "text": "he..." }│
  │<──────────────────────────────────────────┤
  │  { "type": "stt_partial", "text": "hello" }│
  │                                           │
  │  7. User stops speaking (VAD detects)     │
  │                                           │
  │  8. Receive STT final (JSON)              │
  │<──────────────────────────────────────────┤
  │  { "type": "stt_final",                   │
  │    "text": "hello how are you" }          │
  │                                           │

╔═════════════════════════════════════════════════════════════════════╗
║ PHASE 3: AI RESPONSE - TTS STREAMING                               ║
╚═════════════════════════════════════════════════════════════════════╝

  │  9. Receive tts_start (JSON)              │
  │<──────────────────────────────────────────┤
  │  { "type": "tts_start",                   │
  │    "response_id": "resp_xyz" }            │
  │  ✅ isSpeaking = true                      │
  │                                           │
  │  10. Receive tts_sentence_start (JSON)    │
  │<──────────────────────────────────────────┤
  │  { "type": "tts_sentence_start",          │
  │    "text": "I'm doing well!" }            │
  │                                           │
  │  11. Receive TTS audio (BINARY)           │
  │  Continuous stream of 640-byte chunks     │
  │<──────────────────────────────────────────┤
  │  PCM16, 24kHz, mono (20ms per frame)      │
  │<──────────────────────────────────────────┤
  │<──────────────────────────────────────────┤
  │  ... (playing on speaker)                 │
  │                                           │
  │  12. Receive tts_sentence_end (JSON)      │
  │<──────────────────────────────────────────┤
  │  { "type": "tts_sentence_end",            │
  │    "text": "I'm doing well!" }            │
  │                                           │
  │  13. Receive ai_reply_text (JSON)         │
  │<──────────────────────────────────────────┤
  │  { "type": "ai_reply_text",               │
  │    "text": "I'm doing well! How are you?" }│
  │                                           │
  │  14. Receive tts_end (JSON)               │
  │<──────────────────────────────────────────┤
  │  { "type": "tts_end",                     │
  │    "response_id": "resp_xyz" }            │
  │  ✅ isSpeaking = false                     │
  │                                           │

╔═════════════════════════════════════════════════════════════════════╗
║ PHASE 4: BARGE-IN (User interrupts AI)                             ║
╚═════════════════════════════════════════════════════════════════════╝

  │  15. AI is speaking (isSpeaking = true)   │
  │  16. User starts speaking (mic detects)   │
  │                                           │
  │  17. Send cancel (JSON)                   │
  ├──────────────────────────────────────────>│
  │  { "type": "cancel" }                     │
  │  ✅ Stop TTS playback immediately          │
  │                                           │
  │  18. Receive interrupted (JSON)           │
  │<──────────────────────────────────────────┤
  │  { "type": "interrupted",                 │
  │    "response_id": "resp_xyz" }            │
  │  ✅ isSpeaking = false                     │
  │                                           │
  │  19. Continue streaming new audio frames  │
  ├──────────────────────────────────────────>│
  │  (User's new question)                    │
  │                                           │

╔═════════════════════════════════════════════════════════════════════╗
║ PHASE 5: USER STOPS MIC - CLEANUP                                  ║
╚═════════════════════════════════════════════════════════════════════╝

  │  20. User presses mic button OFF          │
  │  ✅ Stop MicStreamer                       │
  │  ✅ Stop audio capture                     │
  │  ✅ isMicOn = false                        │
  │                                           │
  │  WebSocket remains open for:              │
  │  - Receiving final STT results            │
  │  - Receiving AI responses                 │
  │  - TTS playback completion                │
  │                                           │

╔═════════════════════════════════════════════════════════════════════╗
║ PHASE 6: PAGE CLOSE - FULL CLEANUP                                 ║
╚═════════════════════════════════════════════════════════════════════╝

  │  21. User leaves page (context.pop())     │
  │  ✅ Stop all streams                       │
  │  ✅ Dispose all resources                  │
  │  ✅ Close WebSocket                        │
  │                                           │
  │  22. Close WebSocket                      │
  ├──────────────────────────────────────────>│
  │                                           │
  │  ✅ Cleanup complete                       │
  │                                           │
```

## 📊 Message Format Reference

### 📤 Flutter → Server (SEND)

| Message Type | Format | When | Data |
|--------------|--------|------|------|
| **stt_start** | JSON | Page load (once) | `{"type": "stt_start", "session_id": "...", "voice": "onyx", "scenario_id": "..."}` |
| **Audio Frames** | Binary | Continuous (when mic ON) | Raw PCM16 bytes, 640 bytes/frame, 16kHz, mono |
| **cancel** | JSON | User interrupts AI | `{"type": "cancel"}` |

### 📥 Server → Flutter (RECEIVE)

| Message Type | Format | Meaning | Action |
|--------------|--------|---------|--------|
| **stt_ready** | JSON | Session initialized | Set `isSessionReady = true` |
| **stt_partial** | JSON | Live transcription | Update `recognizedText` |
| **stt_final** | JSON | Complete transcription | Add to chat history |
| **tts_start** | JSON | AI starting to speak | Set `isSpeaking = true`, clear audio buffer |
| **tts_sentence_start** | JSON | New sentence starting | Prepare sentence buffer |
| **TTS Audio** | Binary | AI voice audio | Add to player, play on speaker |
| **tts_sentence_end** | JSON | Sentence complete | Play buffered audio |
| **ai_reply_text** | JSON | AI's text response | Add to chat history |
| **tts_end** | JSON | AI finished speaking | Set `isSpeaking = false` |
| **interrupted** | JSON | User barged in | Stop playback |
| **error** | JSON | Server error | Show error message |

## 🎯 Critical Rules

### ✅ DO

1. **Send `stt_start` ONCE** - Only in `_connectToWebSocket()`
2. **Reuse SAME WebSocket** - For stt_start, audio, and TTS
3. **Wait for `stt_ready`** - Before sending audio frames
4. **Handle BINARY messages** - TTS audio comes as raw PCM16
5. **Handle JSON messages** - All control messages are JSON strings
6. **Check `isSessionReady`** - Before streaming audio
7. **Detect barge-in** - Send `cancel` if user speaks during TTS
8. **Play TTS immediately** - Add frames to player as they arrive

### ❌ DON'T

1. **DON'T send `stt_start` twice** - Only once on page load
2. **DON'T create new WebSocket** - Reuse existing channel
3. **DON'T wrap audio in JSON** - Send raw binary PCM16
4. **DON'T base64 encode audio** - Server sends raw bytes
5. **DON'T buffer all TTS** - Play sentences as they complete
6. **DON'T ignore binary messages** - That's your TTS audio!

## 🔍 Audio Format Specifications

### User Audio (Flutter → Server)
```
Format: PCM16 (signed 16-bit little-endian)
Sample Rate: 16000 Hz
Channels: 1 (mono)
Frame Size: 640 bytes = 20ms
Bit Depth: 16 bits
Encoding: Raw binary (NO base64, NO JSON)
```

### TTS Audio (Server → Flutter)
```
Format: PCM16 (signed 16-bit little-endian)
Sample Rate: 24000 Hz
Channels: 1 (mono)
Frame Size: 640 bytes = 20ms
Bit Depth: 16 bits
Encoding: Raw binary (NO base64, NO JSON)
```

## 🧪 Testing Checklist

### ✅ Connection Test
- [ ] WebSocket connects successfully
- [ ] `stt_start` sent once
- [ ] `stt_ready` received
- [ ] `isSessionReady` becomes true

### ✅ Audio Streaming Test
- [ ] Mic button turns ON microphone
- [ ] Audio frames (640 bytes) sent to server
- [ ] `stt_partial` messages received
- [ ] `stt_final` received after speech ends

### ✅ TTS Response Test
- [ ] `tts_start` received
- [ ] Binary audio frames received
- [ ] Audio plays on phone speaker
- [ ] `tts_end` received
- [ ] `isSpeaking` becomes false

### ✅ Barge-in Test
- [ ] User speaks while AI is talking
- [ ] `cancel` message sent
- [ ] AI audio stops immediately
- [ ] `interrupted` message received
- [ ] New STT processing begins

### ✅ Cleanup Test
- [ ] Mic button turns OFF microphone
- [ ] Audio capture stops
- [ ] WebSocket remains open
- [ ] Page close cleans up everything

## 📝 Console Output Examples

### ✅ Successful Flow
```
═══════════════════════════════════════════════════════════
🚀 VoiceChatController.onInit() - Controller Initializing
═══════════════════════════════════════════════════════════
✅ onInit() complete - Animation started

═══════════════════════════════════════════════════════════
🎯 VoiceChatController.onReady() - Page Ready
═══════════════════════════════════════════════════════════

╔═══════════════════════════════════════════════════════════╗
║          CONNECTING TO WEBSOCKET SERVER                  ║
╚═══════════════════════════════════════════════════════════╝
🔌 Connecting to: ws://10.10.7.114:8000/ws/chat?token=...
✅ WebSocket connected successfully

╔═══════════════════════════════════════════════════════════╗
║     STEP 1: SENDING stt_start TO SERVER                  ║
╚═══════════════════════════════════════════════════════════╝
📤 Sending JSON: {"type":"stt_start","session_id":"flutter_..."}
✅ stt_start sent to server

┌───────────────────────────────────────────────────────────┐
│           INCOMING WEBSOCKET MESSAGE                      │
└───────────────────────────────────────────────────────────┘
📨 Message Type: TEXT (JSON)
🏷️  Parsed Type: stt_ready
╔═══════════════════════════════════════════════════════════╗
║      ✅✅✅ stt_ready RECEIVED! ✅✅✅                      ║
╚═══════════════════════════════════════════════════════════╝
✅ isSessionReady is now: true

[User presses mic button]

╔═══════════════════════════════════════════════════════════╗
║              STARTING MICROPHONE                          ║
╚═══════════════════════════════════════════════════════════╝
╔═══════════════════════════════════════════════════════════╗
║       STARTING AUDIO CAPTURE (stt_start already sent)    ║
╚═══════════════════════════════════════════════════════════╝
✅ Microphone started successfully

🎙️  Frame #1 received (640 bytes)
📤 Sent 0.6 KB to server (frame #10)

📨 Message Type: TEXT (JSON)
🎤 STT PARTIAL (Live): "hel"
🎤 STT PARTIAL (Live): "hello"
🎯 STT FINAL (Complete): "hello how are you"

🔊 TTS START - AI about to speak
📝 TTS SENTENCE START: "I'm doing well, thank you!"

📨 Message Type: BINARY (TTS Audio)
📏 Audio Length: 640 bytes
🔊 isSpeaking = true
✅ Audio frame added to TTS player

✅ TTS SENTENCE END
✅ TTS COMPLETE - AI finished speaking
🔊 isSpeaking = false
👂 Back to listening mode
```

---

## 📚 Key Files

| File | Purpose |
|------|---------|
| `voice_chat_controller.dart` | Main controller - WebSocket handling, state management |
| `voice_ws_client.dart` | WebSocket client - Connection, send/receive |
| `mic_streamer.dart` | Microphone capture - PCM16 audio recording |
| `tts_player.dart` | Audio playback - TTS audio player |
| `barge_in_detector.dart` | Interrupt detection - VAD for user speech |

---

**Date:** January 26, 2026  
**Status:** ✅ Complete and Verified  
**Protocol Version:** 1.0  
**Server:** ws://10.10.7.114:8000/ws/chat
