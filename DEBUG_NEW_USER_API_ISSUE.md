# Debug: New User API Not Working Issue

## Problem Statement
When a new user creates an account and signs up, APIs are not working (no scenarios loading, profile not loading, etc.)

## Root Cause Analysis

### Possible Issues:
1. **Access token not being saved properly** during OTP verification
2. **Access token not being retrieved properly** when APIs are called
3. **Token format mismatch** - API response format different than expected
4. **Session not persisting** after navigation to verified screen
5. **Controllers not initialized** when home screen loads

## Debug Logging Added

### 1. SharedPreferencesUtil.saveUserSession()
Now logs detailed information when saving session:
```
╔═══════════════════════════════════════════════════════════╗
║              SAVING USER SESSION                           ║
╚═══════════════════════════════════════════════════════════╝
📝 Received:
   accessToken: eyJhbGci... (xxx chars)
   refreshToken: Present/NULL
   userId: 123
   userName: John Doe
   email: john@example.com

💾 Saving to SharedPreferences...
   ✅ Access token saved
   ✅ Refresh token saved
   ✅ User ID saved
   ✅ User name saved
   ✅ Email saved
   ✅ isLoggedIn flag set to true

🔍 Verifying saved data:
   Token exists: true
   Token length: 200
   isLoggedIn: true
   userId: 123
```

### 2. HomeController.fetchDailyScenarios()
Now logs detailed API call information:
```
╔═══════════════════════════════════════════════════════════╗
║         FETCHING DAILY SCENARIOS FOR NEW USER             ║
╚═══════════════════════════════════════════════════════════╝
🔑 Checking access token:
   Token exists: true/false
   Token length: xxx
   Token preview: eyJhbGci...

📡 Calling API with token...
📥 API Response received:
   Status: success
   Scenarios count: 5
```

### 3. HomeController.fetchUserProfile()
Now logs profile fetch details:
```
╔═══════════════════════════════════════════════════════════╗
║              FETCHING USER PROFILE                         ║
╚═══════════════════════════════════════════════════════════╝
🔑 Checking access token:
   Token exists: true/false
   Token length: xxx

📡 Calling getUserProfile API...
✅ User profile loaded:
   Name: John Doe
   Email: john@example.com
   Image: https://...
```

## How to Debug

### Step 1: Create New Account
1. Open app
2. Click "Sign Up"
3. Enter details
4. Click "Create Account"

### Step 2: Verify Email
1. Enter OTP received
2. Click "Verify"
3. **Check Console Logs:**
   - Look for "SAVING USER SESSION" block
   - Verify `accessToken: eyJ...` is present
   - Verify `✅ Access token saved` appears
   - Verify `Token exists: true` in verification

### Step 3: Navigate to Verified Screen
1. After verification succeeds
2. **Check Console Logs:**
   - Look for navigation logs
   - Verify no errors

### Step 4: Click "Continue" Button
1. On verified screen, click "Continue"
2. **Check Console Logs:**
   - Look for "Resetting controllers"
   - Look for "Navigating to home"

### Step 5: Home Screen Loads
1. App navigates to home
2. **Check Console Logs:**
   - Look for "FETCHING USER PROFILE" block
   - Look for "FETCHING DAILY SCENARIOS FOR NEW USER" block
   - Verify `Token exists: true`
   - Verify `Token length: > 0`

## Expected Console Output (Success)

```
// During OTP Verification
📦 VerifyOtpResponseModel.fromJson:
   Raw JSON keys: [msg, access, refresh, id, email, name]
   access: String
   refresh: String
   id: int

✅ OTP verification API call successful
📦 Response access token: Present (200 chars)
✅ Access token received, saving session...

╔═══════════════════════════════════════════════════════════╗
║              SAVING USER SESSION                           ║
╚═══════════════════════════════════════════════════════════╝
💾 Saving to SharedPreferences...
   ✅ Access token saved
   ✅ isLoggedIn flag set to true
🔍 Verifying saved data:
   Token exists: true
   isLoggedIn: true

// Navigate to home
🔄 Navigating to home...
✅ Navigation to home initiated

// Home screen loads
╔═══════════════════════════════════════════════════════════╗
║              FETCHING USER PROFILE                         ║
╚═══════════════════════════════════════════════════════════╝
🔑 Checking access token:
   Token exists: true
   Token length: 200
📡 Calling getUserProfile API...
✅ User profile loaded

╔═══════════════════════════════════════════════════════════╗
║         FETCHING DAILY SCENARIOS FOR NEW USER             ║
╚═══════════════════════════════════════════════════════════╝
🔑 Checking access token:
   Token exists: true
   Token length: 200
📡 Calling API with token...
✅ Fetched 5 daily scenarios
```

## Possible Error Scenarios

### Error 1: Token Not Saved
```
╔═══════════════════════════════════════════════════════════╗
║              SAVING USER SESSION                           ║
╚═══════════════════════════════════════════════════════════╝
❌ Error saving user session: [error message]
```
**Solution:** Check SharedPreferences initialization

### Error 2: Token Not Found on Home Screen
```
╔═══════════════════════════════════════════════════════════╗
║         FETCHING DAILY SCENARIOS FOR NEW USER             ║
╚═══════════════════════════════════════════════════════════╝
🔑 Checking access token:
   Token exists: false
   Token length: 0
❌ No access token found - cannot fetch scenarios
```
**Solution:** Token was saved but not retrieved - check SharedPreferences keys match

### Error 3: API Returns No Token
```
📦 VerifyOtpResponseModel.fromJson:
   Raw JSON keys: [msg]
   access: null
   refresh: null

⚠️ No access token in OTP verification response
⚠️ Full response: {msg: "Account verified"}
```
**Solution:** Server not returning tokens - check backend API

### Error 4: API Call Fails
```
❌❌❌ ERROR FETCHING DAILY SCENARIOS ❌❌❌
Error: Exception: Failed to fetch scenarios with status: 401
```
**Solution:** Token is invalid or expired - check token format

## Files Modified

| File | Purpose |
|------|---------|
| `shared_preference.dart` | Added detailed logging to `saveUserSession()` |
| `home_controller.dart` | Added logging to `fetchUserProfile()` and `fetchDailyScenarios()` |

## Next Steps

1. **Run the app** with a new user signup
2. **Check console logs** for the debug output
3. **Identify where the flow breaks:**
   - Token not in API response?
   - Token not being saved?
   - Token not being retrieved?
   - API calls failing?

4. **Share the console logs** showing:
   - OTP verification logs
   - Session saving logs
   - Home screen loading logs
   - Any error messages

This will help pinpoint exactly where the issue is occurring.
