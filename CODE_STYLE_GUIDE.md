# Code Style Guide - Austin Small Talk

This document contains the coding standards and patterns used in this project.

---

## 1. File & Folder Naming

### ✅ Correct
```
lib/pages/home/home.dart
lib/pages/home/home_controller.dart
lib/utils/app_colors/app_colors.dart
lib/service/auth/auth_service.dart
```

### ❌ Incorrect
```
lib/pages/ProfileSupportandHelp/  # Should be: profile_support_and_help/
lib/pages/FAQs/                   # Should be: faqs/
lib/Utils/AppColors.dart          # Should be: utils/app_colors/app_colors.dart
```

**Rule:** Always use `snake_case` for files and folders

---

## 2. Class Naming

### ✅ Correct
```dart
class HomeController extends GetxController { }
class ApiServices { }
class UserProfileResponseModel { }
class CustomTextField extends StatefulWidget { }
```

### ❌ Incorrect
```dart
class homeController { }           // Should be: HomeController
class api_services { }             // Should be: ApiServices
class userprofileresponse { }      // Should be: UserProfileResponseModel
```

**Rule:** Always use `PascalCase` for class names

---

## 3. Variable & Method Naming

### ✅ Correct
```dart
// Variables
final RxBool isLoading = false.obs;
final String userName = 'John';
final Color primaryColor = Colors.blue;

// Methods
void fetchUserProfile() { }
Future<void> handleLogin() async { }
Widget buildHeader() { }

// Private members
final ApiServices _apiServices = ApiServices();
void _initializeWebSocket() { }
```

### ❌ Incorrect
```dart
// Variables
final RxBool IsLoading = false.obs;     // Should be: isLoading
final String user_name = 'John';        // Should be: userName
final Color PrimaryColor = Colors.blue;  // Should be: primaryColor

// Constants (special case)
static const Color white_color = Color(0xFFFFFFFF);  // Should be: whiteColor or WHITE_COLOR

// Methods
void FetchUserProfile() { }  // Should be: fetchUserProfile
void fetch_profile() { }     // Should be: fetchProfile
```

**Rule:** Use `camelCase` for variables and methods, `UPPER_SNAKE_CASE` for constants

---

## 4. Constants

### ✅ Correct
```dart
class AppColors {
  AppColors._(); // Private constructor prevents instantiation
  
  // Option 1: Semantic constants (preferred)
  static const Color primary = Color(0xFF0A84FF);
  static const Color secondary = Color(0xFF1E90FF);
  static const Color background = Color(0xFF000000);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  
  // Option 2: Traditional constants
  static const Color PRIMARY_COLOR = Color(0xFF0A84FF);
  static const Color SECONDARY_COLOR = Color(0xFF1E90FF);
}

class AppStrings {
  AppStrings._();
  
  static const String appName = 'Small Talk';
  static const String welcomeMessage = 'Welcome back!';
}

class Spacing {
  Spacing._();
  
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
}
```

### ❌ Incorrect
```dart
class AppColors {
  // Missing private constructor - can be instantiated
  
  static const Color white_color = Color(0xFFFFFFFF);  // Inconsistent naming
  static const Color deepblue = Color(0xFF1E90FF);     // Inconsistent naming
  static const Color logout = Color(0xFF3C3C3C);       // Unclear purpose
}
```

---

## 5. Widget Structure

### ✅ Correct Pattern
```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(controller),
            _buildContent(controller),
            _buildFooter(controller),
          ],
        ),
      ),
    );
  }

  // Private widget builders
  Widget _buildHeader(HomeController controller) {
    return Container(
      child: Text('Header'),
    );
  }

  Widget _buildContent(HomeController controller) {
    return Expanded(
      child: ListView.builder(
        itemCount: controller.items.length,
        itemBuilder: (context, index) => _buildItem(controller.items[index]),
      ),
    );
  }

  Widget _buildItem(Item item) {
    return Card(
      child: Text(item.name),
    );
  }

  Widget _buildFooter(HomeController controller) {
    return CustomButton(
      label: 'Continue',
      onPressed: controller.onContinuePressed,
    );
  }
}
```

### Key Points:
- Use `const` constructors when possible
- Break large widgets into smaller methods
- Use descriptive method names (e.g., `_buildHeader`, not `_build1`)
- Keep `build()` method clean and readable

---

## 6. Controller Pattern

### ✅ Correct Pattern
```dart
class HomeController extends GetxController {
  // ==================== Dependencies ====================
  final ApiServices _apiServices = ApiServices();
  
  // ==================== Observable State ====================
  final RxBool isLoading = false.obs;
  final RxString userName = ''.obs;
  final RxList<Scenario> scenarios = <Scenario>[].obs;
  
  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    _initialize();
  }
  
  @override
  void onReady() {
    super.onReady();
    fetchData();
  }
  
  @override
  void onClose() {
    // Clean up resources
    _disposeResources();
    super.onClose();
  }
  
  // ==================== Public Methods ====================
  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      final data = await _apiServices.getData();
      scenarios.value = data;
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }
  
  void onItemTapped(int index) {
    AppLogger.debug('Item tapped: $index');
    // Handle tap
  }
  
  // ==================== Private Methods ====================
  void _initialize() {
    // Initialization logic
  }
  
  void _handleError(Object error) {
    AppLogger.error('Error occurred', error);
    ToastMessage.error('Something went wrong');
  }
  
  void _disposeResources() {
    // Cleanup logic
  }
}
```

### Key Points:
- Group related code with comment sections
- Public methods first, private methods last
- Always clean up in `onClose()`
- Use proper error handling
- Clear method names

---

## 7. API Service Pattern

### ✅ Correct Pattern
```dart
class AuthApiService {
  final String baseUrl = ApiConstant.baseUrl;
  
  /// Login user with email and password
  /// 
  /// Throws [ApiException] if login fails
  /// Returns [LoginResponseModel] on success
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LoginResponseModel.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw ApiException(
          error['message'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (_) {
      throw NetworkException('No internet connection');
    } on TimeoutException catch (_) {
      throw NetworkException('Request timed out');
    } catch (e) {
      AppLogger.error('Login error', e);
      throw ApiException('An unexpected error occurred');
    }
  }
}
```

### Key Points:
- Document public methods with `///` comments
- Specify what exceptions are thrown
- Use specific exception types
- Log errors properly (not with print)
- Return typed models

---

## 8. Model Class Pattern

### ✅ Correct Pattern
```dart
/// User profile response from API
class UserProfileResponseModel {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final DateTime createdAt;
  
  UserProfileResponseModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.createdAt,
  });
  
  /// Create model from JSON
  factory UserProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return UserProfileResponseModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  /// Create a copy with some fields updated
  UserProfileResponseModel copyWith({
    int? id,
    String? name,
    String? email,
    String? avatar,
    DateTime? createdAt,
  }) {
    return UserProfileResponseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  String toString() {
    return 'UserProfileResponseModel(id: $id, name: $name, email: $email)';
  }
}
```

### Key Points:
- All fields should be final
- Use `required` for non-nullable fields
- Provide factory constructor for JSON parsing
- Provide `toJson()` method
- Optional: `copyWith()` for immutability
- Optional: `toString()` for debugging

---

## 9. Error Handling Pattern

### ✅ Correct Pattern
```dart
Future<void> loadData() async {
  try {
    isLoading.value = true;
    
    final data = await _apiServices.fetchData();
    items.value = data;
    
  } on NetworkException catch (e) {
    AppLogger.warning('Network error', e);
    ToastMessage.error(
      'No internet connection',
      title: 'Connection Error',
    );
    
  } on ApiException catch (e) {
    AppLogger.error('API error', e);
    
    if (e.statusCode == 401) {
      _handleUnauthorized();
    } else {
      ToastMessage.error(
        e.userFriendlyMessage ?? 'Something went wrong',
      );
    }
    
  } catch (e, stackTrace) {
    AppLogger.error('Unexpected error', e, stackTrace);
    ToastMessage.error('An unexpected error occurred');
    
  } finally {
    isLoading.value = false;
  }
}
```

### ❌ Incorrect Pattern
```dart
try {
  final data = await _apiServices.fetchData();
  items.value = data;
} catch (e) {
  print('Error: $e');  // ❌ Using print
  ToastMessage.error('Error');  // ❌ Not helpful to user
}
```

---

## 10. Logging Pattern

### ✅ Correct Pattern

**Create:** `lib/utils/logger/app_logger.dart`
```dart
import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();
  
  static void debug(String message, [Object? data]) {
    if (kDebugMode) {
      print('🔍 DEBUG: $message${data != null ? ' | $data' : ''}');
    }
  }
  
  static void info(String message, [Object? data]) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message${data != null ? ' | $data' : ''}');
    }
  }
  
  static void warning(String message, [Object? error]) {
    if (kDebugMode) {
      print('⚠️ WARNING: $message${error != null ? ' | $error' : ''}');
    }
  }
  
  static void error(String message, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
      print('   Error: $error');
      if (stackTrace != null) {
        print('   Stack trace:\n$stackTrace');
      }
    }
    
    // In production, send to error tracking service
    // Sentry.captureException(error, stackTrace: stackTrace);
  }
}
```

**Usage:**
```dart
// Instead of:
print('Loading data...');  // ❌

// Use:
AppLogger.debug('Loading data');  // ✅
AppLogger.info('User logged in', userId);  // ✅
AppLogger.error('Failed to load', error, stackTrace);  // ✅
```

---

## 11. Responsive Design Pattern

### ✅ Correct Pattern
```dart
// Use ScreenUtil consistently
SizedBox(height: 24.h),        // Height responsive
SizedBox(width: 24.w),         // Width responsive
Text(style: TextStyle(fontSize: 16.sp)),  // Font size responsive

// Use semantic spacing
SizedBox(height: Spacing.medium.h),  // ✅ Better than magic number
padding: EdgeInsets.all(Spacing.large.w),

// Responsive containers
Container(
  width: 0.8.sw,  // 80% of screen width
  height: 0.5.sh, // 50% of screen height
)
```

---

## 12. State Management Pattern

### ✅ Correct Pattern
```dart
// In Controller
final RxBool isLoading = false.obs;
final RxString errorMessage = ''.obs;
final Rxn<User> currentUser = Rxn<User>(); // Nullable observable

// In UI
Obx(() => CustomButton(
  isLoading: controller.isLoading.value,
  onPressed: controller.login,
))

Obx(() {
  if (controller.isLoading.value) {
    return CircularProgressIndicator();
  }
  
  if (controller.errorMessage.isNotEmpty) {
    return ErrorWidget(message: controller.errorMessage.value);
  }
  
  return ContentWidget();
})
```

---

## 13. Navigation Pattern

### ✅ Correct Pattern
```dart
// Using GoRouter
void navigateToProfile() {
  context.push(AppPath.profile);
}

void navigateWithData() {
  context.push(
    AppPath.details,
    extra: userData,  // Pass data
  );
}

void replaceRoute() {
  context.pushReplacement(AppPath.home);
}

void goBack() {
  context.pop();
}
```

---

## 14. Dependency Injection Pattern

### ✅ Correct Pattern
```dart
// In lib/core/dependency/dependency.dart
class Dependency {
  static void init() {
    // Controllers - use fenix for auto-disposal and recreation
    Get.lazyPut<HomeController>(
      () => HomeController(),
      fenix: true,  // Recreate when needed
    );
    
    // Services - use permanent for singletons
    Get.put<ApiServices>(
      ApiServices(),
      permanent: true,  // Never dispose
    );
  }
}

// In main.dart
void main() {
  Dependency.init();
  runApp(MyApp());
}

// In widgets/controllers
final controller = Get.find<HomeController>();  // ✅
final controller = Get.put(HomeController());   // ❌ Don't use in widgets
```

---

## 15. Asset Management Pattern

### ✅ Correct Pattern
```dart
// lib/core/custom_assets/custom_assets.dart
class CustomAssets {
  CustomAssets._();
  
  // Images
  static const String _imagesPath = 'assets/images';
  static const String logo = '$_imagesPath/logo.png';
  static const String backgroundImage = '$_imagesPath/background.png';
  
  // Icons
  static const String _iconsPath = 'assets/icons';
  static const String homeIcon = '$_iconsPath/home.svg';
  static const String profileIcon = '$_iconsPath/profile.svg';
}

// Usage
Image.asset(CustomAssets.logo)
SvgPicture.asset(CustomAssets.homeIcon)
```

---

## 16. Testing Pattern

### ✅ Correct Pattern
```dart
// test/controllers/home_controller_test.dart
void main() {
  late HomeController controller;
  late MockApiServices mockApiServices;
  
  setUp(() {
    mockApiServices = MockApiServices();
    Get.put<ApiServices>(mockApiServices);
    controller = HomeController();
  });
  
  tearDown(() {
    Get.reset();
  });
  
  group('HomeController', () {
    test('initial state is correct', () {
      expect(controller.isLoading.value, false);
      expect(controller.scenarios.isEmpty, true);
    });
    
    test('fetchData updates scenarios on success', () async {
      // Arrange
      final mockData = [Scenario(id: 1, title: 'Test')];
      when(() => mockApiServices.fetchScenarios())
          .thenAnswer((_) async => mockData);
      
      // Act
      await controller.fetchData();
      
      // Assert
      expect(controller.scenarios.length, 1);
      expect(controller.isLoading.value, false);
    });
  });
}
```

---

## Common Anti-Patterns to Avoid

### ❌ Don't Do This

```dart
// 1. Using print() in production
print('Debug message');  // Use AppLogger instead

// 2. Magic numbers
SizedBox(height: 24.h);  // Use Spacing.medium

// 3. Hardcoded strings
Text('Welcome');  // Use AppStrings.welcome

// 4. Creating controllers in build method
Get.put(HomeController());  // Use Get.find() or Get.lazyPut()

// 5. Not handling errors
final data = await api.getData();  // Wrap in try-catch

// 6. Storing passwords in SharedPreferences
prefs.setString('password', password);  // Use flutter_secure_storage

// 7. Not disposing resources
StreamSubscription sub;  // Cancel in onClose()

// 8. Long build methods
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      child: Column(
        children: [
          // 200 lines of code...
        ]
      )
    )
  );
}

// 9. God classes (too many responsibilities)
class ApiServices {
  // 1771 lines of code - TOO MUCH!
}

// 10. Not using const constructors
Text('Hello');  // Should be: const Text('Hello')
```

---

## Quick Reference Checklist

- [ ] File names are snake_case
- [ ] Class names are PascalCase
- [ ] Variables/methods are camelCase
- [ ] Constants use UPPER_SNAKE_CASE or camelCase
- [ ] Using AppLogger instead of print()
- [ ] No hardcoded strings (use AppStrings)
- [ ] No magic numbers (use constants)
- [ ] Proper error handling with try-catch
- [ ] Resources disposed in onClose()
- [ ] Using const constructors where possible
- [ ] Widget methods are private (_buildWidget)
- [ ] Controllers properly registered in Dependency
- [ ] Null safety properly implemented
- [ ] Documentation for public APIs
- [ ] Tests written for critical logic

---

**Last Updated:** January 27, 2026
