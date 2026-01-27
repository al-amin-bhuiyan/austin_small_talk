# Voice Chat Quick Reference Guide

## 🎯 Quick Summary

### When Does What Happen?

| Event | WebSocket | Mic | Action |
|-------|-----------|-----|--------|
| **Page Opens** | ✅ Connects | 🔴 OFF | Automatic |
| **Press Mic (1st time)** | ✅ Connected | 🟢 ON | User action |
| **Press Mic (2nd time)** | ✅ Connected | 🔴 OFF | User action |
| **Page Closes** | ❌ Disconnects | 🔴 OFF | Automatic |

---

## 🔄 User Flow

```
1. User opens voice_chat.dart page
   ↓
   WebSocket: CONNECTING... → CONNECTED ✅
   Mic: OFF 🔴
   Status: "Ready - Press mic to talk"

2. User presses mic button
   ↓
   Mic: OFF 🔴 → ON 🟢
   Action: Audio starts streaming
   UI: Pulsing animation

3. User speaks
   ↓
   Mic: ON 🟢
   Audio: Streaming to server
   Feedback: Real-time audio levels

4. User presses mic button again
   ↓
   Mic: ON 🟢 → OFF 🔴
   Action: Audio stops streaming
   UI: Static icon

5. User closes page
   ↓
   Mic: Stops (if on)
   WebSocket: Disconnects
   Status: Cleaned up
```

---

## 🐛 Debugging Guide

### Issue: "WebSocket not connecting"
**Check:**
- Is the page actually visible/active?
- Look for `onReady()` logs in console
- Check network connectivity
- Verify server is running

### Issue: "Mic won't turn on"
**Check:**
- Is WebSocket connected? (green status indicator)
- Microphone permissions granted?
- Look for `_startMicrophone()` logs
- Check for error messages

### Issue: "Mic stays on when leaving page"
**Check:**
- Should be fixed now! ✅
- Look for `onClose()` and `_cleanup()` logs
- Verify mic turns red when page closes

### Issue: "Resources not releasing"
**Check:**
- Look for cleanup logs when page closes
- All 7 cleanup steps should complete
- States should reset to false

---

## 📋 Console Log Guide

### Good Flow (Page Opens):
```
🚀 VoiceChatController.onInit() - Controller Initializing
✅ onInit() complete - Animation started
🎯 VoiceChatController.onReady() - Page Appeared
🎬 INITIALIZING VOICE CHAT (PAGE APPEARED)
📦 Step 1/4: Configuring Audio Session
   ✅ Audio session configured
📦 Step 2/4: Creating TTS Player
   ✅ TTS Player created (16kHz, mono)
📦 Step 3/4: Creating Barge-in Detector
   ✅ Barge-in detector created
📦 Step 4/4: Connecting to WebSocket Server
✅ WEBSOCKET CONNECTED - READY FOR VOICE CHAT ✅
```

### Good Flow (Mic Button Pressed):
```
🎤 MICROPHONE BUTTON PRESSED
📊 Current Mic State: 🔴 OFF
🎯 Action: Turn ON
STARTING MICROPHONE
✅ WebSocket is connected
📤 Sending stt_start
✅ stt_start sent to server
🎙️ Creating MicStreamer
✅ MicStreamer initialized
✅ Audio capture started
MICROPHONE STARTED SUCCESSFULLY
🎤 Status: ACTIVE (Streaming)
```

### Good Flow (Page Closes):
```
VOICE CHAT PAGE CLOSING - CLEANUP STARTING
🧹 CLEANUP: PAGE CLOSING - DISCONNECTING ALL 🧹
🧹 Step 1/7: Stopping microphone (if active)...
   ✅ Microphone stopped and cleaned
🧹 Step 2/7: Cancelling WebSocket subscription...
   ✅ WebSocket listener stopped
...
🧹 Step 7/7: Closing WebSocket connection...
   ✅ WebSocket disconnected
🔄 Resetting all state variables...
   ✅ All states reset to initial values
✅ CLEANUP COMPLETE - PAGE CLOSED SUCCESSFULLY ✅
```

---

## ⚡ Performance Tips

1. **Don't keep page open unnecessarily** - WebSocket uses network/battery
2. **Turn off mic when not speaking** - Saves processing power
3. **Navigate away cleanly** - Use back button, not force-close
4. **Check permissions** - Grant mic access before opening page

---

## 🔐 Security Notes

- ✅ WebSocket uses authentication token
- ✅ Token sent in URL query parameter
- ✅ Audio data encrypted in transit (if HTTPS/WSS)
- ✅ No audio stored locally after page closes

---

## 📱 UI States

### Connection Status Indicator:
- 🔴 "Connecting..." - WebSocket connecting
- 🟢 "Connected" - Ready to use
- 🔴 "Disconnected" - Connection lost

### Microphone Button:
- 🔴 Red/Gray - Mic OFF, click to start
- 🟢 Green/Pulsing - Mic ON, click to stop
- ⚪ Disabled - WebSocket not connected

### Speaking Indicator:
- 🌊 Animated wave - AI is speaking
- ⚪ Flat line - Listening/Idle

---

*Quick Reference - Version 1.0 - January 26, 2026*
