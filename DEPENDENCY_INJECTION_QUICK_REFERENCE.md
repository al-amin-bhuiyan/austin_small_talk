# Dependency Injection - Quick Reference

## 📖 Quick Start

### Adding a New Controller

1. **Create Controller**
```dart
class MyNewController extends GetxController {
  final RxBool isLoading = false.obs;
  
  void myMethod() {
    // Your logic here
  }
}
```

2. **Register in `dependency.dart`**
```dart
class Dependency {
  static void init() {
    // ... existing controllers
    Get.lazyPut<MyNewController>(() => MyNewController());
  }
}
```

3. **Use in Page**
```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyNewController>();
    
    return Obx(() => Text('Loading: ${controller.isLoading.value}'));
  }
}
```

---

## 🎯 All Registered Controllers

```dart
// Global
Get.find<SplashController>()

// Authentication
Get.find<LoginController>()
Get.find<CreateAccountController>()
Get.find<ForgetPasswordController>()
Get.find<VerifyEmailController>()
Get.find<CreateNewPasswordController>()

// Verified Screens
Get.find<VerifiedControllerFromCreateNewPassword>()
Get.find<VerifiedControllerFromVerifyEmail>()
```

---

## ⚠️ Important Rules

### ✅ DO
- Use `Get.find<T>()` to access controllers in pages
- Register controllers with `Get.lazyPut<T>()` in dependency.dart
- Call `Dependency.init()` once in main.dart
- Use type parameters: `Get.find<LoginController>()`

### ❌ DON'T
- Don't use `Get.put()` in pages
- Don't create controllers with `new` or direct instantiation
- Don't forget to add controller to dependency.dart
- Don't use `Get.find()` without type parameter

---

## 🔍 Troubleshooting

### Error: "Controller not found"
```dart
// Problem: Controller not registered
Get.find<MyController>() // ❌ Error

// Solution: Add to dependency.dart
Get.lazyPut<MyController>(() => MyController()); // ✅
```

### Error: "Type not specified"
```dart
// Problem: Missing type parameter
final controller = Get.find(); // ❌ Error

// Solution: Add type
final controller = Get.find<MyController>(); // ✅
```

### Testing
```dart
// Mock controller in tests
setUp(() {
  Get.reset(); // Clear all controllers
  Get.lazyPut<MyController>(() => MockMyController());
});
```

---

## 📋 Checklist for New Features

When adding a new feature with a controller:

- [ ] Create controller file
- [ ] Add controller to `dependency.dart`
- [ ] Import controller in dependency.dart
- [ ] Use `Get.lazyPut<T>()` to register
- [ ] Use `Get.find<T>()` in page
- [ ] Test navigation flow
- [ ] Run `flutter analyze`
- [ ] Test app restart

---

## 💡 Pro Tips

### 1. Type Safety
Always use type parameters to avoid runtime errors:
```dart
final controller = Get.find<LoginController>(); // ✅ Type safe
```

### 2. Testing
Reset GetX between tests:
```dart
tearDown(() {
  Get.reset();
});
```

### 3. Lazy Loading
Controllers are created only when first accessed:
```dart
Get.lazyPut<MyController>(() => MyController()); // Not created yet
// ...later...
Get.find<MyController>(); // Created here on first access
```

### 4. Memory Management
GetX automatically disposes controllers when not needed. No manual cleanup required!

---

## 🔗 Related Files

- **Main Registration:** `lib/core/dependency/dependency.dart`
- **Initialization:** `lib/main.dart` (Dependency.init())
- **Controllers:** `lib/pages/*/controller.dart`
- **Documentation:** `DEPENDENCY_INJECTION_IMPLEMENTATION.md`

---

Quick Reference v1.0 - December 2025
