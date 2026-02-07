# Login API Base URL and Port Configuration

## 📍 Current Configuration

### Base URL and Port
```dart
static const String baseUrl = 'http://10.10.7.74:8001/';
```

**Components:**
- **Protocol**: `http://` (not HTTPS)
- **IP Address**: `10.10.7.74` (Local network IP)
- **Port**: `8001`
- **Trailing slash**: `/` (included)

### Login Endpoint
```dart
static const String login = '${smallTalk}accounts/user/login/';
```

**Full URL Resolution:**
```
http://10.10.7.74:8001/accounts/user/login/
```

**Breakdown:**
- `baseUrl` = `http://10.10.7.74:8001/`
- `smallTalk` = `${baseUrl}` = `http://10.10.7.74:8001/`
- `login` = `${smallTalk}accounts/user/login/` = `http://10.10.7.74:8001/accounts/user/login/`

## 🔍 All API Endpoints

### Authentication APIs (Port 8001)
| Endpoint | Full URL |
|----------|----------|
| Register | `http://10.10.7.74:8001/accounts/user/register/` |
| Login | `http://10.10.7.74:8001/accounts/user/login/` |
| Verify OTP | `http://10.10.7.74:8001/accounts/user/verify-otp/` |
| Resend OTP | `http://10.10.7.74:8001/accounts/user/resend-otp/` |
| Forgot Password | `http://10.10.7.74:8001/accounts/user/send-reset-password-email/` |
| Reset Password OTP | `http://10.10.7.74:8001/accounts/user/reset-password-otp/` |
| Set New Password | `http://10.10.7.74:8001/accounts/user/set-new-password/` |
| Change Password | `http://10.10.7.74:8001/accounts/user/change-password/` |
| User Profile | `http://10.10.7.74:8001/accounts/user/profile/` |
| Delete Account | `http://10.10.7.74:8001/accounts/user/delete-account/` |
| Google Auth | `http://10.10.7.74:8001/accounts/user/google-auth/` |
| Refresh Token | `http://10.10.7.74:8001/accounts/user/token/refresh/` |
| Verify Token | `http://10.10.7.74:8001/accounts/user/token/verify/` |

### Core APIs (Port 8001)
| Endpoint | Full URL |
|----------|----------|
| Daily Scenarios | `http://10.10.7.74:8001/core/chat/daily-scenarios/` |
| Create Scenario | `http://10.10.7.74:8001/core/scenarios/` |
| Chat Message | `http://10.10.7.74:8001/core/chat/message/` |
| Chat Sessions | `http://10.10.7.74:8001/core/chat/sessions/` |
| Chat History | `http://10.10.7.74:8001/core/chat/sessions/history/` |

### WebSocket API (Different Server - Port 8000!)
| Endpoint | Full URL |
|----------|----------|
| Voice Chat WebSocket | `ws://10.10.7.114:8000/ws/chat` |

⚠️ **Important**: Voice chat uses a **different server** with a different IP (`10.10.7.114`) and port (`8000`)

## 🧪 Test the Login API

### Using cURL (Command Line)
```bash
curl -X POST http://10.10.7.74:8001/accounts/user/login/ \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"email":"ferdos.khurrom@gmail.com","password":"123456"}'
```

### Using PowerShell
```powershell
Invoke-WebRequest -Uri "http://10.10.7.74:8001/accounts/user/login/" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"; "Accept"="application/json"} `
  -Body '{"email":"ferdos.khurrom@gmail.com","password":"123456"}'
```

### Expected Response (200 OK)
```json
{
  "message": "Login successful",
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user_id": 1,
  "user_name": "Sophia Adams",
  "email": "ferdos.khurrom@gmail.com"
}
```

## 🚨 Troubleshooting

### Issue: API Not Responding

#### 1. Check if Server is Running
```bash
# Test base URL
curl http://10.10.7.74:8001/

# Or in browser
http://10.10.7.74:8001/
```

**Expected**: Some response (even an error page means server is running)
**If no response**: Server is not running or IP/port is wrong

#### 2. Verify IP Address
```bash
# Windows - Check server's IP
ipconfig

# Look for IPv4 Address under your network adapter
```

**Common Issues:**
- ✅ Server running on different IP
- ✅ Port already in use
- ✅ Firewall blocking connection
- ✅ Server not started

#### 3. Check Port
The server might be running on a different port. Common Django ports:
- `8000` - Default Django development server
- `8001` - Custom port (currently configured)
- `8080` - Alternative web port

#### 4. Test with Localhost (if on same machine)
```dart
static const String baseUrl = 'http://localhost:8001/';
// or
static const String baseUrl = 'http://127.0.0.1:8001/';
```

#### 5. Check Network Connection
If testing from Android emulator:
- ✅ Use `10.0.2.2` instead of `localhost`
- ✅ Use actual IP for physical device testing

### Issue: Connection Refused

**Possible Causes:**
1. **Django server not running**
   ```bash
   # Start Django server
   python manage.py runserver 0.0.0.0:8001
   ```

2. **Wrong IP/Port combination**
   - Verify server is actually listening on `10.10.7.74:8001`
   - Check Django console output when starting server

3. **Firewall blocking**
   - Windows Firewall might block incoming connections
   - Allow port 8001 through firewall

### Issue: Timeout

**Possible Causes:**
1. **Network unreachable**
   - Device and server on different networks
   - VPN interference

2. **Server too slow**
   - Increase timeout in http client
   - Check server logs for slow queries

## 📝 How to Change Base URL

If you need to update the API server address:

**File**: `lib/service/auth/api_constant/api_constant.dart`

```dart
class ApiConstant {
  // Option 1: Development (local network)
  static const String baseUrl = 'http://10.10.7.74:8001/';
  
  // Option 2: Localhost (same machine)
  // static const String baseUrl = 'http://localhost:8001/';
  
  // Option 3: Android Emulator (localhost)
  // static const String baseUrl = 'http://10.0.2.2:8001/';
  
  // Option 4: Production server
  // static const String baseUrl = 'https://api.yourapp.com/';
  
  // Option 5: Staging server
  // static const String baseUrl = 'https://staging-api.yourapp.com/';
  
  static const String smallTalk = '${baseUrl}';
  // ...rest of the code
}
```

## 🔧 Debug Mode

The API service already logs all requests. You can see them in console:

```dart
print('API Request: POST ${ApiConstant.login}');
print('Request Body: ${jsonEncode(request.toJson())}');
print('Response Status: ${response.statusCode}');
print('Response Body: ${response.body}');
```

**Example Console Output:**
```
API Request: POST http://10.10.7.74:8001/accounts/user/login/
Request Body: {"email":"ferdos.khurrom@gmail.com","password":"123456"}
Response Status: 200
Response Body: {"message":"Login successful","access":"..."}
```

## 📊 API Service Implementation

The login API call in `api_services.dart`:

```dart
Future<LoginResponseModel> loginUser(LoginRequestModel request) async {
  try {
    final response = await http.post(
      Uri.parse(ApiConstant.login),  // ← Uses the URL from api_constant.dart
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    print('API Request: POST ${ApiConstant.login}');
    print('Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return LoginResponseModel.fromJson(jsonData);
    }
    // Error handling...
  } catch (e) {
    // Network error handling...
  }
}
```

## ✅ Verification Checklist

To ensure API is configured correctly:

- [ ] Server is running on `10.10.7.74:8001`
- [ ] Can access `http://10.10.7.74:8001/` in browser
- [ ] Can reach login endpoint with curl/Postman
- [ ] Flutter app shows API request in console
- [ ] Response status is 200/201 for success
- [ ] Error messages are clear and helpful

## 🎯 Current Status

**Base URL**: `http://10.10.7.74:8001/`
**Login Endpoint**: `http://10.10.7.74:8001/accounts/user/login/`
**Method**: POST
**Headers**: 
- `Content-Type: application/json`
- `Accept: application/json`

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Expected Response** (200/201):
```json
{
  "message": "Login successful",
  "access": "JWT_ACCESS_TOKEN",
  "refresh": "JWT_REFRESH_TOKEN",
  "user_id": 1,
  "user_name": "User Name",
  "email": "user@example.com"
}
```

---

## 🔑 Summary

The login API is configured to hit:
- **Base URL**: `http://10.10.7.74:8001/`
- **Full Login URL**: `http://10.10.7.74:8001/accounts/user/login/`

This is a **local network server** (not localhost, not production).

Make sure the Django backend server is running on that exact IP and port!
