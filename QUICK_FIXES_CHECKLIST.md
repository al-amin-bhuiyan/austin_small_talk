# Quick Fixes Checklist - Austin Small Talk

## 🔴 CRITICAL - Fix Today

### 1. Security: Password Storage
**File:** `lib/data/global/shared_preference.dart`

**Current (INSECURE):**
```dart
await instance.setString(_keyPassword, password); // ❌ Plain text!
```

**Action:**
```bash
flutter pub add flutter_secure_storage
```

**Fix:** Create `lib/data/secure_storage.dart`

---

### 2. Remove Development Dependencies from Production
**File:** `pubspec.yaml`

**Move to dev_dependencies:**
```yaml
dev_dependencies:
  device_preview: ^1.1.0  # Move from dependencies
```

**In main.dart:** Remove or comment out DevicePreview wrapper

---

## 🟡 HIGH PRIORITY - This Week

### 3. Create Proper Logging System
**Create:** `lib/utils/logger/app_logger.dart`

Replace all `print()` statements with proper logging

---

### 4. Fix Empty Files
**Delete or implement:**
- `lib/utils/static_string/static_string.dart` - EMPTY
- `lib/helper/general_error/general_error.dart` - EMPTY  
- `lib/global/model/error_response.dart` - EMPTY

---

### 5. Fix AppColors Naming
**File:** `lib/utils/app_colors/app_colors.dart`

**Current:**
```dart
static const Color profile_item_background = Color(0x4C464646); // ❌
static const Color deepblue = Color(0xFF1E90FF); // ❌
```

**Fix to:**
```dart
static const Color profileItemBackground = Color(0x4C464646); // ✅
static const Color deepBlue = Color(0xFF1E90FF); // ✅
```

---

### 6. Rename Folders to snake_case
**Current:**
```
lib/pages/profile/ProfileSupportandHelp/
lib/pages/profile/ProfileSupportandHelp/FAQs/
```

**Fix to:**
```
lib/pages/profile/profile_support_and_help/
lib/pages/profile/profile_support_and_help/faqs/
```

---

### 7. Fix Duplicate Controller Registration
**File:** `lib/core/dependency/dependency.dart`

**Issue:** VoiceChatController registered twice

**Search for:**
```dart
Get.lazyPut<VoiceChatController>
```

**Action:** Keep only one instance

---

### 8. Complete or Remove TODOs
**Found 17 TODO comments**

**Action:** For each TODO:
- Implement it, OR
- Create a ticket, OR
- Remove if not needed

**Files with TODOs:**
- profile_security_controller.dart (3)
- subscription_controller.dart (3)
- login_or_sign_up_controller.dart (1)
- And more...

---

## 🟢 MEDIUM PRIORITY - Next Sprint

### 9. Create Constants Files

**Create:** `lib/utils/app_constants/app_strings.dart`
```dart
class AppStrings {
  AppStrings._();
  
  // App
  static const String appName = 'Small Talk';
  static const String appTagline = 'Improve your real-life\ncommunication skills';
  
  // Auth
  static const String login = 'Log in or signup';
  static const String emailHint = 'name@example.com';
  
  // Errors
  static const String noInternet = 'No internet connection';
}
```

**Create:** `lib/utils/app_constants/app_dimensions.dart`
```dart
class Spacing {
  Spacing._();
  
  static const double tiny = 4;
  static const double small = 8;
  static const double medium = 16;
  static const double large = 24;
  static const double extraLarge = 32;
}
```

---

### 10. Split api_services.dart

**Current:** 1771 lines in one file

**Action:** Split into:
```
lib/service/
├── auth/
│   ├── auth_api_service.dart
│   └── token_api_service.dart
├── chat/
│   ├── chat_api_service.dart
│   └── session_api_service.dart
├── user/
│   ├── profile_api_service.dart
│   └── scenario_api_service.dart
└── base_api_service.dart
```

---

### 11. Implement Custom Exceptions

**Create:** `lib/core/exceptions/app_exceptions.dart`
```dart
class AppException implements Exception {
  final String message;
  final String? userFriendlyMessage;
  
  AppException(this.message, {this.userFriendlyMessage});
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message,
    userFriendlyMessage: 'No internet connection');
}

class ApiException extends AppException {
  final int? statusCode;
  ApiException(String message, {this.statusCode}) : super(message);
}
```

---

### 12. Add Unit Tests

**Create test structure:**
```
test/
├── controllers/
│   ├── home_controller_test.dart
│   ├── login_controller_test.dart
│   └── voice_chat_controller_test.dart
├── services/
│   └── api_services_test.dart
└── utils/
    └── validators_test.dart
```

**Add to pubspec.yaml:**
```yaml
dev_dependencies:
  mocktail: ^1.0.0
```

---

## 🔵 LOW PRIORITY - Backlog

### 13. Environment Configuration
Create `.env` files for different environments

### 14. Dark Theme
Implement dark theme support

### 15. Localization
Add multi-language support with flutter_localizations

### 16. Analytics
Integrate Firebase Analytics or similar

### 17. Error Monitoring
Add Sentry or Crashlytics

---

## Quick Command Reference

### Fix Imports
```bash
flutter pub run import_sorter:main
```

### Format Code
```bash
dart format lib/ --line-length 100
```

### Analyze Code
```bash
flutter analyze
```

### Run Tests
```bash
flutter test --coverage
```

### Clean Build
```bash
flutter clean && flutter pub get
```

---

## Files Requiring Immediate Attention

1. ❌ `lib/data/global/shared_preference.dart` - Security issue
2. ⚠️ `lib/service/auth/api_service/api_services.dart` - Too large (1771 lines)
3. ⚠️ `lib/utils/app_colors/app_colors.dart` - Naming inconsistency
4. ⚠️ `lib/core/dependency/dependency.dart` - Duplicate registration
5. ⚠️ `pubspec.yaml` - Dev tool in production dependencies

---

## Estimated Time Investment

| Priority | Tasks | Estimated Time |
|----------|-------|----------------|
| 🔴 Critical | 2 tasks | 4-6 hours |
| 🟡 High | 6 tasks | 2-3 days |
| 🟢 Medium | 5 tasks | 1 week |
| 🔵 Low | 5 tasks | 2-3 weeks |

**Total:** ~4-5 weeks for complete cleanup

---

## Progress Tracking

- [ ] Critical fixes completed
- [ ] High priority fixes completed
- [ ] Medium priority fixes completed
- [ ] Low priority items addressed
- [ ] Code review passed
- [ ] All tests passing
- [ ] Documentation updated

---

**Created:** January 27, 2026  
**Last Updated:** January 27, 2026
