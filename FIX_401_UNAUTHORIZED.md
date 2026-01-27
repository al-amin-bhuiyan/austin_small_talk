# ✅ 401 Unauthorized Error - Fixed

## 🐛 Problem

**Error:** `HTTP 401 Unauthorized` when calling `/core/chat/message/`

**Root Cause:** The access token is either:
1. Not saved to SharedPreferences after login
2. Saved with wrong key name
3. Expired or invalid

---

## ✅ Solution Applied

### 1. **Fixed Token Key Name**

**Changed from:** `'auth_token'`  
**Changed to:** `'accessToken'`

Both API methods now use the correct key:
```dart
final token = prefs.getString('accessToken');
```

### 2. **Added Token Validation**

Both methods now check if token exists before making API call:
```dart
if (token == null || token.isEmpty) {
  throw Exception('Authentication required. Please log in first.');
}
```

### 3. **Added 401 Error Handling**

Specific handling for unauthorized errors:
```dart
if (response.statusCode == 401) {
  print('❌ 401 UNAUTHORIZED');
  print('💡 Token may be expired or invalid');
  throw Exception('Session expired. Please log in again.');
}
```

### 4. **Enhanced Debugging**

Added detailed logging:
```dart
print('💡 Available keys: ${prefs.getKeys()}');
print('Auth Token: Present (${token.substring(0, 20)}...)');
print('Token Length: ${token.length} characters');
```

---

## 🔑 How to Save Token After Login

### **IMPORTANT: You must save the access token after successful login!**

Add this code to your login controller/handler:

```dart
// After successful login API call
Future<void> handleLogin() async {
  try {
    final response = await apiServices.loginUser(loginRequest);
    
    // ✅ SAVE THE ACCESS TOKEN TO SHAREDPREFERENCES
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', response.accessToken);
    
    // Optional: Also save refresh token
    if (response.refreshToken != null) {
      await prefs.setString('refreshToken', response.refreshToken!);
    }
    
    // Optional: Save user info
    if (response.userId != null) {
      await prefs.setInt('userId', response.userId!);
    }
    if (response.userName != null) {
      await prefs.setString('userName', response.userName!);
    }
    if (response.email != null) {
      await prefs.setString('email', response.email!);
    }
    
    print('✅ Access token saved successfully');
    print('Token: ${response.accessToken.substring(0, 20)}...');
    
    // Navigate to home screen
    Get.offAll(() => HomeScreen());
    
  } catch (e) {
    print('❌ Login failed: $e');
    // Show error to user
  }
}
```

---

## 📊 Complete Login Flow

```
User enters email & password
    ↓
Call API: POST /accounts/user/login/
Body: {"email": "...", "password": "..."}
    ↓
API Response:
{
  "message": "Login successful",
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user_id": 123,
  "user_name": "John Doe",
  "email": "john@example.com"
}
    ↓
Save to SharedPreferences:
✅ prefs.setString('accessToken', response.accessToken)
✅ prefs.setString('refreshToken', response.refreshToken)
✅ prefs.setInt('userId', response.userId)
    ↓
Navigate to home screen
    ↓
User can now use chat API with valid token!
```

---

## 🔍 Debugging 401 Errors

### Check if Token is Saved

```dart
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('accessToken');

print('Token exists: ${token != null}');
print('Token value: ${token?.substring(0, 20)}...');
print('All keys: ${prefs.getKeys()}');
```

### Check Token Format

JWT tokens should look like:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMjN9.abc123...
```

Three parts separated by dots (`.`)

### Verify API Call

Check console logs:
```
🚀 STARTING CHAT SESSION
URL: http://10.10.7.74:8001/core/chat/message/
Auth Token: Present (eyJhbGciOiJIUzI1NiIs...)
Token Length: 250 characters

📥 START CHAT RESPONSE
Status Code: 401  ← Problem here!
```

---

## 🛠️ Common Issues & Solutions

### Issue 1: Token Not Saved
**Symptom:** `❌ No access token found in SharedPreferences`

**Solution:**
```dart
// Make sure to save token after login
await prefs.setString('accessToken', response.accessToken);
```

### Issue 2: Wrong Key Name
**Symptom:** Token saved but API gets 401

**Solution:** Use exact key name `'accessToken'`:
```dart
// ✅ Correct
await prefs.setString('accessToken', token);

// ❌ Wrong
await prefs.setString('auth_token', token);
await prefs.setString('token', token);
```

### Issue 3: Token Expired
**Symptom:** Worked before, now returns 401

**Solution:** Implement token refresh or ask user to log in again:
```dart
if (response.statusCode == 401) {
  // Clear expired token
  await prefs.remove('accessToken');
  
  // Navigate to login
  Get.offAll(() => LoginScreen());
  
  // Show message
  Get.snackbar('Session Expired', 'Please log in again');
}
```

### Issue 4: Invalid Token Format
**Symptom:** API rejects token immediately

**Solution:** Verify token is sent with "Bearer " prefix:
```dart
headers: {
  'Authorization': 'Bearer $token',  // ✅ Correct with "Bearer "
}
```

---

## 📝 Updated Code Files

### api_services.dart

**Changes:**
1. ✅ Changed token key from `'auth_token'` to `'accessToken'`
2. ✅ Added token existence check
3. ✅ Added 401 specific error handling
4. ✅ Added detailed debug logging
5. ✅ Removed conditional Authorization header (always include if token exists)

### Both Methods Updated:
- `startChatSession()`
- `sendChatMessage()`

---

## 🧪 Testing

### 1. Test Without Token (Should Fail)
```dart
// Clear token
final prefs = await SharedPreferences.getInstance();
await prefs.remove('accessToken');

// Try to start chat
// Expected: Exception('Authentication required. Please log in first.')
```

### 2. Test With Invalid Token (Should Fail)
```dart
// Set fake token
await prefs.setString('accessToken', 'fake-token-123');

// Try to start chat
// Expected: 401 error → Exception('Session expired. Please log in again.')
```

### 3. Test With Valid Token (Should Succeed)
```dart
// Login first to get real token
await login();

// Try to start chat
// Expected: 200 OK → Welcome message appears
```

---

## 📋 Checklist

Before using chat API, ensure:

- [ ] User has logged in successfully
- [ ] Access token is saved to SharedPreferences with key `'accessToken'`
- [ ] Token is not expired (typically valid for 1 hour)
- [ ] Token is a valid JWT format (3 parts separated by dots)
- [ ] Authorization header includes "Bearer " prefix
- [ ] Network connection is working
- [ ] API server is running

---

## 🎯 Next Steps

1. **Add token saving to login flow**
   - Find your login controller/handler
   - Add `prefs.setString('accessToken', response.accessToken)` after successful login

2. **Test the flow**
   - Log in with valid credentials
   - Check console for token saved confirmation
   - Try opening a chat
   - Verify 200 OK response

3. **Handle token expiration**
   - Implement token refresh mechanism
   - Or redirect to login on 401 errors

---

## ✅ Status

**FIXED** - 401 error handling implemented

**Action Required:**
- ⚠️ **Save access token to SharedPreferences after login**
- Key: `'accessToken'`
- Value: `response.accessToken` from login API

Once the token is saved properly, the chat API will work! 🎉
