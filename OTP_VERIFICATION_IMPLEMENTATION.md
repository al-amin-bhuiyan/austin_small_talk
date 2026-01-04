# OTP Verification API Integration Summary

## Overview
Implemented complete API integration for user registration and OTP verification following proper OOP principles.

## API Endpoints Implemented

### 1. Registration API
**Endpoint:** `POST http://10.10.7.74:8001/accounts/user/register/`

**Request Body:**
```json
{
  "email": "mdshobuj04111@gmail.com",
  "name": "mdshobuj",
  "password": "123456",
  "password2": "123456",
  "voice": "male",
  "date_of_birth": "2000-02-21"
}
```

**Response:**
```json
{
  "msg": "Registration successful. Please check your email for OTP verification. The OTP will expire in 15 minutes.",
  "email": "mdshobuj04111@gmail.com",
  "expires_in_minutes": 15
}
```

### 2. OTP Verification API
**Endpoint:** `POST http://10.10.7.74:8001/accounts/user/verify-otp/`

**Request Body:**
```json
{
  "email": "ferdos.khurrom@gmail.com",
  "otp": "213584"
}
```

**Response:**
```json
{
  "msg": "OTP verified successfully",
  "data": { ... }
}
```

## Files Created

### 1. `/lib/service/auth/models/verify_otp_request_model.dart`
- Model for OTP verification request
- Contains email and otp fields
- Includes JSON serialization methods

### 2. `/lib/service/auth/models/verify_otp_response_model.dart`
- Model for OTP verification response
- Contains message and data fields
- Handles both 'msg' and 'message' keys from API

## Files Modified

### 1. `/lib/service/auth/models/register_response_model.dart`
**Changes:**
- Updated to match actual API response structure
- Changed from generic success/message/data structure
- Now includes: `message`, `email`, `expiresInMinutes`
- Maps 'msg' key from API to 'message' property

### 2. `/lib/service/auth/api_constant/api_constant.dart`
**Changes:**
- Added `verifyOtp` endpoint constant
- Maintains baseUrl and smallTalk without changes

### 3. `/lib/service/auth/api_service/api_services.dart`
**Changes:**
- Added imports for new models (VerifyOtpRequestModel, VerifyOtpResponseModel)
- Implemented `verifyOtp()` method
- Follows same pattern as registerUser method
- Includes proper error handling and logging

### 4. `/lib/pages/prefered_gender/prefered_gender_controller.dart`
**Changes:**
- Updated `onLoginToAccountPressed()` to pass email from API response
- Uses `extra` parameter in navigation to pass email to VerifyEmailScreen
- Email from RegisterResponseModel is passed to next screen

### 5. `/lib/pages/verify_email/verify_email_controller.dart`
**Changes:**
- Added ApiServices import and instance
- Added VerifyOtpRequestModel import
- Updated `onVerifyPressed()` to call OTP verification API
- Creates VerifyOtpRequestModel with email and OTP
- Calls _apiServices.verifyOtp() method
- Shows API response message in toast

## Data Flow

### Registration Flow:
1. **CreateAccountScreen** → User fills form
2. **CreateAccountController** → Stores data temporarily
3. **PreferredGenderScreen** → User selects voice (male/female)
4. **PreferredGenderController** → Makes registration API call
5. **API Response** → Returns success message, email, expires_in_minutes
6. **Navigation** → Passes email to VerifyEmailScreen via `extra` parameter

### OTP Verification Flow:
1. **VerifyEmailScreen** → Receives email from previous screen
2. **VerifyEmailController** → Displays email in UI
3. **User enters OTP** → 6-digit code
4. **onVerifyPressed()** → Creates VerifyOtpRequestModel
5. **API Call** → POST to verify-otp endpoint
6. **Success** → Shows message, navigates based on flag
   - flag=false → Navigate to verifiedfromverifyemail (signup flow)
   - flag=true → Navigate to createNewPassword (forgot password flow)

## OOP Principles Applied

### 1. Encapsulation
- All API logic encapsulated in ApiServices class
- Models encapsulate data structure and serialization
- Controllers manage their own state

### 2. Single Responsibility
- Models: Only handle data structure and serialization
- ApiServices: Only handle API communication
- Controllers: Only handle business logic and state management

### 3. Separation of Concerns
- API constants separated in ApiConstant class
- Request/Response models separated by functionality
- Controllers don't directly handle HTTP requests

### 4. Dependency Injection
- ApiServices injected into controllers
- GetX used for dependency management

### 5. Error Handling
- Try-catch blocks in all async methods
- User-friendly error messages
- Proper exception propagation

## Key Features

### 1. Email Passing
- Email from registration response automatically passed to verification screen
- Uses go_router's `extra` parameter for data passing
- Email displayed in verification screen message

### 2. API Response Handling
- Flexible JSON parsing with fallback values
- Handles both 'msg' and 'message' keys
- Proper status code checking (200/201)

### 3. Error Messages
- Extracts error messages from API response
- Falls back to generic messages if parsing fails
- Removes "Exception: " prefix for clean display

### 4. Logging
- Request URL logged
- Request body logged
- Response status logged
- Response body logged

## Usage Example

### Register User:
```dart
final request = RegisterRequestModel(
  email: 'user@example.com',
  name: 'John Doe',
  password: '123456',
  password2: '123456',
  voice: 'male',
  dateOfBirth: '2000-01-01',
);

final response = await _apiServices.registerUser(request);
// response.email → 'user@example.com'
// response.message → 'Registration successful...'
// response.expiresInMinutes → 15
```

### Verify OTP:
```dart
final request = VerifyOtpRequestModel(
  email: 'user@example.com',
  otp: '123456',
);

final response = await _apiServices.verifyOtp(request);
// response.message → 'OTP verified successfully'
```

## Testing Checklist

- [x] Register user with male voice
- [x] Register user with female voice
- [x] Email passed to verification screen
- [x] OTP verification API integration
- [x] Success message display
- [x] Error handling for invalid OTP
- [x] Error handling for expired OTP
- [x] Network error handling
- [x] Navigation based on flag value

## Notes

- Base URL and smallTalk constants remain unchanged
- All HTTP requests use proper headers (Content-Type, Accept)
- Print statements included for debugging
- Proper cleanup in controller's onClose method
- Resend OTP functionality ready for API integration
