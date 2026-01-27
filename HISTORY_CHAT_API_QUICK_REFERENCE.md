# 📚 History Chat API - Quick Reference

## API Endpoint
```
GET http://10.10.7.74:8001/core/chat/sessions/history/
Authorization: Bearer {access_token}
```

## Request Example
```dart
final response = await _apiServices.getChatHistory(
  accessToken: accessToken,
);
```

## Expected Response
```json
{
  "status": "success",
  "count": 241,
  "sessions": [
    {
      "session_id": "cbf63a00-69ca-48cb-b824-926e3e266cc9",
      "scenario_id": "scenario_1947cb70",
      "scenario_title": "",
      "scenario_emoji": "",
      "scenario_difficulty": "",
      "mode": "text",
      "status": "active",
      "started_at": "2026-01-26T18:27:13.178949Z",
      "last_activity_at": "2026-01-26T18:27:14.154374Z",
      "ended_at": null,
      "user_email": "mdshobuj204111@gmail.com",
      "message_count": 1
    }
  ]
}
```

## Model Classes

### ChatHistoryResponseModel
```dart
ChatHistoryResponseModel({
  required String status,
  required int count,
  required List<ChatSessionHistory> sessions,
})
```

### ChatSessionHistory
```dart
ChatSessionHistory({
  required String sessionId,
  String? scenarioId,
  String? scenarioTitle,
  String? scenarioEmoji,
  String? scenarioDifficulty,
  required String mode,
  required String status,
  required DateTime startedAt,
  required DateTime lastActivityAt,
  DateTime? endedAt,
  required String userEmail,
  required int messageCount,
})
```

## Usage in Controller

```dart
// Fetch chat history
await fetchChatHistory();

// Access sessions
final sessions = chatSessions.value;

// Get conversations for UI
final convos = conversations;

// Filter by search
updateSearchQuery('coffee');
final filtered = filteredConversations;

// Handle tap
onConversationTap(sessionId, context);
```

## Time Formatting
- Just now
- 5m ago, 2h ago
- Yesterday
- 3 days ago
- 2 weeks ago
- 3 months ago

## Key Fields from API Response

| Field | Type | Description |
|-------|------|-------------|
| `session_id` | String | Unique session identifier |
| `scenario_id` | String? | Associated scenario ID (optional) |
| `scenario_title` | String? | Scenario title (may be empty) |
| `scenario_emoji` | String? | Scenario emoji (may be empty) |
| `scenario_difficulty` | String? | Difficulty level (may be empty) |
| `mode` | String | Chat mode (e.g., "text") |
| `status` | String | Session status (e.g., "active") |
| `started_at` | DateTime | When session started |
| `last_activity_at` | DateTime | Last activity timestamp |
| `ended_at` | DateTime? | When session ended (null if active) |
| `user_email` | String | User's email |
| `message_count` | int | Number of messages in session |

## Files Modified

1. `lib/service/auth/api_constant/api_constant.dart` - Added chatHistory endpoint
2. `lib/service/auth/models/chat_history_model.dart` - Updated model to match API
3. `lib/service/auth/api_service/api_services.dart` - Added getChatHistory method
4. `lib/pages/history/history_controller.dart` - Updated to use chat history API

## Error Messages

- `❌ No access token found` - User not logged in
- `Failed to load chat history` - API or network error
- `Chat session not found` - Invalid session ID

## Testing Commands

```dart
// Print all sessions
print('Sessions: ${controller.chatSessions.length}');

// Print conversations
controller.conversations.forEach((c) {
  print('${c.title}: ${c.preview} (${c.messageCount} messages)');
});

// Test search
controller.updateSearchQuery('test');
print('Filtered: ${controller.filteredConversations.length}');
```

## Backend Requirements

✅ Endpoint: `GET /core/chat/sessions/history/`
✅ Authorization: Bearer token required
✅ Response format: JSON as shown above
✅ All fields properly formatted
✅ Timestamps in ISO 8601 format
✅ Session IDs as strings
✅ Count field shows total number of sessions

## Handling Empty Fields

The API may return empty strings for optional fields:
- `scenario_title` - Use fallback: "Chat Session"
- `scenario_emoji` - Use fallback: "💬"
- `scenario_difficulty` - Use fallback: "easy"

## Preview Text Generation

```dart
String preview = 'No messages yet';
if (session.messageCount > 0) {
  preview = '${session.messageCount} ${session.messageCount == 1 ? 'message' : 'messages'}';
}
```

## Troubleshooting

**No history showing?**
- Check access token exists
- Verify backend endpoint is running
- Check console for error messages
- Verify response format matches model

**Empty scenario fields?**
- API returns empty strings for missing data
- Controller handles this with fallback values
- Check if scenario was properly created

**Wrong timestamps?**
- Backend sends ISO 8601 format
- Check timezone handling
- Verify DateTime parsing

**Navigation not working?**
- Check sessionId is correct
- Verify message screen accepts scenarioData
- Check AppPath.messageScreen is defined

---

✅ **History Screen now uses real chat history from backend**
✅ **All changes compiled successfully**
✅ **Ready for testing with backend integration**
✅ **Handles empty scenario fields gracefully**
