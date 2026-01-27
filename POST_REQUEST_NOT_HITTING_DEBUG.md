# 🔧 POST Request Not Hitting - Troubleshooting & Fix

## 🐛 Issue
POST request to `/core/chat/message/` is not being made when navigating to message screen.

---

## 🔍 Added Extensive Debugging

### 1. **Message Screen State Logs**
```
🎬 MESSAGE SCREEN initState() CALLED
📦 widget.scenarioData: [data]
🔍 scenarioData is null: [true/false]
✅ ScenarioData received: ID, Title, Type
🔄 Scheduling setScenarioData call...
⏰ PostFrameCallback triggered
✅ Calling controller.setScenarioData()...
```

### 2. **Controller Logs**
```
🎯 SET SCENARIO DATA CALLED
🔑 Scenario ID: [id]
🚀 About to call _startChatSession()...
🎬 _startChatSession() METHOD CALLED
🔍 _scenarioId value: "[value]"
🔄 About to call API service...
```

### 3. **API Service Logs**
```
🚀 STARTING CHAT SESSION
URL: http://10.10.7.74:8001/core/chat/message/
Scenario ID: [id]
Request Body: {"scenario_id": "[id]"}
Auth Token: Present (eyJhbGci...)
Token Length: [number] characters
📥 START CHAT RESPONSE
Status Code: [200/401/etc]
Response Body: [json]
```

---

## 🧪 How to Debug

### Step 1: Check Console Logs

Run the app and navigate to message screen. Look for these logs:

**If you see:**
```
🎬 MESSAGE SCREEN initState() CALLED
❌ No valid scenario data - chat will not start
```
**Problem:** ScenarioData is not being passed to MessageScreen

**Solution:** Check navigation code where you push to MessageScreen:
```dart
// Make sure to pass scenarioData
context.push(AppPath.messageScreen, extra: scenarioData);
```

---

**If you see:**
```
🎬 _startChatSession() METHOD CALLED
❌ No scenario ID available - EXITING METHOD
```
**Problem:** scenarioId is null or empty

**Solution:** Check ScenarioData object has valid scenarioId:
```dart
print('Scenario ID before navigation: ${scenarioData.scenarioId}');
// Should not be null or empty
```

---

**If you see:**
```
🔄 About to call API service...
❌ No access token found in SharedPreferences
```
**Problem:** User not logged in or token not saved

**Solution:** Log in first and save token:
```dart
await prefs.setString('accessToken', loginResponse.accessToken);
```

---

**If you see:**
```
📥 START CHAT RESPONSE
Status Code: 401
❌ 401 UNAUTHORIZED
```
**Problem:** Token is invalid or expired

**Solution:** Log in again to get fresh token

---

**If you see:**
```
📥 START CHAT RESPONSE
Status Code: 200
✅ Chat session started successfully
```
**Success!** API call is working correctly

---

## 🔧 Common Issues & Fixes

### Issue 1: No Logs at All

**Symptom:** No console output when navigating to message screen

**Possible Causes:**
1. Not navigating to message screen correctly
2. App crashed before reaching the screen
3. Console not showing Flutter logs

**Solution:**
```dart
// Add log before navigation
print('🚀 Navigating to message screen with: ${scenarioData.scenarioId}');
context.push(AppPath.messageScreen, extra: scenarioData);
```

---

### Issue 2: Logs Stop at "Scheduling setScenarioData"

**Symptom:**
```
🔄 Scheduling setScenarioData call in postFrameCallback...
[No more logs]
```

**Possible Causes:**
1. PostFrameCallback not being triggered
2. Widget unmounted before callback runs
3. Controller not initialized

**Solution:** Try calling directly instead of using postFrameCallback:
```dart
@override
void initState() {
  super.initState();
  controller = Get.put(MessageScreenController(), tag: 'message_${DateTime.now().millisecondsSinceEpoch}');
  
  // Call directly in initState
  if (widget.scenarioData != null && widget.scenarioData is ScenarioData) {
    Future.microtask(() {
      controller.setScenarioData(widget.scenarioData as ScenarioData);
    });
  }
}
```

---

### Issue 3: scenarioId is Empty String

**Symptom:**
```
🔍 _scenarioId value: ""
❌ No scenario ID available - EXITING METHOD
```

**Solution:** Check where ScenarioData is created:
```dart
// Make sure scenarioId is set
ScenarioData(
  scenarioId: 'scenario_19751c5d',  // ← Must not be empty!
  scenarioTitle: 'Weather Chat',
  // ...
)
```

---

### Issue 4: API Call Made But No Response

**Symptom:**
```
🔄 About to call API service...
[Hangs here, no response]
```

**Possible Causes:**
1. Network connection issue
2. Server not running
3. Firewall blocking request
4. Wrong API URL

**Solution:**
```dart
// 1. Check network
ping 10.10.7.74

// 2. Check server is running
curl http://10.10.7.74:8001/

// 3. Test API directly
curl -X POST http://10.10.7.74:8001/core/chat/message/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"scenario_id": "scenario_19751c5d"}'
```

---

## 🧪 Manual Test Method

Added a test method to verify API works:

```dart
// In your controller or test code
final controller = Get.find<MessageScreenController>();
await controller.testApiCall();

// Check console for:
// 🧪 TEST API CALL
// ✅ TEST API CALL SUCCESS!
```

---

## ✅ Verification Checklist

Before the POST request can work:

- [ ] User is logged in
- [ ] Access token saved: `prefs.setString('accessToken', token)`
- [ ] ScenarioData object created with valid scenarioId
- [ ] ScenarioData passed to MessageScreen via navigation
- [ ] MessageScreen receives scenarioData (check logs)
- [ ] Controller.setScenarioData() is called (check logs)
- [ ] _startChatSession() is called (check logs)
- [ ] scenarioId is not null or empty (check logs)
- [ ] API service method is called (check logs)
- [ ] Network connection is working
- [ ] Server is running at 10.10.7.74:8001

---

## 📋 Complete Flow with Logs

```
1. Navigate to Message Screen
   └─> 🎬 MESSAGE SCREEN initState() CALLED

2. Receive ScenarioData
   └─> ✅ ScenarioData received: ID: scenario_19751c5d

3. Schedule setScenarioData
   └─> 🔄 Scheduling setScenarioData call...

4. PostFrameCallback Fires
   └─> ⏰ PostFrameCallback triggered
   └─> ✅ Calling controller.setScenarioData()...

5. Set Scenario Data
   └─> 🎯 SET SCENARIO DATA CALLED
   └─> 🔑 Scenario ID: scenario_19751c5d
   └─> 🚀 About to call _startChatSession()...

6. Start Chat Session
   └─> 🎬 _startChatSession() METHOD CALLED
   └─> 🔍 _scenarioId value: "scenario_19751c5d"
   └─> 🔄 About to call API service...

7. API Service Call
   └─> 🚀 STARTING CHAT SESSION
   └─> URL: http://10.10.7.74:8001/core/chat/message/
   └─> Request Body: {"scenario_id": "scenario_19751c5d"}
   └─> Auth Token: Present (eyJhbGci...)

8. API Response
   └─> 📥 START CHAT RESPONSE
   └─> Status Code: 200
   └─> ✅ Chat session started successfully
   └─> 💬 Welcome message: "Welcome to Weather Chat!..."

9. Display Message
   └─> ✅ Welcome message added to chat
```

---

## 🎯 Next Steps

1. **Run the app** with the new debug logs
2. **Navigate to message screen**
3. **Check console output** - follow the log trail
4. **Identify where it stops** - that's where the problem is
5. **Apply the fix** from the solutions above
6. **Verify** - should see all logs through to API response

---

## 📞 Quick Debug Commands

```dart
// In your code, add these temporary logs:

// Before navigation
print('About to navigate with: ${scenarioData.scenarioId}');

// In initState
print('MessageScreen initState: ${widget.scenarioData}');

// Before API call
print('Calling API with scenarioId: $_scenarioId');

// After API call
print('API response: ${response.sessionId}');
```

---

## ✅ Status

**DEBUGGING ENHANCED** - Extensive logs added to trace the entire flow from navigation to API response.

Run the app and check console logs to identify exactly where the flow breaks!
