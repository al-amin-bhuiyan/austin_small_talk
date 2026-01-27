# 🚀 Quick Reference: Message Screen API Integration

## ✅ What Was Implemented

### 📁 Files Created
1. `chat_session_start_response_model.dart` - Models for session start
2. `chat_message_request_model.dart` - Model for sending messages
3. `chat_message_response_model.dart` - Models for message responses

### 🔧 Files Modified
1. `api_constant.dart` - Added chat session endpoints
2. `api_services.dart` - Added `startChatSession()` and `sendChatMessage()` methods
3. `message_screen_controller.dart` - Complete API integration
4. `message_screen.dart` - Added loading states and UI feedback

---

## 🔑 Key Information

### Session ID Flow
```dart
// 1. Captured from start session API
_sessionId = "eb10b7ca-4277-48ba-8b56-8bdff86fe622"

// 2. Used for all subsequent messages
POST /core/chat/sessions/{_sessionId}/message/
```

### Welcome Message Path
```dart
// Extract from:
response.aiMessage.metadata?.rawAiResponse?.welcomeMessage

// JSON path:
response → ai_message → metadata → raw_ai_response → welcome_message
```

### AI Response Path
```dart
// Extract from:
response.aiMessage.textContent

// JSON path:
response → ai_message → text_content
```

---

## 📊 API Endpoints

### 1. Start Session
```http
POST http://10.10.7.74:8001/core/chat/sessions/?scenario_id=scenario_a82ef385
Authorization: Bearer {token}
Content-Type: application/json

Response:
{
  "session_id": "eb10b7ca-...",
  "ai_message": {
    "metadata": {
      "raw_ai_response": {
        "welcome_message": "Welcome to Weather Chat!..."
      }
    }
  }
}
```

### 2. Send Message
```http
POST http://10.10.7.74:8001/core/chat/sessions/eb10b7ca-.../message/
Authorization: Bearer {token}
Content-Type: application/json

Body:
{
  "text_content": "how you help me?"
}

Response:
{
  "user_message": {...},
  "ai_message": {
    "text_content": "I can help you by talking about..."
  }
}
```

---

## 🔍 How to Test

### Test Session Start
1. Navigate to home screen
2. Click on any scenario
3. Watch for console logs:
   ```
   🔑 Scenario ID: scenario_a82ef385
   🚀 Starting chat session with scenario: scenario_a82ef385
   ✅ Chat session started successfully
   📋 Session ID: eb10b7ca-4277-48ba-8b56-8bdff86fe622
   💬 Welcome message: Welcome to Weather Chat!...
   ```
4. Verify welcome message appears in chat

### Test Message Sending
1. Type a message
2. Click send
3. Watch for console logs:
   ```
   📤 Sending message: how you help me?
   🔑 Session ID: eb10b7ca-4277-48ba-8b56-8bdff86fe622
   ✅ Message sent successfully
   💬 AI Response: I can help you by talking about...
   ```
4. Verify both user message and AI response appear

### Test Error Handling
1. Turn off internet
2. Try sending a message
3. Verify error snackbar appears
4. Verify message is removed from UI
5. Verify text is restored to input field

---

## 🐛 Debugging

### Check Session ID
```dart
print('Current session ID: $_sessionId');
```

### Check API Response
Look for console logs:
```
API Request: POST http://...
Response Status: 200
Response Body: {...}
```

### Check Message Flow
```dart
print('Messages count: ${messages.length}');
print('Last message: ${messages.last.text}');
print('Is user: ${messages.last.isUser}');
```

---

## 💡 Common Issues

### Issue: Welcome message not showing
**Solution:** Check that scenario has `scenario_id` in `ScenarioData`

### Issue: "Chat session not started" error
**Solution:** Wait for loading to complete before sending message

### Issue: Messages not appearing
**Solution:** Check console for API errors, verify token is valid

### Issue: Send button stuck in loading
**Solution:** Check network, verify API endpoint is correct

---

## 📝 Code Examples

### Start Session (Automatic)
```dart
void setScenarioData(ScenarioData data) {
  scenarioData = data;
  _scenarioId = data.scenarioId;
  _startChatSession(); // Automatic!
}
```

### Send Message (Manual)
```dart
Future<void> sendMessage() async {
  final text = messageController.text.trim();
  if (text.isEmpty) return;
  
  // Add to UI
  messages.add(ChatMessage(text: text, isUser: true));
  
  // Send to API
  final request = ChatMessageRequest(textContent: text);
  final response = await _apiServices.sendChatMessage(_sessionId!, request);
  
  // Add AI response
  messages.add(ChatMessage(
    text: response.aiMessage.textContent,
    isUser: false,
  ));
}
```

---

## 🎯 Next Features (Optional)

- [ ] Auto-scroll to latest message
- [ ] Typing indicator
- [ ] Message timestamps display
- [ ] Retry failed messages
- [ ] Voice message support
- [ ] Audio playback from `audio_url`
- [ ] Session history
- [ ] Export conversation

---

## ✨ Success Indicators

✅ Welcome message appears automatically  
✅ User messages send instantly  
✅ AI responses appear after sending  
✅ Loading states work correctly  
✅ Errors are handled gracefully  
✅ Session persists during conversation  
✅ No console errors  

---

## 📞 Support

If you encounter issues:
1. Check console logs for detailed error messages
2. Verify API server is running
3. Verify auth token is valid
4. Check network connectivity
5. Review CHAT_SESSION_API_IMPLEMENTATION.md for detailed flow

---

**Implementation Date:** January 21, 2026  
**Status:** ✅ Complete and Production Ready  
**Version:** 1.0.0
