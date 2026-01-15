# Google Sign-In - Quick Reference ✅

## How to Use in UI

```dart
ElevatedButton(
  onPressed: controller.isLoading.value
      ? null
      : () => controller.onGoogleSignInPressed(context),
  child: Text('Sign in with Google'),
)
```

**Important:** Pass `context` to the method!

## What Happens When User Clicks

1. ✅ Google account picker appears
2. ✅ User selects account
3. ✅ Google ID token obtained
4. ✅ Token sent to backend: `POST /accounts/user/google-auth/`
5. ✅ Backend returns access token + user info
6. ✅ Session saved to SharedPreferences
7. ✅ User navigated to home screen

## Files Added

1. `lib/service/auth/models/google_auth_request_model.dart`
2. `lib/service/auth/models/google_auth_response_model.dart`
3. `lib/utils/google_sign_in_wrapper.dart`
4. `lib/pages/login_or_sign_up/google_auth_controller.dart`

## Files Modified

1. `pubspec.yaml` → Added `google_sign_in: 6.2.1`
2. `lib/service/auth/api_constant/api_constant.dart` → Added endpoint
3. `lib/service/auth/api_service/api_services.dart` → Added `googleAuth()` method
4. `lib/pages/login_or_sign_up/login_or_sign_up_controller.dart` → Added `onGoogleSignInPressed()`
5. `lib/core/dependency/dependency.dart` → Registered controller

## Backend API

**Endpoint:** `POST {{small_talk}}accounts/user/google-auth/`

**Request:**
```json
{
  "google_token": "eyJhbGciOiJSUzI1NiIs..."
}
```

**Response:**
```json
{
  "message": "Google sign-in successful",
  "access": "eyJhbGc...",
  "refresh": "eyJhbGc...",
  "user_id": 123,
  "user_name": "John Doe",
  "email": "john@example.com"
}
```

## Configuration Needed

### Android
Add to `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        resValue "string", "default_web_client_id", "YOUR_CLIENT_ID.apps.googleusercontent.com"
    }
}
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

### Get OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create/select project
3. Enable Google Sign-In API
4. Create OAuth 2.0 credentials
5. Add SHA-1 fingerprint for Android
6. Download and configure

## Testing

```bash
# Run the app
flutter run

# Test sign-in
# 1. Click "Sign in with Google"
# 2. Select account
# 3. Check console logs
# 4. Verify navigation to home
```

## Troubleshooting

### "Sign-in canceled"
→ User dismissed Google picker (normal)

### "Failed to get authentication token"
→ Google Sign-In configuration issue, check OAuth setup

### "Google authentication failed"
→ Backend issue, check API endpoint and token validation

### No Google picker shown
→ Check google-services.json (Android) or GoogleService-Info.plist (iOS)

## Architecture Pattern

Follows existing project structure:
- ✅ Models in `lib/service/auth/models/`
- ✅ API methods in `api_services.dart`
- ✅ Constants in `api_constant.dart`
- ✅ Controller logic in existing `login_or_sign_up_controller.dart`
- ✅ Session management via `SharedPreferencesUtil`

## Success Indicators

✅ Google account picker appears  
✅ Console shows: "✅ Google Sign-In successful"  
✅ Console shows: "✅ Backend authentication successful!"  
✅ Console shows: "✅ User session saved successfully"  
✅ User navigated to home screen  
✅ User stays logged in after app restart  

---

**Status:** ✅ READY TO USE
**Next Step:** Configure OAuth credentials and test
