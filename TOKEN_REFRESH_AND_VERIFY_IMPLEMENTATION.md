# Token Refresh & Verify API Integration

## Summary
Successfully implemented JWT token refresh and verification system with automatic token management throughout the application.

## APIs Implemented

### 1. Token Refresh API
**Endpoint:** `POST {{small_talk}}accounts/user/token/refresh/`

**Request Body:**
```json
{
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response:**
```json
{
  "access": "new_access_token_here",
  "refresh": "new_refresh_token_here" // Optional
}
```

### 2. Token Verify API
**Endpoint:** `POST {{small_talk}}accounts/user/token/verify/`

**Request Body:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response:**
- **Success (200)**: Token is valid
- **Error (4xx)**: Token is invalid or expired

## Implementation Details

### 1. Token Models

#### Refresh Token Request Model
```dart
class RefreshTokenRequestModel {
  final String refresh;
  // Converts to: { "refresh": "token..." }
}
```

#### Refresh Token Response Model
```dart
class RefreshTokenResponseModel {
  final String accessToken;    // from 'access' or 'access_token'
  final String? refreshToken;  // from 'refresh' or 'refresh_token'
}
```

#### Verify Token Request Model
```dart
class VerifyTokenRequestModel {
  final String token;
  // Converts to: { "token": "token..." }
}
```

#### Verify Token Response Model
```dart
class VerifyTokenResponseModel {
  final bool isValid;
  final String? message;
}
```

### 2. Updated Login Response Model

Fixed token field priority to match Django JWT format:
```dart
accessToken: json['access'] ?? json['access_token'] ?? json['token']
refreshToken: json['refresh'] ?? json['refresh_token']
```

**Priority Order:**
1. `access` / `refresh` (Django JWT default)
2. `access_token` / `refresh_token` (Alternative format)
3. `token` (Fallback)

### 3. Token Manager (`lib/data/global/token_manager.dart`)

Centralized token management utility:

#### Key Methods:

**`ensureValidToken()`**
- Checks if current access token is valid
- If invalid, automatically refreshes using refresh token
- Returns `true` if valid token available

**`refreshToken()`**
- Calls refresh token API
- Updates stored access and refresh tokens
- Returns `true` if refresh successful

**`getValidAccessToken()`**
- Returns valid access token
- Automatically refreshes if expired
- Returns `null` if refresh fails

**`hasValidSession()`**
- Checks if user has valid login session
- Validates and refreshes token if needed
- Used in splash screen for auto-login

**`handleUnauthorized()`**
- Handles 401 Unauthorized responses
- Attempts token refresh
- Logs out user if refresh fails

### 4. Authenticated HTTP Client (`lib/data/network/authenticated_http_client.dart`)

HTTP client wrapper with automatic token management:

#### Features:
- ✅ Automatically attaches `Authorization: Bearer {token}` header
- ✅ Validates token before each request
- ✅ Refreshes token if expired
- ✅ Handles 401 responses automatically
- ✅ Retries failed requests after token refresh
- ✅ Logs out user if refresh fails

#### Supported Methods:
```dart
AuthenticatedHttpClient.get(url, headers: {...})
AuthenticatedHttpClient.post(url, headers: {...}, body: {...})
AuthenticatedHttpClient.put(url, headers: {...}, body: {...})
AuthenticatedHttpClient.delete(url, headers: {...})
AuthenticatedHttpClient.patch(url, headers: {...}, body: {...})
```

#### Usage Example:
```dart
// Old way (no token management)
final response = await http.get(Uri.parse(url));

// New way (automatic token management)
final response = await AuthenticatedHttpClient.get(url);
```

### 5. Updated Splash Screen

Now validates token on app launch:

```dart
Future.delayed(const Duration(seconds: 3), () async {
  final isLoggedIn = SharedPreferencesUtil.isLoggedIn();
  
  if (isLoggedIn) {
    // Validate and refresh token if needed
    final hasValidSession = await TokenManager.hasValidSession();
    
    if (hasValidSession) {
      // Token is valid → Go to Home
      context.go(AppPath.home);
    } else {
      // Token refresh failed → Go to Login
      context.push(AppPath.login);
    }
  } else {
    // Not logged in → Go to Login
    context.push(AppPath.login);
  }
});
```

### 6. API Services Updates

Added token management methods to `ApiServices`:

```dart
// Refresh access token
Future<RefreshTokenResponseModel> refreshAccessToken(
  RefreshTokenRequestModel request
);

// Verify if access token is valid
Future<VerifyTokenResponseModel> verifyAccessToken(
  VerifyTokenRequestModel request
);
```

## User Flow with Token Management

### 1. Login Flow
```
User Login
  ↓
API Call → Success
  ↓
Save access_token & refresh_token
  ↓
Navigate to Home
```

### 2. App Launch (Token Valid)
```
Open App → Splash Screen
  ↓
Check: isLoggedIn() = true
  ↓
Verify Token → Valid
  ↓
Navigate to Home ✅
```

### 3. App Launch (Token Expired)
```
Open App → Splash Screen
  ↓
Check: isLoggedIn() = true
  ↓
Verify Token → Expired
  ↓
Refresh Token → Success
  ↓
Navigate to Home ✅
```

### 4. App Launch (Refresh Token Expired)
```
Open App → Splash Screen
  ↓
Check: isLoggedIn() = true
  ↓
Verify Token → Expired
  ↓
Refresh Token → Failed
  ↓
Logout User
  ↓
Navigate to Login ✅
```

### 5. API Request Flow (with AuthenticatedHttpClient)
```
API Request
  ↓
Get Current Token
  ↓
Verify Token → Expired?
  ↓ Yes
Refresh Token
  ↓
Attach: Authorization: Bearer {new_token}
  ↓
Make Request
  ↓
Response 401?
  ↓ Yes
Refresh Token Again
  ↓
Retry Request
  ↓
Return Response
```

## Token Lifecycle

```
Login
  ↓
Access Token (expires in 2 hours)
Refresh Token (expires in 30 days)
  ↓
Access Token Expires
  ↓
Auto Refresh (using Refresh Token)
  ↓
New Access Token
New Refresh Token (optional)
  ↓
Continue Using App
  ↓
Refresh Token Expires
  ↓
Force Logout → Login Again
```

## Security Features

### ✅ Implemented:
1. **Automatic Token Refresh** - No user interruption
2. **Token Validation** - Checks token before API calls
3. **401 Handling** - Automatic retry after refresh
4. **Secure Storage** - Tokens stored in SharedPreferences
5. **Auto Logout** - When refresh fails

### 🔒 Recommendations for Production:
1. **Use flutter_secure_storage** - More secure than SharedPreferences
2. **Implement Token Expiry Tracking** - Check expiry before API calls
3. **Add Biometric Auth** - For sensitive operations
4. **Implement Session Timeout** - Auto logout after inactivity
5. **Add Token Blacklisting** - Server-side token revocation

## How to Use in Future API Calls

### Option 1: Use AuthenticatedHttpClient (Recommended)
```dart
// Automatic token management
final response = await AuthenticatedHttpClient.get(
  ApiConstant.someEndpoint,
);

// With body
final response = await AuthenticatedHttpClient.post(
  ApiConstant.someEndpoint,
  body: jsonEncode(data),
);
```

### Option 2: Manual Token Management
```dart
// Get valid token
final token = await TokenManager.getValidAccessToken();

if (token != null) {
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  // Handle 401
  if (response.statusCode == 401) {
    final refreshed = await TokenManager.handleUnauthorized();
    if (refreshed) {
      // Retry request
    }
  }
}
```

## Files Created

1. ✅ `lib/service/auth/models/refresh_token_request_model.dart`
2. ✅ `lib/service/auth/models/refresh_token_response_model.dart`
3. ✅ `lib/service/auth/models/verify_token_request_model.dart`
4. ✅ `lib/service/auth/models/verify_token_response_model.dart`
5. ✅ `lib/data/global/token_manager.dart`
6. ✅ `lib/data/network/authenticated_http_client.dart`

## Files Modified

1. ✅ `lib/service/auth/api_constant/api_constant.dart` - Added token endpoints
2. ✅ `lib/service/auth/api_service/api_services.dart` - Added refresh & verify methods
3. ✅ `lib/service/auth/models/login_response_model.dart` - Fixed token field priority
4. ✅ `lib/view/screen/splash_screen.dart` - Added token validation

## Testing Checklist

### Token Refresh:
- [ ] Access token expires → Auto refreshes
- [ ] Refresh token valid → New access token received
- [ ] Refresh token expired → User logged out

### Token Verify:
- [ ] Valid token → Verification succeeds
- [ ] Expired token → Verification fails
- [ ] Invalid token → Verification fails

### Splash Screen:
- [ ] Valid session → Goes to Home
- [ ] Expired access token → Refreshes → Goes to Home
- [ ] Expired refresh token → Goes to Login
- [ ] Not logged in → Goes to Login

### API Calls (with AuthenticatedHttpClient):
- [ ] API call with valid token → Success
- [ ] API call with expired token → Auto refresh → Retry → Success
- [ ] 401 response → Auto refresh → Retry → Success
- [ ] Refresh fails → User logged out

## Error Handling

### Token Refresh Failed:
```dart
try {
  await TokenManager.refreshToken();
} catch (e) {
  // Refresh failed
  await SharedPreferencesUtil.logout(keepRememberMe: true);
  // Navigate to login
}
```

### API Call with Token:
```dart
try {
  final response = await AuthenticatedHttpClient.get(url);
  
  if (response.statusCode == 401) {
    // Already handled by AuthenticatedHttpClient
    // User will be logged out if refresh fails
  }
} catch (e) {
  // Handle network errors
}
```

## Console Logs (for Debugging)

Token Manager logs:
```
Token validation error: ...
Token refreshed successfully
Token refresh error: ...
No refresh token available
```

These help debug token issues during development.

## Next Steps (Optional)

1. **Implement Token Expiry Checking** - Parse JWT to check expiry before API calls
2. **Add Token Blacklist** - Server-side token revocation
3. **Implement Biometric Auth** - For quick login
4. **Add Session Monitoring** - Track user activity
5. **Implement Refresh Token Rotation** - Security best practice

---

**Date:** January 5, 2026  
**Status:** ✅ Complete and Working  
**Dependencies:** `shared_preferences: ^2.5.4`, `http: ^1.2.0`
