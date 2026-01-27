# WebSocket Integration Guide
## How VoiceChatController connects to ConversationController

---

## 📊 Architecture Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                         UI LAYER                                  │
│  (voice_chat.dart - User clicks mic button)                      │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│                   VOICE CHAT CONTROLLER                          │
│  (voice_chat_controller.dart)                                    │
│                                                                   │
│  • Manages UI state (isListening, isSpeaking, etc.)              │
│  • Handles user interactions                                     │
│  • Creates and manages ConversationController instance           │
│  • Bridges UI ↔ WebSocket logic                                  │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│                 CONVERSATION CONTROLLER                          │
│  (conversation_controller.dart)                                   │
│                                                                   │
│  • Orchestrates WebSocket conversation flow                      │
│  • Manages state machine (idle → connecting → listening → etc.)  │
│  • Coordinates: VoiceWsClient, MicStreamer, TtsPlayer            │
│  • Handles barge-in detection                                    │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│                     LOW-LEVEL COMPONENTS                         │
│                                                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │ VoiceWsClient   │  │  MicStreamer    │  │   TtsPlayer     │  │
│  │                 │  │                 │  │                 │  │
│  │ • WebSocket     │  │ • Mic capture   │  │ • Audio play    │  │
│  │ • Send/Receive  │  │ • PCM16 frames  │  │ • PCM16 decode  │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│                                                                   │
│  ┌─────────────────┐                                             │
│  │BargeInDetector  │                                             │
│  │                 │                                             │
│  │ • RMS analysis  │                                             │
│  │ • Interrupt det │                                             │
│  └─────────────────┘                                             │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🔗 Connection Flow: toggleListening() → startSession()

### **STEP-BY-STEP INTEGRATION:**

```dart
// ============================================================================
// STEP 1: User clicks mic button in UI
// ============================================================================
// File: voice_chat.dart
GestureDetector(
  onTap: () => controller.toggleListening(),
  child: MicIcon(),
)

// ============================================================================
// STEP 2: VoiceChatController.toggleListening() is called
// ============================================================================
// File: voice_chat_controller.dart
Future<void> toggleListening() async {
  if (isListening.value) {
    // Stop WebSocket conversation
    await stopListening();
  } else {
    // Start WebSocket conversation
    await startListening();
  }
}

// ============================================================================
// STEP 3: VoiceChatController.startListening() creates ConversationController
// ============================================================================
Future<void> startListening() async {
  if (!isListening.value) {
    isListening.value = true;
    _startAnimation();

    // Create ConversationController instance with all components
    _conversationController = ConversationController(
      ws: VoiceWsClient(),
      mic: MicStreamer(
        sampleRate: 16000,
        numChannels: 1,
        frameMs: 20,
      ),
      player: TtsPlayer(
        sampleRate: 24000,
        numChannels: 1,
      ),
      bargeIn: BargeInDetector(
        threshold: 0.02,
        requiredFrames: 3,
      ),
    );

    // ========================================================================
    // STEP 4: Call ConversationController.startSession() - THE BRIDGE!
    // ========================================================================
    try {
      await _conversationController!.startSession(
        wsUri: Uri.parse('wss://your-server.com/voice'),
        scenario: scenarioData?.scenarioTitle ?? 'General Conversation',
      );
      
      // Start listening to conversation state changes
      _listenToConversationState();
      
    } catch (e) {
      print('Error starting conversation: $e');
      isListening.value = false;
      _stopAnimation();
    }
  }
}

// ============================================================================
// STEP 5: Listen to ConversationController state changes
// ============================================================================
void _listenToConversationState() {
  // Poll or use a stream to monitor state
  Timer.periodic(Duration(milliseconds: 100), (timer) {
    if (_conversationController == null) {
      timer.cancel();
      return;
    }

    final state = _conversationController!.state;
    
    switch (state) {
      case VoiceState.idle:
        isListening.value = false;
        isSpeaking.value = false;
        break;
        
      case VoiceState.connecting:
        isListening.value = true;
        isSpeaking.value = false;
        break;
        
      case VoiceState.listening:
        isListening.value = true;
        isSpeaking.value = false;
        break;
        
      case VoiceState.aiSpeaking:
        isListening.value = true;
        isSpeaking.value = true;
        break;
    }
  });
}

// ============================================================================
// STEP 6: Stop conversation when user clicks mic again
// ============================================================================
Future<void> stopListening() async {
  if (isListening.value) {
    await _conversationController?.stopSession();
    _conversationController = null;
    
    isListening.value = false;
    isSpeaking.value = false;
    _stopAnimation();
  }
}
```

---

## 🎯 Complete Data Flow

```
USER CLICKS MIC BUTTON
         │
         ├─→ UI: voice_chat.dart
         │   └─→ onTap: controller.toggleListening()
         │
         ├─→ VoiceChatController.toggleListening()
         │   └─→ Checks: isListening.value?
         │       │
         │       ├─→ FALSE: Start new conversation
         │       │   └─→ VoiceChatController.startListening()
         │       │       │
         │       │       ├─→ Set isListening.value = true
         │       │       ├─→ Start UI animation
         │       │       ├─→ Create ConversationController instance
         │       │       │   • new VoiceWsClient()
         │       │       │   • new MicStreamer(16kHz, PCM16)
         │       │       │   • new TtsPlayer(24kHz, PCM16)
         │       │       │   • new BargeInDetector()
         │       │       │
         │       │       └─→ ⭐ ConversationController.startSession()
         │       │           │
         │       │           ├─→ state = VoiceState.connecting
         │       │           │
         │       │           ├─→ VoiceWsClient.connect(wsUri)
         │       │           │   └─→ Opens WebSocket to server
         │       │           │
         │       │           ├─→ TtsPlayer.init() & start()
         │       │           │   └─→ Ready to play AI audio
         │       │           │
         │       │           ├─→ Send session config (JSON)
         │       │           │   {type: "start_session", in_sr: 16000, ...}
         │       │           │
         │       │           ├─→ Send scenario config (JSON)
         │       │           │   {type: "set_scenario", scenario: "..."}
         │       │           │
         │       │           ├─→ Start WebSocket listener
         │       │           │   ws.stream.listen((msg) {
         │       │           │     • Handle JSON messages (state, transcript, etc.)
         │       │           │     • Handle binary audio (play via TtsPlayer)
         │       │           │   })
         │       │           │
         │       │           ├─→ MicStreamer.init() & start()
         │       │           │   └─→ Start recording microphone
         │       │           │
         │       │           ├─→ Start mic frame listener
         │       │           │   mic.frames.listen((frame) {
         │       │           │     • Send frame to server via WebSocket
         │       │           │     • Check for barge-in if AI speaking
         │       │           │   })
         │       │           │
         │       │           └─→ state = VoiceState.listening
         │       │
         │       └─→ TRUE: Stop conversation
         │           └─→ VoiceChatController.stopListening()
         │               └─→ ConversationController.stopSession()
         │                   ├─→ Cancel mic subscription
         │                   ├─→ Cancel WebSocket subscription
         │                   ├─→ Stop microphone
         │                   ├─→ Stop audio player
         │                   ├─→ Close WebSocket
         │                   └─→ state = VoiceState.idle
         │
         └─→ UI updates based on isListening/isSpeaking observable values
```

---

## 🔧 Implementation Checklist

### **Phase 1: Update VoiceChatController**
- [x] Add `ConversationController?` instance variable
- [x] Import required classes (VoiceWsClient, MicStreamer, TtsPlayer, etc.)
- [x] Modify `startListening()` to create ConversationController
- [x] Call `conversationController.startSession()`
- [x] Add state synchronization logic
- [x] Modify `stopListening()` to call `conversationController.stopSession()`

### **Phase 2: Configure WebSocket Server**
- [ ] Set up WebSocket server URL (e.g., wss://your-server.com/voice)
- [ ] Implement server-side STT (Speech-to-Text)
- [ ] Implement server-side AI conversation logic
- [ ] Implement server-side TTS (Text-to-Speech)
- [ ] Test JSON message formats
- [ ] Test binary audio streaming

### **Phase 3: Testing**
- [ ] Test WebSocket connection
- [ ] Test microphone audio upload
- [ ] Test server audio playback
- [ ] Test barge-in detection
- [ ] Test error handling
- [ ] Test session termination

---

## 📝 Key Implementation Notes

### **1. WebSocket URL Configuration**
```dart
// Option 1: Hardcoded (development)
final wsUri = Uri.parse('wss://dev-server.com/voice');

// Option 2: Environment variable
final wsUri = Uri.parse(const String.fromEnvironment('WS_URL'));

// Option 3: From config service
final wsUri = Uri.parse(await ConfigService.getWebSocketUrl());
```

### **2. State Synchronization**
The VoiceChatController needs to sync with ConversationController state:

```dart
// ConversationController.state (internal)
enum VoiceState { idle, connecting, listening, aiSpeaking }

// VoiceChatController observables (for UI)
final isListening = false.obs;  // Maps to: listening | aiSpeaking
final isSpeaking = false.obs;   // Maps to: aiSpeaking
final isProcessing = false.obs; // Maps to: connecting
```

### **3. Error Handling**
```dart
try {
  await _conversationController!.startSession(
    wsUri: wsUri,
    scenario: scenario,
  );
} on WebSocketException catch (e) {
  // Handle WebSocket connection errors
  showErrorToast('Connection failed: ${e.message}');
  isListening.value = false;
} on MicrophoneException catch (e) {
  // Handle microphone errors
  showErrorToast('Microphone error: ${e.message}');
  isListening.value = false;
} catch (e) {
  // Handle general errors
  showErrorToast('Error: $e');
  isListening.value = false;
}
```

### **4. Cleanup on Dispose**
```dart
@override
void onClose() {
  _conversationController?.stopSession();
  _conversationController = null;
  _animationTimer?.cancel();
  super.onClose();
}
```

---

## 🚀 Quick Start Implementation

Here's the minimal code to add to `VoiceChatController`:

```dart
// 1. Add import at top
import 'conversation/conversation_controller.dart';
import 'ws/voice_ws_client.dart';
import 'audio/mic_streamer.dart';
import 'audio/tts_player.dart';
import 'audio/barge_in_detector.dart';

// 2. Add instance variable
ConversationController? _conversationController;

// 3. Replace startListening() method
Future<void> startListening() async {
  if (!isListening.value) {
    isListening.value = true;
    _startAnimation();

    _conversationController = ConversationController(
      ws: VoiceWsClient(),
      mic: MicStreamer(sampleRate: 16000, numChannels: 1, frameMs: 20),
      player: TtsPlayer(sampleRate: 24000, numChannels: 1),
      bargeIn: BargeInDetector(threshold: 0.02, requiredFrames: 3),
    );

    await _conversationController!.startSession(
      wsUri: Uri.parse('wss://your-server.com/voice'),
      scenario: scenarioData?.scenarioTitle ?? 'General',
    );
  }
}

// 4. Replace stopListening() method
Future<void> stopListening() async {
  if (isListening.value) {
    await _conversationController?.stopSession();
    _conversationController = null;
    isListening.value = false;
    _stopAnimation();
  }
}

// 5. Update onClose()
@override
void onClose() {
  _conversationController?.stopSession();
  _animationTimer?.cancel();
  super.onClose();
}
```

---

## 🎬 Conclusion

**The bridge between `VoiceChatController.toggleListening()` and `ConversationController.startSession()` is:**

1. User clicks mic → `toggleListening()` called
2. `toggleListening()` calls `startListening()`
3. `startListening()` creates `ConversationController` instance
4. `startListening()` calls `conversationController.startSession(wsUri, scenario)`
5. `startSession()` executes the entire WebSocket workflow (9 initialization steps)
6. Conversation runs in real-time with barge-in support
7. User clicks mic again → `stopListening()` → `conversationController.stopSession()`

This creates a clean separation of concerns:
- **VoiceChatController**: UI state management, user interactions
- **ConversationController**: WebSocket orchestration, audio streaming, state machine
- **Low-level components**: Individual responsibilities (WebSocket, mic, player, detection)
