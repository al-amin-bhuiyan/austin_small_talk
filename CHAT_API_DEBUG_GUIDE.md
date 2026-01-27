# 🔧 Chat API Debug & Fix Guide

## ✅ Current Configuration

### Token Key Being Used
```dart
final token = prefs.getString('access_token');  ✅ CORRECT
```

### API Endpoint
```dart
URL: http://10.10.7.74:8001/core/chat/message/  ✅ CORRECT
```

### Request Format
```dart
POST /core/chat/message/
Headers:
  Content-Type: application/json
  Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
Body:
  {"scenario_id": "scenario_e4e77284"}
```

---

## 🧪 Quick Test Steps

### 1. Verify Token is Saved
Run this to check if token exists:
```dart
final prefs = await SharedPreferences.getInstance();
print('Token: ${prefs.getString('access_token')}');
print('All keys: ${prefs.getKeys()}');
```

### 2. Test API Call
Use the test method in controller:
```dart
final controller = Get.find<MessageScreenController>();
await controller.testApiCall();
```

### 3. Check Console Output
Look for these logs:
```
🚀 STARTING CHAT SESSION
URL: http://10.10.7.74:8001/core/chat/message/
Auth Token: Present (eyJhbGci...)
📥 START CHAT RESPONSE
Status Code: [CHECK THIS NUMBER]
```

---

## 🔍 Common Issues & Solutions

### Issue 1: "No access token found"
**Console shows:**
```
❌ No access token found in SharedPreferences
💡 Available keys: {remember_me, user_email, ...}
```

**Cause:** Token key doesn't match or token not saved

**Fix:** Verify token is saved with correct key
```dart
// After login, ensure this is called:
await SharedPreferencesUtil.saveUserSession(
  accessToken: response.accessToken,  // From login response
  refreshToken: response.refreshToken,
);

// This saves to: prefs.setString('access_token', accessToken)
```

---

### Issue 2: 401 Unauthorized
**Console shows:**
```
Status Code: 401
❌ 401 UNAUTHORIZED
```

**Cause:** Token expired or invalid

**Fix:** Log in again to get fresh token
```dart
// User needs to login again
context.go(AppPath.login);
```

---

### Issue 3: Network Error
**Console shows:**
```
❌ Exception in startChatSession: SocketException
```

**Cause:** Server not reachable

**Fix:** 
1. Check server is running:
   ```bash
   ping 10.10.7.74
   curl http://10.10.7.74:8001/
   ```

2. Check if on same network
3. Check firewall settings

---

### Issue 4: 400 Bad Request
**Console shows:**
```
Status Code: 400
Response Body: {"error": "Invalid scenario_id"}
```

**Cause:** Invalid scenario ID format

**Fix:** Use correct scenario ID from API
```dart
// Make sure scenario ID comes from daily scenarios API
// Format: "scenario_XXXXXXXX"
```

---

### Issue 5: 500 Server Error
**Console shows:**
```
Status Code: 500
Response Body: {"error": "Internal server error"}
```

**Cause:** Backend error

**Fix:** Check backend logs, contact API developer

---

## 🛠️ Manual API Test

Test the API directly with curl:

```bash
# Get your token first
# From SharedPreferences or login response

curl -X POST http://10.10.7.74:8001/core/chat/message/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"scenario_id": "scenario_e4e77284"}'
```

**Expected Response (200 OK):**
```json
{
  "status": "success",
  "session_id": "acaeb58a-c371-40fe-8877-d84d8f8b7d12",
  "is_new_session": true,
  "ai_message": {
    "metadata": {
      "raw_ai_response": {
        "welcome_message": "Welcome to..."
      }
    }
  }
}
```

---

## 📋 Complete Checklist

Before API will work:

- [ ] User logged in successfully
- [ ] Token saved: `prefs.getString('access_token')` returns value
- [ ] Token is valid JWT (3 parts: header.payload.signature)
- [ ] Token not expired (check `exp` claim in JWT)
- [ ] Network connectivity working
- [ ] Server running at 10.10.7.74:8001
- [ ] Scenario ID is valid format
- [ ] App has internet permission (AndroidManifest.xml)

---

## 🎯 Current Code Status

**API Service:** ✅ Correctly configured
- Uses `'access_token'` key
- Includes Bearer token in header
- Proper error handling for 401

**Controller:** ✅ Correctly configured
- Calls API with scenario ID
- Handles response properly
- Shows welcome message

**UI:** ✅ Correctly configured
- Loading state shown
- Messages displayed
- Error handling in place

---

## 🔄 Complete Flow Verification

```
1. User clicks scenario
   └─> ✅ ScenarioData passed to MessageScreen

2. MessageScreen.initState()
   └─> ✅ Controller.setScenarioData() called

3. Controller._startChatSession()
   └─> ✅ Gets token from 'access_token'
   └─> ✅ Makes POST request
   └─> ⚠️  CHECK RESPONSE HERE

4. API Response
   └─> If 200: ✅ Welcome message shown
   └─> If 401: ❌ Token expired
   └─> If 400: ❌ Bad request
   └─> If 500: ❌ Server error
```

---

## 💡 Debug Commands

Add these to your code temporarily:

```dart
// In _startChatSession(), before API call:
print('🔍 DEBUG INFO:');
print('Token exists: ${token != null}');
print('Token length: ${token?.length}');
print('Token preview: ${token?.substring(0, 20)}...');
print('Request URL: $url');
print('Request body: ${jsonEncode(requestBody)}');

// After API response:
print('🔍 RESPONSE DEBUG:');
print('Status: ${response.statusCode}');
print('Headers: ${response.headers}');
print('Body: ${response.body}');
```

---

## 🎉 Expected Working Flow

**Console Output (Success):**
```
🚀 STARTING CHAT SESSION
URL: http://10.10.7.74:8001/core/chat/message/
Scenario ID: scenario_e4e77284
Request Body: {"scenario_id":"scenario_e4e77284"}
Auth Token: Present (eyJhbGciOiJIUzI1NiIs...)
Token Length: 250 characters

📥 START CHAT RESPONSE
Status Code: 200
Response Body: {"status":"success","session_id":"..."}

✅ Chat session started successfully
📋 Session ID: acaeb58a-c371-40fe-8877-d84d8f8b7d12
💬 Welcome message: Welcome to Weather Chat!...
✅ Welcome message added to chat
```

**UI Result:**
- Loading spinner disappears
- Welcome message appears in chat bubble
- Input field ready for user to type

---

## 🚀 Next Steps

1. **Run the app** and navigate to message screen
2. **Check console logs** - identify which step fails
3. **Compare with expected flow** above
4. **Apply fix** based on error type
5. **Test again** until you see Status Code: 200

The API should work! If you see any error, the console logs will tell you exactly what's wrong.
