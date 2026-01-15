# Testing Checklist: Signup Token Save Fix ✅

## Pre-Test Setup
- [ ] Clear app data / Uninstall and reinstall app (to start fresh)
- [ ] Have a new email address ready for testing

---

## Test 1: Signup → Immediate Delete Account ✅

### Steps:
1. [ ] Open app
2. [ ] Click "Sign Up" / "Create Account"
3. [ ] Enter email, name, password, DOB
4. [ ] Select preferred gender (AI voice)
5. [ ] Submit registration
6. [ ] Enter OTP code from email
7. [ ] Click "Verify"
8. [ ] **Check console logs for:** `✅ Access token received, saving session...`
9. [ ] **Check console logs for:** `✅ User session saved successfully`
10. [ ] Navigate to Profile → Security
11. [ ] Click "Delete Account"
12. [ ] Confirm deletion
13. [ ] **Expected:** Account deleted successfully ✅
14. [ ] **Expected:** Redirected to login screen ✅

### Success Criteria:
- ✅ No error messages during OTP verification
- ✅ Console shows "Access token received, saving session..."
- ✅ Console shows "User session saved successfully"
- ✅ Delete account works WITHOUT needing to logout/login first
- ✅ User redirected to login after deletion

---

## Test 2: Signup → Use Features → Delete Account ✅

### Steps:
1. [ ] Complete signup and OTP verification (steps 1-7 from Test 1)
2. [ ] Navigate to Home screen
3. [ ] Try to create a new scenario
4. [ ] Try to change password
5. [ ] Try to edit profile
6. [ ] Go to Security → Delete Account
7. [ ] **Expected:** All features work, delete account succeeds ✅

### Success Criteria:
- ✅ Can create scenarios without login errors
- ✅ Can change password without token errors
- ✅ Can edit profile without authentication issues
- ✅ Delete account works immediately

---

## Test 3: Signup → Close App → Reopen → Delete Account ✅

### Steps:
1. [ ] Complete signup and OTP verification
2. [ ] Close app completely (swipe away from recent apps)
3. [ ] Reopen app
4. [ ] **Expected:** User is still logged in (goes to Home, not Login)
5. [ ] Navigate to Security → Delete Account
6. [ ] **Expected:** Delete account works ✅

### Success Criteria:
- ✅ User stays logged in after app restart
- ✅ No need to login again
- ✅ Delete account works after app restart

---

## Test 4: Compare with Login Flow ✅

### Steps:
1. [ ] Signup a new account (save credentials)
2. [ ] Complete OTP verification
3. [ ] Go to Security → Logout
4. [ ] Login with same credentials
5. [ ] Go to Security → Delete Account
6. [ ] **Expected:** Both signup and login flows behave identically ✅

### Success Criteria:
- ✅ Signup flow saves tokens (check console)
- ✅ Login flow saves tokens (check console)
- ✅ Both flows allow immediate delete account
- ✅ Consistent behavior

---

## Console Logs to Watch For

### During OTP Verification (Should See):
```
✅ Access token received, saving session...
✅ User session saved successfully
```

### If No Token Returned (Warning):
```
⚠️ No access token in OTP verification response
```

### During Delete Account (Should See):
```
🔷 Starting account deletion...
✅ Access token found: eyJhbGciOiJIUzI1NiIs...
✅ Account deleted successfully!
🗑️ Starting complete data cleanup...
✅ SharedPreferences cleared
✅ GetX controllers cleared
✅ Complete data cleanup finished
🔄 Navigating to login screen...
```

---

## If Tests Fail

### Scenario A: "Please login first" error during delete
**Issue:** Token not saved during signup  
**Check:** Console logs during OTP verification - do you see "saving session"?  
**Fix:** Verify API response contains access token

### Scenario B: "User not found" error during delete
**Issue:** Token invalid or account already deleted  
**Check:** Token should still trigger logout flow (not an error)  
**Expected:** User is logged out and redirected to login

### Scenario C: App crashes or red screen
**Issue:** Import error or null safety issue  
**Check:** Verify imports in `verify_email_controller.dart`  
**Check:** Run `flutter clean && flutter pub get`

---

## Success Indicators ✅

All tests pass if:
- ✅ Tokens are saved immediately after OTP verification
- ✅ Delete account works right after signup (no logout needed)
- ✅ All authenticated features work after signup
- ✅ User session persists across app restarts
- ✅ No token-related errors in any flow

---

## API Response Verification

If needed, add temporary debug logging in `verify_email_controller.dart`:

```dart
final response = await _apiServices.verifyOtp(request);

// Add this debug log
print('🔍 API Response:');
print('   Message: ${response.message}');
print('   Access Token: ${response.accessToken?.substring(0, 20)}...');
print('   Refresh Token: ${response.refreshToken?.substring(0, 20)}...');
print('   User ID: ${response.userId}');
print('   User Name: ${response.userName}');
print('   Email: ${response.email}');
```

This helps verify that tokens are being extracted correctly from the API response.

---

**Ready to Test!** 🚀
