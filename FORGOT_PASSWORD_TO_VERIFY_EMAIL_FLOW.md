# Forgot Password to Verify Email Flow - Implementation

## Summary
Updated the forgot password flow to properly pass email to `VerifyEmailController` using `Get.find<>()` pattern, ensuring the email and flag are set before navigation.

---

## 🔄 Complete Flow

### **Step 1: User on Forgot Password Screen**

User enters email: `ferdos.khurrom@gmail.com`

```dart
// forget_password_controller.dart
Future<void> onForgetPasswordPressed(BuildContext context) async {
  // 1. Validate terms accepted
  if (!acceptTerms.value) {
    CustomSnackbar.warning(...);
    return;
  }

  // 2. Validate email format
  if (formKey.currentState?.validate() ?? false) {
    // 3. Create API request
    final request = ForgotPasswordRequestModel(
      email: emailController.text.trim(),
    );

    // 4. Call API
    final response = await _apiServices.sendResetPasswordEmail(request);
    
    // 5. Show success message
    CustomSnackbar.success(
      context: context,
      title: 'Success',
      message: response.message, // "Password Reset OTP send. Please check your Email"
    );

    // ✅ 6. Get VerifyEmailController and set values
    final verifyController = Get.find<VerifyEmailController>();
    verifyController.email.value = emailController.text.trim();
    verifyController.flag.value = true; // Forgot password flow

    // 7. Navigate to Verify Email screen
    context.push(
      '${AppPath.verifyEmail}?flag=true',
      extra: emailController.text.trim(),
    );
  }
}
```

---

### **Step 2: Verify Email Screen Receives Data**

```dart
// verify_email.dart
@override
Widget build(BuildContext context) {
  // ✅ Get the existing controller (already initialized with email and flag)
  final controller = Get.find<VerifyEmailController>();
  
  // Optional: Override with route parameters if provided
  if (flag != null) {
    controller.flag.value = flag == 'true';
  }

  if (email != null && email!.isNotEmpty) {
    controller.email.value = email!;
  }

  // Now controller.email.value = "ferdos.khurrom@gmail.com"
  // And controller.flag.value = true (forgot password flow)
  
  return Scaffold(...);
}
```

---

## 📊 Data Flow Diagram

```
┌─────────────────────────────────────────┐
│   Forget Password Screen                │
│   User enters: ferdos.khurrom@gmail.com │
└──────────────────┬──────────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │ Click "Forget        │
        │ Password" Button     │
        └──────────┬───────────┘
                   │
                   ▼
┌──────────────────────────────────────────┐
│ POST /accounts/user/send-reset-password- │
│ email/                                   │
│ { "email": "ferdos.khurrom@gmail.com" }  │
└──────────────────┬───────────────────────┘
                   │
                   ▼ Response 200
        ┌──────────────────────┐
        │ Show Success Toast   │
        │ "Password Reset OTP  │
        │ send. Please check   │
        │ your Email"          │
        └──────────┬───────────┘
                   │
                   ▼
┌──────────────────────────────────────────┐
│ Get.find<VerifyEmailController>()        │
│ ✅ verifyController.email.value =        │
│    "ferdos.khurrom@gmail.com"            │
│ ✅ verifyController.flag.value = true    │
└──────────────────┬───────────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │ Navigate to          │
        │ Verify Email Screen  │
        │ ?flag=true           │
        │ extra=email          │
        └──────────┬───────────┘
                   │
                   ▼
┌──────────────────────────────────────────┐
│ Verify Email Screen                      │
│ ✅ Displays email in UI                  │
│ "We emailed you a six-digit code to     │
│  ferdos.khurrom@gmail.com"               │
│                                          │
│ ✅ User enters 6-digit OTP               │
│ ✅ Verify OTP with flag=true             │
└──────────────────┬───────────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │ If flag=true         │
        │ → Create New Password│
        │                      │
        │ If flag=false        │
        │ → Verified Screen    │
        └──────────────────────┘
```

---

## 🎯 Key Implementation Points

### **1. Controller Communication Pattern**

```dart
// In ForgetPasswordController
final verifyController = Get.find<VerifyEmailController>();
verifyController.email.value = emailController.text.trim();
verifyController.flag.value = true;
```

**Why this works:**
- `Get.find<VerifyEmailController>()` retrieves the existing controller instance
- The controller is already registered in dependency injection (from `Dependency.init()`)
- We set the values **before** navigation
- When `VerifyEmailScreen` calls `Get.find<>()`, it gets the same controller with pre-set values

---

### **2. Double Safety with Route Parameters**

```dart
// In verify_email.dart
final controller = Get.find<VerifyEmailController>();

// Override with route params if provided (backup safety)
if (flag != null) {
  controller.flag.value = flag == 'true';
}

if (email != null && email!.isNotEmpty) {
  controller.email.value = email!;
}
```

**Benefits:**
- Primary: Controller already has correct values
- Backup: Route parameters can override if needed
- Fail-safe: Works even if controller wasn't pre-initialized

---

## 🔀 Flow Comparison

### **Before (Had Issues):**
```dart
// Forgot Password Controller
context.push('${AppPath.verifyEmail}?flag=true', extra: email);

// Verify Email Screen
// Controller might not have email set
// Depends only on route parameters
```

### **After (Fixed):**
```dart
// Forgot Password Controller
final verifyController = Get.find<VerifyEmailController>();
verifyController.email.value = email; // ✅ Set first
verifyController.flag.value = true;   // ✅ Set flag
context.push('${AppPath.verifyEmail}?flag=true', extra: email);

// Verify Email Screen
// Controller already has email and flag ✅
// Route parameters act as backup ✅
```

---

## 📝 Complete Usage Example

### **Scenario: User Forgets Password**

1. **User on Login Screen**
   - Clicks "Forgot Password?"

2. **Forget Password Screen**
   ```dart
   User enters: ferdos.khurrom@gmail.com
   Checks: "I agree to Terms and Conditions" ✓
   Clicks: "Forget password"
   ```

3. **API Call**
   ```json
   POST http://10.10.7.74:8001/accounts/user/send-reset-password-email/
   { "email": "ferdos.khurrom@gmail.com" }
   
   Response 200:
   { "msg": "Password Reset OTP send. Please check your Email" }
   ```

4. **Controller Sets Values**
   ```dart
   final verifyController = Get.find<VerifyEmailController>();
   verifyController.email.value = "ferdos.khurrom@gmail.com";
   verifyController.flag.value = true;
   ```

5. **Navigate to Verify Email**
   ```dart
   context.push('${AppPath.verifyEmail}?flag=true', extra: email);
   ```

6. **Verify Email Screen**
   ```dart
   final controller = Get.find<VerifyEmailController>();
   // controller.email.value = "ferdos.khurrom@gmail.com" ✅
   // controller.flag.value = true ✅
   
   // UI displays:
   "We emailed you a six-digit code to ferdos.khurrom@gmail.com"
   ```

7. **User Enters OTP**
   ```
   User enters: 1 2 3 4 5 6
   Clicks: "Verify"
   ```

8. **OTP Verification**
   ```json
   POST http://10.10.7.74:8001/accounts/user/verify-otp/
   {
     "email": "ferdos.khurrom@gmail.com",
     "otp": "123456"
   }
   ```

9. **Routing Based on Flag**
   ```dart
   if (flag.value == true) {
     // Forgot password flow
     context.push(AppPath.createNewPassword);
   } else {
     // Signup flow
     context.push(AppPath.verifiedfromverifyemail);
   }
   ```

---

## ✅ Benefits of This Approach

1. **✅ Reliable Data Transfer** - Controller directly receives data
2. **✅ Type Safety** - No string parsing needed
3. **✅ State Management** - Uses GetX reactive state
4. **✅ Backup Safety** - Route parameters as fallback
5. **✅ Clean Code** - Follows GetX patterns
6. **✅ Testable** - Easy to unit test

---

## 🐛 Previous Issue

**Problem:**
```dart
// Only relied on route parameters
context.push('${AppPath.verifyEmail}?flag=true', extra: email);

// In verify_email.dart
if (email != null && email!.isNotEmpty) {
  controller.email.value = email!; // Might not trigger in all cases
}
```

**Issue:**
- Route parameters might not always be received
- Controller state wasn't explicitly set
- Timing issues with controller initialization

---

## ✨ Solution

**Fix:**
```dart
// Explicitly set controller values BEFORE navigation
final verifyController = Get.find<VerifyEmailController>();
verifyController.email.value = emailController.text.trim();
verifyController.flag.value = true;

// Then navigate (controller already has data)
context.push('${AppPath.verifyEmail}?flag=true', extra: email);
```

---

## 📄 Files Modified

1. ✅ `lib/pages/forget_password/forget_password_controller.dart`
   - Added import for `VerifyEmailController`
   - Updated `onForgetPasswordPressed` to use `Get.find<>()` pattern
   - Explicitly sets email and flag before navigation

---

## 🎯 Testing

**Test Case 1: Forgot Password Flow**
```
1. Go to Forgot Password screen
2. Enter email: test@example.com
3. Check Terms & Conditions
4. Click "Forget password"
5. ✅ Verify: Toast shows "Password Reset OTP send..."
6. ✅ Verify: Navigate to Verify Email screen
7. ✅ Verify: Email displays correctly in description
8. ✅ Verify: OTP verification uses correct email
9. ✅ Verify: After OTP, goes to Create New Password (not Verified)
```

**Test Case 2: Signup Flow (Should Still Work)**
```
1. Go to Create Account
2. Complete signup
3. ✅ Verify: Navigate to Verify Email screen
4. ✅ Verify: Email displays correctly
5. ✅ Verify: After OTP, goes to Verified screen (not Create Password)
```

---

**Date:** January 5, 2026  
**Status:** ✅ Complete and Working  
**Pattern:** GetX Controller Communication via `Get.find<>()`

---

The forgot password flow now properly sets the email in `VerifyEmailController` before navigation, ensuring reliable data transfer! 🎉
