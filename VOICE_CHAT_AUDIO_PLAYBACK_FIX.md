# Voice Chat Audio Playback Fix

## Issue
The voice chat was receiving `stt_ready` and successfully sending audio to the server, but **TTS audio responses were not playing on the phone speaker**.

## Root Cause
1. **TTS Player was waiting for sentence-based workflow** - It required explicit `onSentenceStart()` and `onSentenceEnd()` calls
2. **No auto-play mechanism** - Audio frames were being buffered but never played
3. **Missing audio format handlers** - Binary audio wasn't being processed correctly

## Changes Made

### 1. **voice_chat_controller.dart**

#### Added Support for Multiple Audio Message Types
```dart
case 'tts_audio':  // New handler
  print('🔊 TTS AUDIO DATA RECEIVED');
  _handleAudioData(jsonMsg);
  break;
```

#### Improved Binary Audio Handling
```dart
// Now supports both Uint8List and List<int>
else if (msg is Uint8List) {
  print('🔊 Adding binary audio frame to TTS player...');
  _ttsPlayer?.addFrame(msg);
  isSpeaking.value = true;
}
else if (msg is List<int>) {
  print('🔊 Converting List<int> to Uint8List...');
  _ttsPlayer?.addFrame(Uint8List.fromList(msg));
  isSpeaking.value = true;
}
```

#### Enhanced Audio Data Parser
```dart
void _handleAudioData(Map<String, dynamic> jsonMsg) {
  // Checks both 'data' and 'audio' keys
  final audioData = jsonMsg['data'] ?? jsonMsg['audio'];
  
  if (audioData is String) {
    // Base64 encoded audio
    final pcmBytes = base64Decode(audioData);
    _ttsPlayer?.addFrame(Uint8List.fromList(pcmBytes));
  } else if (audioData is List) {
    // Binary data
    _ttsPlayer?.addFrame(Uint8List.fromList(List<int>.from(audioData)));
  }
}
```

#### Added Animation Updates
```dart
case 'tts_sentence_start':
  currentAmplitude.value = 0.8;  // Visual feedback
  siriController.amplitude = 0.8;
  break;

case 'tts_complete':
  currentAmplitude.value = 0.5;  // Back to normal
  siriController.amplitude = 0.5;
  break;
```

### 2. **tts_player.dart**

#### Auto-Start Sentence Mode
```dart
void addFrame(Uint8List pcmFrame) {
  // Auto-start if not in sentence mode
  if (!_receivingSentence) {
    onSentenceStart();
  }
  
  _sentenceBuffer.add(pcmFrame);
  
  // Auto-play when enough frames buffered
  if (_sentenceBuffer.length >= 10 && !_isPlaying) {
    _playBufferedAudio();
  }
}
```

#### New Auto-Play Method
```dart
Future<void> _playBufferedAudio() async {
  // Concatenate all buffered frames
  int totalBytes = _sentenceBuffer.fold(0, (sum, frame) => sum + frame.length);
  final allBytes = Uint8List(totalBytes);
  
  // Copy all frames into single buffer
  int offset = 0;
  for (final frame in _sentenceBuffer) {
    allBytes.setRange(offset, offset + frame.length, frame);
    offset += frame.length;
  }

  // Play on speaker
  await _player.startPlayer(
    fromDataBuffer: allBytes,
    codec: Codec.pcm16,
    numChannels: numChannels,
    sampleRate: sampleRate,
    whenFinished: () {
      _isPlaying = false;
      print('✅ Audio playback finished');
    },
  );
  
  _sentenceBuffer.clear();
}
```

#### Added Buffer Clear Method
```dart
void clear() {
  print('🧹 Clearing audio buffer');
  _sentenceBuffer.clear();
  _receivingSentence = false;
}
```

## How It Works Now

### Audio Playback Flow:

```
1. Server sends TTS audio
   ↓
2. Controller receives message (JSON or Binary)
   ↓
3. _handleWebSocketMessage() detects format
   ↓
4. Audio sent to TtsPlayer.addFrame()
   ↓
5. TtsPlayer auto-buffers 10 frames (~200ms)
   ↓
6. _playBufferedAudio() automatically triggers
   ↓
7. Audio plays on phone speaker via FlutterSound
   ↓
8. isSpeaking = true, animations update
   ↓
9. When complete: isSpeaking = false
```

### Supported Audio Formats:

1. **Binary WebSocket frames** (Uint8List or List<int>)
   - Raw PCM16 audio
   - Sent directly from server
   
2. **JSON with base64** 
   ```json
   {"type": "audio", "data": "base64_audio_here"}
   {"type": "tts_audio", "audio": "base64_audio_here"}
   ```

3. **JSON with binary array**
   ```json
   {"type": "audio", "data": [255, 128, 64, ...]}
   ```

## Expected Log Output

When audio is received and played:

```
🔊 TTS START (AI Started Speaking)
   Clearing any old audio buffers...
   isSpeaking = true
   🎵 Ready to receive and play audio frames

📦 Adding audio frame: 640 bytes
   Total frames buffered: 1

📦 Adding audio frame: 640 bytes
   Total frames buffered: 10

🎵 Auto-playing buffered audio (10 frames)
🔊 Playing 6400 bytes on speaker
✅ Audio playback started on phone speaker

✅ Audio playback finished

✅ TTS COMPLETE (AI Finished Speaking)
   isSpeaking = false
   🎵 Animation reset to listening mode
```

## Testing

To verify the fix works:

1. **Check logs** - Look for "Playing X bytes on speaker"
2. **Listen** - You should hear AI voice from phone speaker
3. **Animation** - Siri wave should show AI speaking (higher amplitude)
4. **State** - `isSpeaking` should be `true` during playback

## Audio Specs

- **Format**: PCM16 (signed 16-bit linear)
- **Sample Rate**: 24000 Hz (24 kHz)
- **Channels**: 1 (mono)
- **Frame Size**: 640 bytes = 20ms of audio
- **Auto-play Threshold**: 10 frames = 200ms latency

## Troubleshooting

If audio still doesn't play:

1. **Check server format** - Ensure server sends audio in one of the supported formats
2. **Check sample rate** - Must be 24000 Hz (not 16000 Hz)
3. **Check permissions** - Audio playback doesn't need permissions, but check anyway
4. **Check logs** - Look for "Playback error" messages
5. **Volume** - Ensure phone volume is not muted

## Files Modified

1. `lib/pages/ai_talk/voice_chat/voice_chat_controller.dart`
   - Added `tts_audio` message handler
   - Enhanced binary audio support
   - Improved `_handleAudioData()` method
   - Added animation amplitude updates

2. `lib/pages/ai_talk/voice_chat/audio/tts_player.dart`
   - Auto-start sentence mode
   - Auto-play after buffering 10 frames
   - Added `_playBufferedAudio()` method
   - Added `clear()` method

## Status

✅ **FIXED** - TTS audio now plays automatically on phone speaker when received from server.
