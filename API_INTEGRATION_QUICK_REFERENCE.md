# Quick Reference: Registration & OTP Verification Flow

## API Integration Status: ✅ COMPLETE

## Flow Summary

### 1. User Registration
```
CreateAccountScreen → PreferredGenderScreen → API Call → VerifyEmailScreen
```

### 2. OTP Verification
```
VerifyEmailScreen → Enter OTP → API Call → Success/Error
```

## Implementation Details

### Models Created
1. ✅ `VerifyOtpRequestModel` - OTP verification request
2. ✅ `VerifyOtpResponseModel` - OTP verification response
3. ✅ `RegisterResponseModel` - Updated to match API response

### API Endpoints
1. ✅ Registration: `http://10.10.7.74:8001/accounts/user/register/`
2. ✅ OTP Verification: `http://10.10.7.74:8001/accounts/user/verify-otp/`

### Key Features
- ✅ Email automatically passed from registration to verification screen
- ✅ Proper OOP structure with models and services
- ✅ Error handling with user-friendly messages
- ✅ API logging for debugging
- ✅ Loading states for better UX

## Code References

### To Register User:
**File:** `lib/pages/prefered_gender/prefered_gender_controller.dart`
**Method:** `onLoginToAccountPressed()`

```dart
final request = RegisterRequestModel(
  email: email,
  name: name,
  password: password,
  password2: password,
  voice: selectedGender.value, // 'male' or 'female'
  dateOfBirth: dateOfBirth,
);

final response = await _apiServices.registerUser(request);
// response.email, response.message, response.expiresInMinutes
```

### To Verify OTP:
**File:** `lib/pages/verify_email/verify_email_controller.dart`
**Method:** `onVerifyPressed()`

```dart
final request = VerifyOtpRequestModel(
  email: email.value,
  otp: otpCode,
);

final response = await _apiServices.verifyOtp(request);
// response.message, response.data
```

## API Request/Response Examples

### Registration Request:
```json
{
  "email": "user@example.com",
  "name": "username",
  "password": "123456",
  "password2": "123456",
  "voice": "male",
  "date_of_birth": "2000-02-21"
}
```

### Registration Response:
```json
{
  "msg": "Registration successful. Please check your email for OTP verification. The OTP will expire in 15 minutes.",
  "email": "user@example.com",
  "expires_in_minutes": 15
}
```

### OTP Verification Request:
```json
{
  "email": "user@example.com",
  "otp": "123456"
}
```

### OTP Verification Response:
```json
{
  "msg": "OTP verified successfully",
  "data": { }
}
```

## Navigation Flow

### Signup Flow (flag=false):
1. CreateAccount
2. PreferredGender → **API: Register User**
3. VerifyEmail (receives email) → **API: Verify OTP**
4. VerifiedScreen

### Forgot Password Flow (flag=true):
1. ForgotPassword
2. VerifyEmail → **API: Verify OTP**
3. CreateNewPassword

## Error Handling

All API calls include:
- Network error handling
- Invalid response handling
- User-friendly error messages
- Proper exception propagation

## Testing Commands

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Check for errors
flutter analyze
```

## Important Notes

1. **Email Passing**: Email is passed via `extra` parameter in go_router
2. **Flag Parameter**: Used to determine navigation path after OTP verification
3. **Voice Selection**: Male/Female selection determines the voice value in API
4. **OTP Format**: 6-digit numeric code
5. **API Logging**: All requests/responses logged to console for debugging

## Files to Review for Understanding

1. `lib/service/auth/models/` - All data models
2. `lib/service/auth/api_service/api_services.dart` - API methods
3. `lib/service/auth/api_constant/api_constant.dart` - API endpoints
4. `lib/pages/prefered_gender/prefered_gender_controller.dart` - Registration logic
5. `lib/pages/verify_email/verify_email_controller.dart` - OTP verification logic

## Status: READY FOR TESTING ✅
