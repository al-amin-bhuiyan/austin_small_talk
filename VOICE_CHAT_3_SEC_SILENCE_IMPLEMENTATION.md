# Voice Chat 3-Second Silence Detection Implementation

## Overview
Implemented continuous voice chat with automatic 3-second silence detection that triggers AI response.

## Key Features

### 1. **Microphone Always On**
- Microphone starts automatically when voice_chat screen appears
- Continuous audio streaming to server
- WaveBlob and SiriWave animations always active

### 2. **3-Second Silence Detection**
- When user speaks, a 3-second timer starts
- Each new speech resets the timer
- After 3 seconds of silence, AI processes and responds
- Microphone stays on during AI response

### 3. **Interruption Handling**
- If user speaks while AI is talking:
  - AI immediately stops speaking
  - Audio playback clears all buffers
  - `cancel` signal sent to server
  - User input takes priority

### 4. **Server expects interruption event**
```dart
case 'interrupted':
  print('🛑 Server sent interruption event');
  onInterrupted?.call();
  break;
```

## Flow Diagram

```
Screen Appears → Connect WebSocket → Start Microphone (Always On)
                                              ↓
                                    User Speaks (Partial)
                                              ↓
                            ┌─────── Is AI Speaking? ──────┐
                            ↓ YES                          ↓ NO
                    Interrupt AI                    Reset Timer (3s)
                    Clear Buffers                          ↓
                    Send 'cancel'              User Still Speaking?
                            ↓                              ↓
                    ←──────────────────────────────────────┘
                                              ↓
                            3 Seconds of Silence Detected
                                              ↓
                            Send 'audio_end' to Server
                                              ↓
                            AI Processes & Responds
                                              ↓
                            TTS Audio Playback
                                              ↓
                            Ready for User Input
                            (Mic Still On)
```

## Implementation Details

### Controller Changes (`voice_chat_controller.dart`)

#### New Variables:
```dart
Timer? _silenceTimer;           // 3-second countdown timer
DateTime? _lastSpeechTime;      // Track when user last spoke
String _pendingText = '';       // Store text until silence detected
```

#### Key Methods:

**`_resetSilenceTimer()`**
- Cancels previous timer
- Starts new 3-second countdown
- Called on every `onSttPartial` event

**`_onSilenceDetected()`**
- Triggered after 3 seconds of silence
- Sends user message to chat
- Calls `sendAudioEnd()` to trigger AI response
- Clears pending text

**`_interruptAiSpeaking()`**
- Stops AI playback immediately
- Clears audio buffers
- Sends `cancel` signal to server
- Clears pending text

**`_handleInterruption()`**
- Handles server's `interrupted` event
- Clears all buffers
- Resets amplitude
- Ready for new input

### Service Changes (`voice_chat_service.dart`)

#### New Method:
```dart
void sendAudioEnd() {
  if (_channel != null) {
    print('📤 Sending audio_end signal (mic still on)');
    _channel!.sink.add(jsonEncode({'type': 'audio_end'}));
  }
}
```

This sends the trigger signal without stopping the microphone.

### UI Changes (`voice_chat.dart`)

- Removed pause/push button
- WaveBlob always visible and animated
- SiriWave always active
- Status indicator shows:
  - "Connecting..." when initializing
  - "Listening..." when mic is on
  - "You: [text]" when user speaking
  - "Processing..." when waiting for AI
  - "AI Speaking..." during playback
- Stop button (X) to close and cleanup

## WebSocket Message Flow

### User Speaks:
```json
// Continuous audio chunks (binary)
// Server responds:
{
  "type": "stt_partial",
  "text": "hello how are"
}
{
  "type": "stt_partial", 
  "text": "hello how are you"
}
```

### After 3 Seconds Silence:
```json
// Client sends:
{
  "type": "audio_end"
}

// Server responds:
{
  "type": "stt_final",
  "text": "hello how are you"
}
{
  "type": "ai_reply_text",
  "text": "I'm doing great! How about you?"
}
{
  "type": "tts_start"
}
// Binary audio chunks...
{
  "type": "tts_sentence_end"
}
{
  "type": "tts_complete"
}
```

### User Interrupts AI:
```json
// Client sends:
{
  "type": "cancel"
}

// Server responds:
{
  "type": "interrupted"
}
```

## Testing Checklist

- ✅ Microphone starts automatically on screen load
- ✅ WaveBlob and SiriWave always animated
- ✅ User speech shows in status
- ✅ 3-second silence triggers AI response
- ✅ Speaking during silence resets timer
- ✅ Speaking during AI playback interrupts AI
- ✅ Microphone stays on after AI finishes
- ✅ Stop button properly cleans up
- ✅ Back navigation stops everything
- ✅ Multiple turns work continuously

## Troubleshooting

### Timer not triggering:
- Check `onSttPartial` is being called
- Verify `_resetSilenceTimer()` is called
- Check for 3-second wait

### AI doesn't respond:
- Verify `sendAudioEnd()` is called
- Check WebSocket connection
- Check server logs for `audio_end` received

### Interruption not working:
- Check `isSpeaking.value` is true
- Verify `cancel` message sent
- Check audio player `stop()` called

### Mic not starting:
- Check permissions granted
- Verify `_startContinuousListening()` called
- Check WebSocket connected

## Performance Notes

- Audio streaming is continuous (bandwidth intensive)
- Timer overhead is minimal (1 Timer per session)
- Audio buffers cleared on interrupt (memory efficient)
- No audio recording to disk (RAM only)

## Future Enhancements

1. **Configurable silence duration** (2s, 3s, 5s options)
2. **Voice activity detection** (detect speech vs silence locally)
3. **Echo cancellation** (prevent AI audio from triggering mic)
4. **Background noise filtering**
5. **Offline mode** (local STT/TTS fallback)
