# Voice Chat WebSocket Implementation - Complete

## ✅ Implementation Complete

A full real-time voice chat system has been implemented using WebSocket for bi-directional communication with the AI server.

---

## 📦 New Dependencies Added

Added to `pubspec.yaml`:
```yaml
web_socket_channel: ^3.0.0    # WebSocket communication
just_audio: ^0.9.40           # Audio playback
record: ^5.1.2                # Microphone recording
path_provider: ^2.1.4         # File paths
```

Run `flutter pub get` to install.

---

## 📁 File Structure

```
lib/pages/ai_talk/voice_chat/
├── voice_chat.dart              # UI Screen
├── voice_chat_controller.dart   # Main controller
├── ws/
│   └── voice_ws_client.dart     # WebSocket client
└── audio/
    ├── mic_streamer.dart        # Microphone streaming
    └── tts_player.dart          # AI audio playback
```

---

## 🔌 WebSocket Protocol

### Messages FROM Client → Server

```json
// 1. START SESSION
{
  "type": "start_session",
  "in_codec": "pcm16",
  "in_sr": 16000,
  "channels": 1,
  "frame_ms": 20,
  "out_codec": "pcm16",
  "out_sr": 24000
}

// 2. SET SCENARIO
{
  "type": "set_scenario",
  "scenario": "Talking with the doctor"
}

// 3. CANCEL (Interrupt AI)
{
  "type": "cancel"
}

// 4. PAUSE
{
  "type": "pause"
}

// 5. RESUME
{
  "type": "resume"
}

// 6. END SESSION
{
  "type": "end_session"
}

// 7. BINARY - Raw PCM16 audio bytes (Uint8List)
```

### Messages FROM Server → Client

```json
// 1. SESSION STARTED
{
  "type": "session_started",
  "session_id": "abc123"
}

// 2. STATE CHANGE
{
  "type": "state",
  "value": "listening" // or "ai_speaking" or "processing"
}

// 3. TRANSCRIPT
{
  "type": "transcript",
  "text": "Hello, how are you?",
  "is_final": true
}

// 4. AI RESPONSE
{
  "type": "ai_response",
  "text": "I'm doing well, thank you!"
}

// 5. AI AUDIO DONE
{
  "type": "ai_audio_done"
}

// 6. ERROR
{
  "type": "error",
  "code": "connection_failed",
  "message": "Failed to process audio"
}

// 7. BINARY - Raw PCM16 audio bytes (AI voice)
```

---

## 🎮 Button States

### MIC OFF (Idle)
```
┌─────────┐    ┌─────────┐    ┌─────────┐
│  PAUSE  │    │   MIC   │    │  CLOSE  │
│ (grey)  │    │  (grey) │    │(purple) │
│disabled │    │mic_off  │    │ enabled │
└─────────┘    └─────────┘    └─────────┘
```

### MIC ON + LISTENING
```
┌─────────┐    ┌─────────┐    ┌─────────┐
│  PAUSE  │    │   MIC   │    │  CLOSE  │
│(purple) │    │ (blue)  │    │(purple) │
│ enabled │    │  mic    │    │ enabled │
└─────────┘    └─────────┘    └─────────┘
               + blob anim
               + siri wave
```

### MIC ON + AI SPEAKING
```
┌─────────┐    ┌─────────┐    ┌─────────┐
│  STOP   │    │   MIC   │    │  CLOSE  │
│(purple) │    │ (blue)  │    │(purple) │
│interrupt│    │  mic    │    │ enabled │
└─────────┘    └─────────┘    └─────────┘
```

---

## 🔧 Components

### 1. VoiceWsClient (`ws/voice_ws_client.dart`)

WebSocket client for real-time communication:

```dart
final wsClient = VoiceWsClient(
  inputSampleRate: 16000,
  outputSampleRate: 24000,
  channels: 1,
  frameMs: 20,
);

// Connect
await wsClient.connect('wss://server.com/voice', accessToken: token);

// Start session
wsClient.startSession();

// Set scenario
wsClient.setScenario('Talking with the doctor');

// Send audio
wsClient.sendAudio(audioBytes);

// Interrupt AI
wsClient.cancel();

// End session
wsClient.endSession();

// Callbacks
wsClient.onSessionStarted = (sessionId) { ... };
wsClient.onStateChanged = (state) { ... };
wsClient.onTranscript = (text, isFinal) { ... };
wsClient.onAiResponse = (text) { ... };
wsClient.onAudioReceived = (audioData) { ... };
```

### 2. MicStreamer (`audio/mic_streamer.dart`)

Real-time microphone streaming:

```dart
final mic = MicStreamer(sampleRate: 16000, numChannels: 1);

mic.onAudioData = (data) => wsClient.sendAudio(data);

await mic.startStreaming();
mic.pause();
mic.resume();
await mic.stopStreaming();
```

### 3. TtsPlayer (`audio/tts_player.dart`)

AI audio playback:

```dart
final tts = TtsPlayer(sampleRate: 24000, numChannels: 1);

tts.onPlaybackStarted = () { ... };
tts.onPlaybackFinished = () { ... };

tts.addAudioData(audioBytes);  // Add to queue
tts.stop();                    // Stop playback
```

### 4. VoiceChatController

Main controller orchestrating all components:

```dart
// States
isConnected.value   // WebSocket connected
isMicOn.value       // Mic is on
isListening.value   // Currently listening
isProcessing.value  // Processing speech
isSpeaking.value    // AI is speaking
isPaused.value      // Mic is paused

// Actions
controller.toggleMic()      // Start/stop mic
controller.pauseMic()       // Pause streaming
controller.resumeMic()      // Resume streaming
controller.interruptAI()    // Cancel AI response
controller.goBack(context)  // Exit and cleanup
```

---

## 🎨 UI Features

### Voice Chat Screen

1. **App Bar** - Shows scenario title
2. **Messages Area** - Chat bubbles for user and AI
3. **Control Buttons**:
   - Pause/Interrupt button (left)
   - Mic button with blob animation (center)
   - Close button (right)
4. **Siri Wave** - Animated waveform when listening
5. **Status Text** - Shows current state

### Visual Effects

- **Siri Wave**: Blue animated wave when listening
- **Wave Blob**: Pulsing blob around mic button
- **Gradient Colors**:
  - Mic ON: Blue gradient
  - Mic OFF: Grey gradient
  - Buttons: Purple gradient

---

## 🔄 Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ USER OPENS VOICE CHAT SCREEN                                 │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ USER TAPS MIC BUTTON                                         │
│                                                              │
│ 1. Request microphone permission                             │
│ 2. Connect to WebSocket                                      │
│ 3. Send start_session                                        │
│ 4. Set scenario (if available)                               │
│ 5. Start mic streaming                                       │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ LISTENING STATE                                              │
│                                                              │
│ - Mic streams PCM16 audio to server                          │
│ - Siri wave animation active                                 │
│ - Server sends transcript (partial & final)                  │
│ - UI shows live transcription bubble                         │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ AI RESPONDING                                                │
│                                                              │
│ - Server sends ai_response text                              │
│ - Server streams audio (binary frames)                       │
│ - TtsPlayer plays audio                                      │
│ - User can tap STOP to interrupt                             │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ CYCLE CONTINUES...                                           │
│                                                              │
│ User speaks → AI responds → User speaks → ...                │
└─────────────────────────────────────────────────────────────┘
```

---

## 🧪 Testing

### Test Microphone Permission
```
1. Tap mic button
2. Accept permission dialog
3. Mic should turn blue
4. Blob animation should appear
```

### Test WebSocket Connection
```
1. Check console for: "✅ Voice WebSocket connected"
2. Check console for: "📤 Sent start_session"
3. Check console for: "📥 Session started: [id]"
```

### Test Voice Flow
```
1. Speak into microphone
2. See live transcript appear
3. Wait for AI response
4. Hear AI audio playback
```

### Test Interrupt (Barge-in)
```
1. While AI is speaking
2. Tap STOP button
3. AI should stop immediately
4. Mic should resume listening
```

---

## 📝 API Configuration

Update WebSocket URL in `lib/service/auth/api_constant/api_constant.dart`:

```dart
// WebSocket URL for voice chat
static const String wsBaseUrl = 'ws://10.10.7.74:8001/';
static const String voiceChatWs = '${wsBaseUrl}core/chat/voice/';
```

---

## ✅ Checklist

- [x] WebSocket client with full protocol support
- [x] Microphone streaming with PCM16 audio
- [x] TTS player for AI audio
- [x] VoiceChatController orchestrating all components
- [x] UI with blob animation, siri wave, and button states
- [x] Scenario data integration
- [x] Pause/Resume functionality
- [x] Interrupt (barge-in) support
- [x] Error handling
- [x] Proper cleanup on exit

---

## 🚀 Ready to Use

The voice chat system is now complete! 

To test:
1. Run `flutter pub get`
2. Update WebSocket URL to your server
3. Open voice chat screen
4. Tap the mic button
5. Start talking!

---

**Status:** ✅ **COMPLETE**

All WebSocket protocol messages implemented and UI with button states ready!
