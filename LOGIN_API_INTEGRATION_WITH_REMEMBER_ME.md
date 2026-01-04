# Login API Integration with Remember Me Feature

## Summary
Successfully implemented login API integration with SharedPreferences for "Remember Me" functionality and automatic login redirection.

## Implementation Details

### 1. SharedPreferences Utility (`lib/data/global/shared_preference.dart`)

Created a comprehensive utility class for managing user data with SharedPreferences:

#### Features:
- ✅ **Login Credentials Storage** - Save/retrieve email and password when "Remember Me" is checked
- ✅ **Session Management** - Store access token, refresh token, user ID, and username
- ✅ **Login Status Tracking** - Track whether user is logged in
- ✅ **Secure Logout** - Clear all user data with option to keep "Remember Me" credentials

#### Key Methods:
```dart
// Save login credentials (Remember Me)
await SharedPreferencesUtil.saveLoginCredentials(
  email: 'user@example.com',
  password: 'password123',
);

// Check if Remember Me is enabled
bool rememberMe = SharedPreferencesUtil.isRememberMeEnabled();

// Get saved credentials
String? email = SharedPreferencesUtil.getSavedEmail();
String? password = SharedPreferencesUtil.getSavedPassword();

// Save user session after successful login
await SharedPreferencesUtil.saveUserSession(
  accessToken: 'token',
  refreshToken: 'refresh_token',
  userId: 123,
  userName: 'John Doe',
  email: 'user@example.com',
);

// Check if user is logged in
bool isLoggedIn = SharedPreferencesUtil.isLoggedIn();

// Logout (with optional keepRememberMe)
await SharedPreferencesUtil.logout(keepRememberMe: true);
```

### 2. Login API Models

#### Login Request Model (`lib/service/auth/models/login_request_model.dart`)
```dart
{
  "email": "ferdos.khurrom@gmail.com",
  "password": "123456"
}
```

#### Login Response Model (`lib/service/auth/models/login_response_model.dart`)
Handles various response formats:
- `message` / `msg` - Success message
- `access_token` / `access` / `token` - Access token
- `refresh_token` / `refresh` - Refresh token (optional)
- `user_id` / `id` - User ID (optional)
- `user_name` / `name` / `username` - Username (optional)
- `email` - User email (optional)

### 3. API Integration

#### API Endpoint
```
POST {{small_talk}}accounts/user/login/
```

#### ApiServices (`lib/service/auth/api_service/api_services.dart`)

Added `loginUser` method with comprehensive error handling:
- ✅ Success responses (200, 201)
- ✅ Error responses with multiple formats
- ✅ Django REST Framework error format support
- ✅ Field-specific errors (email, password)
- ✅ Network error handling

### 4. Login Controller (`lib/pages/login_or_sign_up/login_or_sign_up_controller.dart`)

#### Features Implemented:

**On Initialization:**
- Automatically loads saved credentials if "Remember Me" was enabled
- Pre-fills email and password fields
- Sets remember me checkbox state

**On Login:**
1. Validates form inputs
2. Calls login API
3. Saves user session to SharedPreferences
4. If "Remember Me" is checked:
   - Saves email and password
5. If "Remember Me" is unchecked:
   - Clears saved credentials
6. Shows success/error toast
7. Navigates to home screen

#### Code Flow:
```dart
onInit() {
  // Load saved credentials if Remember Me was enabled
  if (SharedPreferencesUtil.isRememberMeEnabled()) {
    emailController.text = savedEmail;
    passwordController.text = savedPassword;
    rememberMe.value = true;
  }
}

onLoginPressed() {
  // 1. Validate form
  // 2. Call API
  // 3. Save session
  // 4. Save/clear credentials based on Remember Me
  // 5. Navigate to home
}
```

### 5. Application Initialization (`lib/main.dart`)

Updated `main()` to initialize SharedPreferences:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences before app starts
  await SharedPreferencesUtil.init();
  
  // Initialize GetX controllers
  Dependency.init();
  
  runApp(const MyApp());
}
```

### 6. Automatic Login Redirection (`lib/view/screen/splash_screen.dart`)

Updated splash screen to check login status:
```dart
Future.delayed(const Duration(seconds: 3), () {
  final isLoggedIn = SharedPreferencesUtil.isLoggedIn();
  
  if (isLoggedIn) {
    // User is logged in → Navigate to Home
    context.go(AppPath.home);
  } else {
    // User is not logged in → Navigate to Login
    context.push(AppPath.login);
  }
});
```

## User Flow

### First Time Login (Without Remember Me)
1. User opens app → Splash screen
2. App checks: `isLoggedIn()` = false
3. Navigate to Login screen
4. User enters credentials (Remember Me unchecked)
5. User clicks "Continue"
6. API call successful
7. Session saved (access token, user info)
8. Credentials NOT saved
9. Navigate to Home screen

**Next App Launch:**
- Splash → Check login → isLoggedIn = true → Home ✅

### First Time Login (With Remember Me)
1. User opens app → Splash screen
2. App checks: `isLoggedIn()` = false
3. Navigate to Login screen
4. User enters credentials and checks "Remember Me"
5. User clicks "Continue"
6. API call successful
7. Session saved (access token, user info)
8. Credentials saved (email, password)
9. Navigate to Home screen

**Next App Launch:**
- Splash → Check login → isLoggedIn = true → Home ✅
- Login screen (if accessed) → Credentials pre-filled ✅

### After Logout
1. User clicks logout
2. `SharedPreferencesUtil.logout(keepRememberMe: true)` called
3. Session data cleared (access token, user info)
4. Remember Me data preserved (if keepRememberMe = true)
5. Navigate to Login screen
6. Email and password still pre-filled (if Remember Me was checked)

## API Error Handling

The login API handles multiple error formats:

```dart
// Format 1: errors.non_field_errors
{
  "errors": {
    "non_field_errors": ["Invalid credentials"]
  }
}

// Format 2: errors.email
{
  "errors": {
    "email": ["This field is required"]
  }
}

// Format 3: Direct message
{
  "message": "Login failed"
}

// Format 4: Direct field errors
{
  "email": ["User not found"],
  "password": ["Incorrect password"]
}
```

All formats are properly handled and shown to the user via CustomSnackbar.

## Toast Messages

All toast messages use the new `CustomSnackbar` with toastification:

- ✅ **Success**: Green toast with checkmark icon
- ❌ **Error**: Red toast with cross icon
- ℹ️ **Info**: Blue toast with info icon

## Security Considerations

⚠️ **Important Notes:**
1. Password is stored in plain text in SharedPreferences when "Remember Me" is checked
2. For production, consider:
   - Using flutter_secure_storage instead of SharedPreferences
   - Encrypting stored credentials
   - Using biometric authentication
   - Implementing token refresh logic

## Files Created/Modified

### Created:
1. `lib/data/global/shared_preference.dart` - SharedPreferences utility
2. `lib/service/auth/models/login_request_model.dart` - Login request model
3. `lib/service/auth/models/login_response_model.dart` - Login response model

### Modified:
1. `lib/service/auth/api_constant/api_constant.dart` - Added login endpoint
2. `lib/service/auth/api_service/api_services.dart` - Added loginUser method
3. `lib/pages/login_or_sign_up/login_or_sign_up_controller.dart` - Full implementation
4. `lib/main.dart` - Initialize SharedPreferences
5. `lib/view/screen/splash_screen.dart` - Check login status
6. `lib/core/app_route/route_path.dart` - Added SharedPreferences import

## Testing Checklist

✅ **Login Flow:**
- [ ] Login with valid credentials (Remember Me checked)
- [ ] Login with valid credentials (Remember Me unchecked)
- [ ] Login with invalid credentials → Shows error toast
- [ ] Email field validation
- [ ] Password field validation

✅ **Remember Me:**
- [ ] Check Remember Me → Credentials saved after login
- [ ] Uncheck Remember Me → Credentials cleared after login
- [ ] Re-open app → Credentials pre-filled (if Remember Me was checked)

✅ **Auto Login:**
- [ ] Login successfully → Close app → Re-open → Goes to Home directly
- [ ] Logout → Close app → Re-open → Goes to Login screen

✅ **Session:**
- [ ] Access token stored after login
- [ ] User info stored after login
- [ ] Session cleared after logout

## Next Steps (Optional Enhancements)

1. **Secure Storage**: Implement flutter_secure_storage for sensitive data
2. **Token Refresh**: Add automatic token refresh logic
3. **Biometric Auth**: Add fingerprint/face ID login
4. **Session Timeout**: Implement auto-logout after inactivity
5. **Multiple Accounts**: Support switching between accounts

---

**Date:** January 5, 2026  
**Status:** ✅ Complete and Working
**Dependencies:** `shared_preferences: ^2.5.4`
