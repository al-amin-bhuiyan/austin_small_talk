# TTS Player Connection Drop Fix

**Date:** January 27, 2026  
**Issue:** Phone/emulator loses connection when AI speaks  
**Status:** ✅ FIXED

---

## Problem Analysis

### **Symptom:**
When AI starts speaking (TTS playback), the phone/emulator connection drops or audio stops working.

### **Root Cause:**
**Duplicate audio session configuration** causing conflicts:

1. ❌ `tts_player.dart` was configuring audio session in `init()`
2. ❌ `audio_session_config.dart` already configured audio session globally
3. ❌ **Two conflicting configurations** → Audio session reconfiguration during playback
4. ❌ Result: Connection drops, audio routing failure

---

## Solution Implemented ✅

### **Removed Duplicate Configuration**

**Before (❌ Broken):**
```dart
// In tts_player.dart init()
Future<void> init() async {
  // ❌ Duplicate configuration!
  final session = await AudioSession.instance;
  await session.configure(
    AudioSessionConfiguration(
      avAudioSessionMode: AVAudioSessionMode.voiceChat,
      // ... more config
    ),
  );
  
  _player = FlutterSoundPlayer();
  await _player!.openPlayer();
}
```

**After (✅ Fixed):**
```dart
// In tts_player.dart init()
Future<void> init() async {
  print('🎵 Initializing TTS Player...');
  
  // ✅ No audio session configuration here!
  // Uses existing global configuration from AudioSessionConfigHelper
  
  _player = FlutterSoundPlayer();
  await _player!.openPlayer(); // Uses existing session
  
  await _player!.startPlayerFromStream(
    codec: Codec.pcm16,
    numChannels: numChannels,
    sampleRate: sampleRate,
    bufferSize: 8192,
    interleaved: true,
  );
  
  print('✅ Player opened (using global audio session config)');
}
```

---

## Architecture Flow

### **Correct Configuration Order:**

```
1. voice_chat_controller.dart
   └─→ AudioSessionConfigHelper.configureForVoiceChat()
       ✅ Configures ONCE globally with:
          - AVAudioSessionMode.voiceChat (iOS echo cancellation)
          - AndroidAudioUsage.voiceCommunication (Android AEC)
       
2. mic_streamer.dart
   └─→ FlutterSoundRecorder.openRecorder()
       ✅ Uses existing session configuration

3. tts_player.dart
   └─→ FlutterSoundPlayer.openPlayer()
       ✅ Uses existing session configuration (NO reconfiguration!)
```

---

## Why This Fixes the Connection Drop

| Issue | Before | After |
|-------|--------|-------|
| **Audio Session Config** | ❌ Configured twice (conflict) | ✅ Configured once (shared) |
| **Connection Stability** | ❌ Drops when TTS starts | ✅ Stable throughout |
| **Echo Cancellation** | ⚠️ Interrupted by reconfig | ✅ Continuous |
| **Audio Routing** | ❌ Confused by dual config | ✅ Consistent |

---

## Key Changes

### **1. Removed Import**
```dart
// ❌ REMOVED
import 'package:audio_session/audio_session.dart';
```

### **2. Simplified Init**
```dart
// ✅ No session.configure() call
// ✅ Just open player with existing config
await _player!.openPlayer();
```

### **3. Updated Comments**
```dart
/// Initialize the audio player
/// Note: Does NOT configure audio session - that's done globally
```

---

## Echo Cancellation Still Enabled ✅

Even though we removed the duplicate config, **echo cancellation is still active** via the global configuration:

### **In `audio_session_config.dart`:**
```dart
// ✅ iOS Echo Cancellation
avAudioSessionMode: AVAudioSessionMode.voiceChat

// ✅ Android Echo Cancellation  
androidAudioAttributes: const AndroidAudioAttributes(
  usage: AndroidAudioUsage.voiceCommunication, // AEC enabled
)
```

This is configured **ONCE** at app startup and used by **BOTH** mic and speaker.

---

## Benefits of This Fix

### **1. Stable Connection** ✅
- No more connection drops when AI speaks
- Audio session remains stable throughout conversation

### **2. Consistent Audio Routing** ✅
- Speaker/mic routing doesn't change mid-conversation
- Bluetooth devices stay connected

### **3. Better Echo Cancellation** ✅
- Single consistent AEC configuration
- No interruption when switching between mic/speaker

### **4. Simpler Code** ✅
- Single source of truth for audio config
- No duplicate configuration logic

---

## Testing Results

| Scenario | Before | After |
|----------|--------|-------|
| **Start AI speech** | ❌ Connection drops | ✅ Stable |
| **AI speaking** | ❌ Audio cuts out | ✅ Smooth playback |
| **Switch mic/speaker** | ❌ Routing fails | ✅ Works correctly |
| **Echo cancellation** | ⚠️ Interrupted | ✅ Continuous |
| **Bluetooth audio** | ❌ Disconnects | ✅ Stays connected |

---

## File Modified

**Total:** 1 file

✅ `lib/pages/ai_talk/voice_chat/audio/tts_player.dart`
- Removed duplicate audio session configuration
- Removed `audio_session` import
- Updated comments to clarify global config usage
- Simplified `init()` method

---

## Related Files (Not Modified)

These files work together to provide the complete audio solution:

1. **`audio_session_config.dart`** - Global audio session configuration (with echo cancellation)
2. **`mic_streamer.dart`** - Uses global config
3. **`voice_chat_controller.dart`** - Initializes global config once at startup

---

## Debug Output

### **Successful Init:**
```
🎵 Initializing TTS Player...
   ✅ Player opened (using global audio session config)
✅ TTS Player initialized with flutter_sound (24000Hz)
   ✅ Direct PCM16 streaming (no WAV conversion)
   ✅ Buffer size: 8192 bytes
   ✅ Low-latency playback mode
```

### **During Playback:**
```
🔊 Streaming frame 10... (640 bytes)
🔊 Streaming frame 20... (640 bytes)
🔊 Streaming frame 30... (640 bytes)
```

No connection drops! ✅

---

## Technical Explanation

### **Why Duplicate Config Caused Drops:**

1. **Audio session reconfiguration is expensive**
   - OS must tear down existing audio routes
   - Reconnect all audio devices
   - Reinitialize echo cancellation

2. **During reconfiguration:**
   - Active audio streams are interrupted
   - Bluetooth/speaker connections may drop
   - Echo cancellation resets

3. **With dual configuration:**
   - Config #1: At app start (global)
   - Config #2: When TTS init (duplicate) ❌
   - Result: Audio system gets confused

4. **With single configuration:**
   - Config: At app start (global) only
   - Mic opens: Uses existing config ✅
   - TTS opens: Uses existing config ✅
   - Result: No interruption!

---

## Best Practice

✅ **Configure audio session ONCE at app startup**  
❌ **Don't reconfigure during runtime** (unless absolutely necessary)

```dart
// ✅ CORRECT: Configure once globally
void _initializeVoiceChat() async {
  await AudioSessionConfigHelper.configureForVoiceChat();
  _micStreamer = MicStreamer(); // Uses global config
  _ttsPlayer = TtsPlayer();     // Uses global config
}

// ❌ WRONG: Configure in each component
class TtsPlayer {
  Future<void> init() async {
    await session.configure(...); // ❌ Don't do this!
  }
}
```

---

## Status: ✅ FIXED

**Issue resolved!** Phone/emulator no longer loses connection when AI speaks.

**Root cause:** Duplicate audio session configuration  
**Solution:** Use shared global configuration  
**Result:** Stable audio throughout conversation with echo cancellation active

---

**Implementation Date:** January 27, 2026  
**Status:** Production Ready ✅  
**Quality:** Stable Connection ✅
