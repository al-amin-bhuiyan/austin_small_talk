# 🎙️ Audio Streaming & Barge-In Flow Explained

## 📊 Overview
This document explains how audio data flows through the system and how barge-in detection works.

---

## 🔊 TTS PLAYBACK - Receiving & Playing Audio from Server

### **1. Setup (Initialization)**
```dart
// In voice_chat_controller.dart
_ttsPlayer = TtsPlayer(sampleRate: 24000); // Match server's output
await _ttsPlayer!.init();
```

**What happens:**
- Creates a `FlutterSoundPlayer` instance
- Opens the audio player
- Prepares for PCM16 streaming (no file I/O)

---

### **2. Starting the Stream**
```dart
// In tts_player.dart - _startStreaming()
await _player!.startPlayerFromStream(
  codec: Codec.pcm16,        // Raw PCM audio format
  numChannels: 1,            // Mono (single channel)
  sampleRate: 24000,         // 24kHz (24,000 samples per second)
  bufferSize: 16384,         // Buffer size in bytes
  interleaved: true          // Audio format
);
```

**Parameters Explained:**
- **codec: Codec.pcm16** = Raw uncompressed 16-bit PCM audio (no MP3/AAC encoding)
- **numChannels: 1** = Mono audio (single channel, not stereo)
- **sampleRate: 24000** = 24,000 samples per second (24kHz quality)
- **bufferSize: 16384** = Internal buffer size (16KB) - controls latency
- **interleaved: true** = Audio data format (only relevant for stereo)

---

### **3. Receiving Audio Data from Server**
```dart
// In voice_chat_controller.dart - _handleWebSocketMessage()
if (msg is Uint8List || msg is List<int>) {
  final audioData = msg is Uint8List 
    ? msg 
    : Uint8List.fromList(msg);
  
  print('📨 Message Type: BINARY (TTS Audio)');
  print('📏 Audio Length: ${audioData.length} bytes');
  print('🎵 Format: PCM16, 24kHz, mono');
  
  // Send to TTS player
  _ttsPlayer?.addAudioFrame(audioData);
}
```

**Data Flow:**
1. WebSocket receives **binary data** (Uint8List)
2. Data is **raw PCM16 audio bytes** from server
3. Controller passes data directly to TTS player

---

### **4. Feeding Audio to Player**
```dart
// In tts_player.dart - addAudioFrame()
Future<void> addAudioFrame(Uint8List audioData) async {
  // Start streaming if not already playing
  if (!_isPlaying) {
    await _startStreaming();
  }
  
  // Feed audio chunk directly to player
  await _player!.feedUint8FromStream(audioData);
}
```

**How it works:**
- **First frame:** Starts the stream with `startPlayerFromStream()`
- **Subsequent frames:** Feeds raw PCM16 bytes with `feedUint8FromStream()`
- **Buffering:** flutter_sound manages internal buffering automatically
- **Playback:** Audio plays immediately (low latency streaming)

---

### **5. Audio Format Details**

**PCM16 Format:**
- **16-bit** = Each audio sample is 2 bytes
- **Little Endian** = Byte order (LSB first)
- **Signed** = Values range from -32768 to +32767

**Data Size Calculation:**
```
1 second of audio = sampleRate × numChannels × 2 bytes
                  = 24000 × 1 × 2
                  = 48,000 bytes per second

20ms chunk (typical) = 48000 / 50 = 960 bytes
```

---

## 🎙️ MIC RECORDING - Sending Audio to Server

### **1. Setup**
```dart
// In voice_chat_controller.dart
_mic = MicStreamer(channel: _channel!);
await _mic!.init();
```

---

### **2. Starting Recording**
```dart
// In mic_streamer.dart
await _recorder.startRecorder(
  toStream: _frames.sink,           // Send to stream
  codec: Codec.pcm16,               // Raw PCM16 format
  numChannels: 1,                   // Mono
  sampleRate: 16000,                // 16kHz (server expects this)
  audioSource: AudioSource.voice_communication,
);
```

**Parameters:**
- **sampleRate: 16000** = 16kHz (lower than TTS playback - optimized for voice)
- **toStream** = Sends audio frames to a stream controller
- **AudioSource.voice_communication** = Optimizes for voice (noise reduction, echo cancellation)

---

### **3. Sending Mic Data to Server**
```dart
// In voice_chat_controller.dart - _startRecording()
_micSubscription = _mic!.frames.listen((frame) {
  // Send RAW PCM16 bytes to server
  _channel?.sink.add(frame);
  
  // Also check for barge-in
  if (isSpeaking.value) { // If AI is speaking
    final shouldInterrupt = _bargeInDetector!.processPcm16Frame(
      Uint8List.fromList(frame),
      isAiSpeaking: true,
    );
    if (shouldInterrupt) {
      // BARGE-IN! Stop AI playback
      await _ttsPlayer?.stop();
      _channel?.sink.add(jsonEncode({'type': 'cancel'}));
    }
  }
});
```

**Data Flow:**
1. Mic captures audio → Generates PCM16 frames
2. Each frame (typically 640 bytes = 20ms at 16kHz) is sent to:
   - **WebSocket** (to server for STT processing)
   - **Barge-in detector** (to detect user interruption)

---

## 🛑 BARGE-IN DETECTION - How Interruption Works

### **What is Barge-In?**
Barge-in = User starts speaking **while AI is still talking**
- AI should **stop talking immediately**
- System should **start listening to user**

---

### **How Barge-In Detector Works**

#### **1. Audio Analysis (processPcm16Frame)**
```dart
// In barge_in_detector.dart
bool processPcm16Frame(Uint8List pcm16le, {bool isAiSpeaking = false}) {
  // 1. Calculate RMS (Root Mean Square) = Audio volume/energy
  for (int i = 0; i < sampleCount; i++) {
    final sample = bd.getInt16(i * 2, Endian.little);
    final normalized = sample / 32768.0;
    sumSquares += normalized * normalized;
  }
  final rms = sqrt(sumSquares / sampleCount);
  
  // 2. Calculate Spectral Centroid = Frequency distribution
  //    (Human voice has specific frequency patterns)
  final spectralCentroid = sumWeightedFreq / sumMagnitude;
  
  // 3. Adaptive Threshold (higher during AI speech)
  final adaptiveThreshold = isAiSpeaking 
    ? baseThreshold * 5     // Much higher when AI is talking
    : baseThreshold;
  
  // 4. Detect human voice pattern
  final minSpectralCentroid = isAiSpeaking ? 0.35 : 0.25;
  final isLikelyHumanVoice = 
    spectralCentroid > minSpectralCentroid && 
    rms > adaptiveThreshold;
  
  // 5. Require multiple consecutive frames
  final effectiveRequiredFrames = isAiSpeaking ? 5 : 3;
  
  if (isLikelyHumanVoice) {
    _hits++;
    if (_hits >= effectiveRequiredFrames) {
      print('🎯 BARGE-IN DETECTED!');
      return true; // Interrupt!
    }
  } else {
    _hits = 0; // Reset counter
  }
  
  return false;
}
```

---

#### **2. Key Metrics**

**RMS (Root Mean Square):**
- Measures **audio volume/energy**
- Range: 0.0 (silence) to 1.0 (max volume)
- Threshold: 0.20 normally, 1.0 during AI speech (5x higher)

**Spectral Centroid:**
- Measures **frequency distribution**
- Helps distinguish human voice from noise/music
- Human voice typically: 0.25-0.45
- Threshold: 0.35 during AI speech (stricter)

**Hit Counter:**
- Requires **3-5 consecutive frames** of human voice
- Prevents false positives from short noises
- Higher requirement during AI speech (5 frames vs 3)

---

#### **3. Barge-In Flow**

```
User Speaks While AI is Talking
          ↓
Mic captures audio frame (640 bytes)
          ↓
Send to WebSocket (for STT)
          ↓
Send to BargeInDetector
          ↓
Calculate RMS & Spectral Centroid
          ↓
Compare against adaptive thresholds
          ↓
Is it human voice? → Increment hit counter
          ↓
Hit counter >= 5? → BARGE-IN!
          ↓
Stop AI audio playback (_ttsPlayer.stop())
          ↓
Send cancel signal to server
          ↓
AI stops speaking, system listens to user
```

---

## 📊 Complete Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    USER SPEAKS                              │
│                         ↓                                   │
│              [Microphone Capture]                           │
│                    16kHz PCM16                              │
│                         ↓                                   │
│              [MicStreamer.frames]                           │
│                         ↓                                   │
│          ┌──────────────┴──────────────┐                   │
│          ↓                              ↓                   │
│   [Send to Server]              [Barge-In Check]            │
│   (WebSocket binary)           (If AI speaking)             │
│          ↓                              ↓                   │
│   [Server STT]                   [Detect interrupt?]        │
│          ↓                              ↓                   │
│   [AI Response]                   [Yes → Stop AI]           │
│          ↓                                                  │
│   [Server TTS]                                              │
│          ↓                                                  │
│ [WebSocket binary audio]                                    │
│    24kHz PCM16 chunks                                       │
│          ↓                                                  │
│   [TtsPlayer.addAudioFrame()]                               │
│          ↓                                                  │
│   [_player.feedUint8FromStream()]                           │
│          ↓                                                  │
│     [Speaker Output]                                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Key Differences: Sending vs Receiving

| Aspect | **Mic Input (Send)** | **TTS Output (Receive)** |
|--------|---------------------|--------------------------|
| Sample Rate | 16kHz | 24kHz |
| Direction | Device → Server | Server → Device |
| Frame Size | ~640 bytes (20ms) | Variable |
| Buffer Size | N/A | 16384 bytes |
| Purpose | STT (Speech-to-Text) | TTS (Text-to-Speech) |
| Format | PCM16, Mono | PCM16, Mono |
| API | `startRecorder()` | `startPlayerFromStream()` |
| Feed Method | Automatic (toStream) | Manual (`feedUint8FromStream()`) |

---

## 💡 Performance Optimizations

### **Low Latency**
- **Direct streaming** (no file I/O)
- **Small buffers** (16KB) for quick response
- **Binary WebSocket** (no JSON overhead for audio)

### **Barge-In Reliability**
- **Adaptive thresholds** (higher when AI speaks)
- **Spectral analysis** (not just volume)
- **Consecutive frame check** (prevents false positives)
- **Background noise estimation** (adapts to environment)

### **Resource Management**
- **Proper cleanup** (stop → close → dispose)
- **Stream controllers** (efficient audio pipeline)
- **Error handling** (graceful degradation)

---

## 🐛 Common Issues & Solutions

### **Issue: Audio cuts off early**
**Solution:** Increase `bufferSize` in `startPlayerFromStream()`

### **Issue: Barge-in too sensitive**
**Solution:** Increase `baseThreshold` or `requiredFrames` in `BargeInDetector`

### **Issue: Audio sounds distorted**
**Solution:** Ensure `sampleRate` matches server output (24kHz)

### **Issue: Echo/feedback**
**Solution:** Use `AudioSource.voice_communication` for mic input

---

## 📝 Summary

### **Sending Audio (Mic → Server):**
1. Initialize recorder with 16kHz PCM16
2. Start recording to stream
3. Listen to frames
4. Send each frame as binary WebSocket message
5. Also check for barge-in if AI is speaking

### **Receiving Audio (Server → Speaker):**
1. Initialize TTS player with 24kHz PCM16
2. Receive binary WebSocket messages
3. Start streaming on first frame
4. Feed subsequent frames with `feedUint8FromStream()`
5. Audio plays automatically

### **Barge-In:**
1. Monitor mic frames while AI is speaking
2. Analyze RMS + spectral centroid
3. Require 5 consecutive frames of human voice
4. Stop AI playback + send cancel signal
5. User takes over conversation

---

**Created:** January 30, 2026
**Framework:** Flutter with flutter_sound
**Audio Format:** PCM16 (16-bit, mono, little-endian)
