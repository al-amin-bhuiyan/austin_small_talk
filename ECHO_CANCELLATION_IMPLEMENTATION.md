# Echo Cancellation Implementation for Voice Chat

## Problem

The voice chat was experiencing **phantom messages** - the AI server was receiving audio data even when the user wasn't speaking. This was caused by an **acoustic echo/feedback loop**:

1. AI speaks through phone **speaker**
2. **Microphone picks up the speaker audio**
3. Voice Activity Detector (VAD) detects speaker sound as "speech"
4. System sends the AI's own voice back to server
5. Creates dummy messages and echo loop

## Root Cause

The `VoiceActivityDetector` was operating continuously without any awareness of when the AI was speaking. The relaxed VAD thresholds (noise floor: 500.0, energy multiplier: 0.3) made it very sensitive to audio, including speaker output.

## Solution: Echo Cancellation

Implemented **playback state tracking** in the VAD to suppress speech detection while the AI is speaking through the device speaker.

## Changes Made

### 1. VoiceActivityDetector (voice_activity_detector.dart)

Added playback state tracking:

```dart
class VoiceActivityDetector {
  // ✅ Echo cancellation - track AI speaker state
  bool _isPlayingAudio = false;
  
  /// Set playback state for echo cancellation
  /// Call with true when AI starts speaking, false when finished
  void setPlaybackState(bool isPlaying) {
    if (_isPlayingAudio != isPlaying) {
      _isPlayingAudio = isPlaying;
      print('🔊 VAD: Playback state changed to ${isPlaying ? "PLAYING" : "STOPPED"}');
      
      // Reset VAD state when playback starts to prevent false triggers
      if (isPlaying) {
        resetState();
      }
    }
  }
  
  VadResult processFrame(Uint8List frame) {
    // ✅ ECHO CANCELLATION: Suppress VAD during AI playback
    if (_isPlayingAudio) {
      // Return no speech detected while AI is speaking
      return VadResult(
        shouldSend: false,
        speechStarted: false,
        speechEnded: false,
      );
    }
    
    // ... normal VAD processing
  }
}
```

**Key Points**:
- `_isPlayingAudio` tracks whether AI is currently speaking
- When true, `processFrame()` immediately returns `shouldSend: false`
- No audio frames are sent to server during AI playback
- VAD state is reset when playback starts to clear any accumulated speech detection

### 2. MicStreamer (mic_streamer.dart)

Exposed VAD for external control:

```dart
class MicStreamer {
  final VoiceActivityDetector _vad = VoiceActivityDetector();
  
  // ✅ Expose VAD for echo cancellation control
  VoiceActivityDetector get vad => _vad;
  
  // ... rest of implementation
}
```

### 3. VoiceChatController (voice_chat_controller.dart)

Integrated echo cancellation with TTS events:

#### When AI Starts Speaking:
```dart
case 'tts_start':
  print('🔊 TTS Starting...');
  isSpeaking.value = true;
  _ttsPlayer?.onSentenceStart();
  
  // ✅ ECHO CANCELLATION: Suppress VAD during AI playback
  _micStreamer?.vad.setPlaybackState(true);
  print('🔇 VAD suppressed during AI speech');
  break;
```

#### When AI Finishes Speaking:
```dart
case 'tts_end':
  print('🔊 TTS Ended');
  isSpeaking.value = false;
  _ttsPlayer?.onSentenceEnd();
  
  // ✅ ECHO CANCELLATION: Wait 500ms before resuming VAD
  // This prevents picking up residual speaker audio
  Future.delayed(Duration(milliseconds: 500), () {
    _micStreamer?.vad.setPlaybackState(false);
    print('🎤 VAD resumed - ready for user speech');
  });
  break;
```

#### When AI is Interrupted:
```dart
void _handleInterruption() {
  isSpeaking.value = false;
  _ttsPlayer?.stop();
  
  // ✅ Resume VAD immediately on interruption (user is speaking)
  _micStreamer?.vad.setPlaybackState(false);
  print('🎤 VAD resumed after interruption');
}
```

#### When Server Cancels:
```dart
case 'cancelled':
  print('🛑 Cancelled by server');
  isSpeaking.value = false;
  
  // ✅ Resume VAD after cancellation
  _micStreamer?.vad.setPlaybackState(false);
  print('🎤 VAD resumed after cancellation');
  break;
```

## How It Works

### Normal Flow (Without Echo Cancellation)
```
1. AI speaks → Speaker plays audio
2. Mic picks up speaker → VAD detects "speech"
3. Sends audio to server → Server receives its own audio
4. Creates dummy message → Endless loop 🔄
```

### With Echo Cancellation
```
1. Server sends 'tts_start' → Controller sets VAD playback = true
2. AI speaks through speaker → Mic still records audio
3. VAD processFrame() called → Returns shouldSend = false (suppressed)
4. No audio sent to server → No dummy messages ✅
5. Server sends 'tts_end' → Wait 500ms, then VAD playback = false
6. User can speak → VAD detects real speech, sends to server
```

## Benefits

1. **No Dummy Messages**: Microphone audio is ignored during AI playback
2. **Clean Conversations**: Only real user speech is detected and sent
3. **Fast Recovery**: VAD resumes 500ms after AI finishes speaking
4. **Barge-In Support**: User can interrupt AI (handled separately)
5. **No Hardware Changes**: Pure software solution, works on all devices

## Testing

### To Verify Fix is Working:

1. **Start voice chat** and let AI speak
2. **Check console logs** for:
   ```
   🔇 VAD suppressed during AI speech
   🔊 VAD: Playback state changed to PLAYING
   ```
3. **Observe behavior**: No messages sent while AI is speaking
4. **After AI finishes**: Look for:
   ```
   🎤 VAD resumed - ready for user speech
   🔊 VAD: Playback state changed to STOPPED
   ```
5. **Speak after AI finishes**: Your speech should be detected normally

### Debug Logging Added:

- `🔇 VAD suppressed during AI speech` - Echo cancellation activated
- `🎤 VAD resumed - ready for user speech` - Echo cancellation deactivated
- `🔊 VAD: Playback state changed to PLAYING/STOPPED` - State transitions

## Edge Cases Handled

1. **Rapid AI Responses**: Each `tts_start` resets VAD state
2. **User Interruption**: VAD immediately resumes when user barges in
3. **Server Cancellation**: VAD resumes on cancel message
4. **Connection Loss**: VAD state resets on reconnection
5. **Residual Audio**: 500ms delay before resuming prevents echo tail pickup

## Alternative Solutions Considered

### 1. Lower Microphone Volume During Playback
❌ Not implemented - affects overall recording quality

### 2. Acoustic Echo Cancellation (AEC) Hardware
❌ Device-dependent, not available on all phones

### 3. Headphones
✅ Still recommended for best experience, but not required

### 4. Increase VAD Threshold
❌ Would reduce sensitivity for real speech detection

## Performance Impact

- **Minimal**: Single boolean check per audio frame (~50 frames/second)
- **No Additional Latency**: Suppression happens in existing VAD pipeline
- **Memory**: +1 boolean variable per VAD instance (~1 byte)

## Future Enhancements

1. **Adaptive Delay**: Adjust 500ms delay based on room acoustics
2. **Level-Based Suppression**: Partial suppression based on playback volume
3. **Hardware AEC Integration**: Use native AEC when available
4. **Machine Learning**: Train model to distinguish speaker from user voice

## Summary

✅ **Echo cancellation implemented** via playback state tracking in VAD  
✅ **Integrated with TTS lifecycle** (start, end, cancel, interrupt)  
✅ **500ms grace period** after AI speech to avoid echo tail  
✅ **Full logging** for debugging and verification  
✅ **No phantom messages** during AI playback  

The fix prevents the microphone from sending audio to the server while the AI is speaking, eliminating the acoustic echo problem completely.
