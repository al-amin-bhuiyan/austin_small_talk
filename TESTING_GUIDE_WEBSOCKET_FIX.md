# 🧪 Testing Guide - WebSocket Fix Verification

## ✅ Critical Fix Applied

**Problem:** Two separate WebSocket connections - TTS never reached Flutter  
**Solution:** Single WebSocket connection for all communication  
**Expected Result:** TTS audio now plays on phone speaker

---

## 🔍 How to Test

### Step 1: Start the App
```
Run the app on your device or emulator
```

### Step 2: Navigate to Voice Chat
```
1. Go to AI Talk screen
2. Press the microphone button
```

### Step 3: Watch the Logs

You should see this sequence:

#### ✅ **Connection Established:**
```
╔═══════════════════════════════════════════════════════════╗
║          STEP 1: SENDING stt_start                       ║
╚═══════════════════════════════════════════════════════════╝
📤 Sending stt_start message...
✅ stt_start sent to server
```

#### ✅ **Server Responds:**
```
╔═══════════════════════════════════════════════════════════╗
║       STEP 2: WAITING FOR stt_ready...                   ║
╚═══════════════════════════════════════════════════════════╝
📥 stt_ready RECEIVED!
```

#### ✅ **Critical Check - Same WebSocket Used:**
```
╔═══════════════════════════════════════════════════════════╗
║       STEP 3: STARTING AUDIO CAPTURE                     ║
╚═══════════════════════════════════════════════════════════╝
✅ Reusing existing WebSocket channel (SAME as stt_start)
   WebSocket hash: 123456789  ← This should be a number
   This ensures TTS responses come back on same connection!
🎙️  Creating MicStreamer with SAME WebSocket
```

**❌ If you see:** `📡 Creating WebSocket channel for audio streaming` - **FIX NOT APPLIED!**  
**✅ If you see:** `✅ Reusing existing WebSocket channel` - **FIX WORKING!**

#### ✅ **Audio Streaming:**
```
🎙️  Frame #1 received (640 bytes)
🎙️  Frame #2 received (640 bytes)
📤 Sent 0.6 KB to server (frame #10)
```

### Step 4: Speak to the AI

Say something like "Hello, how are you?"

#### ✅ **User Speech Detected:**
```
🎤 STT PARTIAL: "hello"
🎤 STT PARTIAL: "hello how"
🎤 STT FINAL: "hello how are you"
```

### Step 5: **CRITICAL TEST** - TTS Audio Arrives

Look for these logs (THIS IS THE KEY!):

```
🔊 AUDIO DATA RECEIVED (JSON format)  ← ✅ SUCCESS!
   Message keys: [type, data]
   Data length: 12800 chars (base64)
   ✅ Audio decoded and added to TTS player

🔊 Playing 6400 bytes on speaker
✅ Audio playback started on phone speaker
```

**If you see `🔊 AUDIO DATA RECEIVED`** → **FIX WORKS! 🎉**

**If you DON'T see this** → TTS still not arriving (check server logs)

### Step 6: Listen!

**You should HEAR the AI voice from your phone speaker!** 🔊

---

## ❌ Troubleshooting

### Problem: Don't see "Reusing existing WebSocket"

**Cause:** Old code still in place  
**Solution:**
1. Clean build: `flutter clean`
2. Rebuild: `flutter pub get`
3. Hot restart (not hot reload!)

### Problem: See "WebSocket channel is null!"

**Cause:** WebSocket not connected before mic starts  
**Solution:** Check network connection and server availability

### Problem: See TTS audio but don't hear sound

**Possible causes:**
1. Phone volume muted → Check media volume
2. Wrong sample rate → Should be 24000 Hz
3. Audio player issue → Check TtsPlayer logs

### Problem: Server sends audio but as binary (Uint8List)

**Expected logs:**
```
📨 Message Type: BINARY (Audio Data)
📏 Binary Length: 640 bytes
🔊 Adding binary audio frame to TTS player...
```

This also works! The audio handler supports both formats.

---

## 📊 Success Criteria

✅ All of these must be true:

| Check | Status |
|-------|--------|
| `stt_ready` received | ✅ |
| "Reusing existing WebSocket" logged | ✅ |
| Audio frames streaming | ✅ |
| `STT FINAL` shows user speech | ✅ |
| **`AUDIO DATA RECEIVED` logged** | ✅ ← **KEY** |
| `Playing X bytes on speaker` logged | ✅ |
| **Hear AI voice from speaker** | ✅ ← **KEY** |

---

## 🔬 Advanced Debugging

### Check WebSocket Hash

The logs show WebSocket hash codes. They should be **THE SAME**:

```
Connection established:
   WebSocket created: hash 123456789

Microphone started:
   WebSocket hash: 123456789  ← Should match!
```

If hashes are different → Still creating new connection (fix not applied)

### Monitor Network Traffic

Use Charles Proxy or similar to verify:
- Only ONE WebSocket connection exists
- Both JSON and binary data flow on same connection

### Server-Side Logs

Ask server team to confirm:
- Session bound to WebSocket correctly
- TTS responses sent to correct connection
- No "session not found" errors

---

## 🎯 Expected Timeline

```
T+0s:     Press mic button
T+0.1s:   stt_start sent
T+0.2s:   stt_ready received
T+0.3s:   Audio streaming starts
T+1s:     User speaks
T+2s:     STT FINAL received
T+2.5s:   Server processing (LLM)
T+3s:     🔊 AUDIO DATA RECEIVED ← AI response!
T+3.1s:   TTS playing on speaker
T+5s:     TTS playback complete
```

---

## 📝 What to Report

### If It Works ✅

Report these logs:
```
✅ Reusing existing WebSocket channel (SAME as stt_start)
🔊 AUDIO DATA RECEIVED
✅ Audio playback started on phone speaker
```

And confirm:
- "I can hear the AI voice!"

### If It Doesn't Work ❌

Report:
1. Full logs from mic button press to timeout
2. Whether you see "Reusing existing WebSocket" or not
3. Whether you see "AUDIO DATA RECEIVED" or not
4. Server logs (if available)

---

## 🚀 Next Steps After Successful Test

Once TTS is working:

1. Test barge-in (interrupt AI while speaking)
2. Test multiple conversations
3. Test different scenarios
4. Test error recovery (disconnect/reconnect)

---

## 📚 Related Documentation

- `WEBSOCKET_CONNECTION_FIX.md` - Detailed technical explanation
- `VOICE_CHAT_AUDIO_PLAYBACK_FIX.md` - Audio player implementation

---

**Remember:** The key indicator is **`🔊 AUDIO DATA RECEIVED`** in the logs. If you see this, the fix is working!
