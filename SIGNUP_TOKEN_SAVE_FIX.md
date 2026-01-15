# Signup Token Save Fix - Complete ✅

## Problem Identified

After signing up a new account, the **delete account feature was not working**, but after logout and login, it worked perfectly. 

### Root Cause

The issue was that **access tokens were not being saved to SharedPreferences after OTP verification** during the signup flow. 

- ✅ **Login flow**: Tokens were saved correctly → Delete account worked
- ❌ **Signup flow**: Tokens were NOT saved → No access token available → Delete account failed

## The Issue in Detail

### What Happened During Signup:

1. User registered → API returned success
2. User verified OTP → API returned **access token + refresh token**
3. ❌ **Tokens were NOT saved to SharedPreferences**
4. User navigated to verified screen
5. User tried to delete account → **No token found** → Failed

### What Happened After Login:

1. User logged in → API returned tokens
2. ✅ **Tokens were saved to SharedPreferences**
3. User tried to delete account → **Token found** → Success!

## Files Modified

### 1. `verify_otp_response_model.dart`

**Before:**
```dart
class VerifyOtpResponseModel {
  final String message;
  final dynamic data; // Just storing raw data
  
  // Not extracting tokens!
}
```

**After:**
```dart
class VerifyOtpResponseModel {
  final String message;
  final String? accessToken;      // ✅ Extract access token
  final String? refreshToken;     // ✅ Extract refresh token
  final int? userId;              // ✅ Extract user ID
  final String? userName;         // ✅ Extract user name
  final String? email;            // ✅ Extract email
  final dynamic data;             // Keep for any additional data

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] is Map<String, dynamic> 
        ? json['data'] as Map<String, dynamic> 
        : <String, dynamic>{};
    
    return VerifyOtpResponseModel(
      message: json['msg'] ?? json['message'] ?? 'OTP verified successfully',
      // Check both root level and data field for tokens
      accessToken: json['access'] ?? json['access_token'] ?? json['token'] ?? 
                   dataMap['access'] ?? dataMap['access_token'] ?? dataMap['token'],
      refreshToken: json['refresh'] ?? json['refresh_token'] ?? 
                    dataMap['refresh'] ?? dataMap['refresh_token'],
      userId: json['user_id'] ?? json['id'] ?? 
              dataMap['user_id'] ?? dataMap['id'],
      userName: json['user_name'] ?? json['name'] ?? json['username'] ?? 
                dataMap['user_name'] ?? dataMap['name'] ?? dataMap['username'],
      email: json['email'] ?? dataMap['email'],
      data: json['data'],
    );
  }
}
```

**What Changed:**
- ✅ Added fields to extract `accessToken`, `refreshToken`, `userId`, `userName`, `email`
- ✅ Checks both root level AND `data` field for token values (flexible API response handling)
- ✅ Similar pattern to `LoginResponseModel` for consistency

### 2. `verify_email_controller.dart`

**Before:**
```dart
// Call API
final response = await _apiServices.verifyOtp(request);

// Show success message
if (context.mounted) {
  CustomSnackbar.success(...);
}

// Navigate to Verified Screen
context.go(AppPath.verifiedfromverifyemail);
```

**After:**
```dart
// Call API
final response = await _apiServices.verifyOtp(request);

// ✅ Save user session if tokens are provided
if (response.accessToken != null && response.accessToken!.isNotEmpty) {
  print('✅ Access token received, saving session...');
  await SharedPreferencesUtil.saveUserSession(
    accessToken: response.accessToken!,
    refreshToken: response.refreshToken,
    userId: response.userId,
    userName: response.userName,
    email: response.email ?? email.value,
  );
  print('✅ User session saved successfully');
} else {
  print('⚠️ No access token in OTP verification response');
}

// Show success message
if (context.mounted) {
  CustomSnackbar.success(...);
}

// Navigate to Verified Screen
context.go(AppPath.verifiedfromverifyemail);
```

**What Changed:**
- ✅ Added import: `import '../../data/global/shared_preference.dart';`
- ✅ After successful OTP verification, now saves tokens to SharedPreferences
- ✅ Saves: `accessToken`, `refreshToken`, `userId`, `userName`, `email`
- ✅ Same behavior as login flow

## What Gets Saved Now

After OTP verification, the following data is saved to SharedPreferences:

| Key | Value | Source |
|-----|-------|--------|
| `access_token` | JWT token | From API response |
| `refresh_token` | Refresh token | From API response |
| `user_id` | User ID | From API response |
| `user_name` | User name | From API response |
| `email` | User email | From API response or input |
| `is_logged_in` | `true` | Set automatically |

## Flow Comparison

### ❌ Before (Broken)

```
Signup → Verify OTP → Navigate to Verified Screen
                ↓
            (No token saved)
                ↓
        Try Delete Account
                ↓
    No token found → FAILS ❌
```

### ✅ After (Fixed)

```
Signup → Verify OTP → Save Tokens → Navigate to Verified Screen
                         ↓
                (Token saved to SharedPreferences)
                         ↓
                 Try Delete Account
                         ↓
            Token found → SUCCESS ✅
```

## API Response Handling

The model now handles multiple API response formats:

### Format 1: Tokens at Root Level
```json
{
  "msg": "OTP verified successfully",
  "access": "eyJhbGc...",
  "refresh": "eyJhbGc...",
  "user_id": 123,
  "user_name": "John Doe",
  "email": "user@example.com"
}
```

### Format 2: Tokens in Data Field
```json
{
  "msg": "OTP verified successfully",
  "data": {
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc...",
    "id": 123,
    "name": "John Doe",
    "email": "user@example.com"
  }
}
```

### Format 3: Mixed Format
```json
{
  "message": "OTP verified successfully",
  "token": "eyJhbGc...",
  "refresh": "eyJhbGc...",
  "data": {
    "user_id": 123,
    "username": "John Doe"
  }
}
```

**All formats are now supported!** ✅

## Testing Scenarios

### ✅ Test Case 1: New Signup → Delete Account
1. Create new account
2. Enter OTP and verify
3. ✅ Tokens are saved to SharedPreferences
4. Go to Settings → Security → Delete Account
5. ✅ **Delete account works immediately** (no need to logout/login)

### ✅ Test Case 2: Signup → Use App Features
1. Create new account
2. Enter OTP and verify
3. ✅ Tokens are saved
4. Try to use any authenticated feature
5. ✅ All features work (token is available)

### ✅ Test Case 3: Signup → Close App → Reopen
1. Create new account
2. Enter OTP and verify
3. ✅ Tokens are saved
4. Close the app completely
5. Reopen the app
6. ✅ User stays logged in (token persists)

## Benefits

✅ **Consistent Behavior**: Signup and Login flows now behave the same way
✅ **Immediate Access**: Users can use all features immediately after signup
✅ **No Logout Required**: Delete account works right after signup
✅ **Token Persistence**: Tokens are saved and available across app restarts
✅ **Better UX**: Seamless user experience from signup to app usage

## Related Files

- `lib/service/auth/models/verify_otp_response_model.dart` - Model updated
- `lib/pages/verify_email/verify_email_controller.dart` - Save session logic added
- `lib/data/global/shared_preference.dart` - Used for saving tokens
- `lib/service/auth/models/login_response_model.dart` - Similar pattern reference

## Summary

The fix ensures that **after a user verifies their email during signup, their access tokens are saved to SharedPreferences**, making them immediately available for all authenticated operations including account deletion. This brings the signup flow in line with the login flow and provides a seamless user experience.

**Problem:** Delete account didn't work after signup (no token saved)  
**Solution:** Save tokens to SharedPreferences after OTP verification  
**Result:** Delete account (and all other features) work immediately after signup ✅
