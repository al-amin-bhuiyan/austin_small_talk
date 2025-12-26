import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../utils/toast_message/toast_message.dart';

/// Controller for LoginScreen - handles login/signup logic
class LoginController extends GetxController {
  // Text editing controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool rememberMe = false.obs;
  final RxBool obscurePassword = true.obs;

  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    // Initialize any data if needed
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Toggle remember me checkbox
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Handle login button press
  Future<void> onLoginPressed(BuildContext context) async {
    if (formKey.currentState?.validate() ?? false) {
      try {
      //   isLoading.value = true;

        // TODO: Implement your login API call here
        await Future.delayed(const Duration(seconds: 2)); // Simulating API call

        // On success, navigate to home or next screen
        // Get.offAllNamed(AppPath.home);

        context.push(AppPath.home);

        ToastMessage.success(
          'Login successful!',
        );
      } catch (e) {
        ToastMessage.error(
          'Login failed: ${e.toString()}',
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  /// Handle "Forgot Password" tap
  void onForgotPasswordPressed(BuildContext context) {
    // Navigate to forgot password screen
    context.push(AppPath.forgetPassword);
  }

  /// Handle "Sign up" tap
  void onSignUpPressed(BuildContext context) {
    // Navigate to sign up screen
    context.push(AppPath.createAccount);
  }

  /// Handle Google sign in
  Future<void> onGoogleSignInPressed() async {
    try {
      isLoading.value = true;

      // TODO: Implement Google Sign In
      await Future.delayed(const Duration(seconds: 1));

      ToastMessage.info(
        'Google Sign In coming soon',
      );
    } catch (e) {
      ToastMessage.error(
        'Google Sign In failed: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle Apple sign in
  Future<void> onAppleSignInPressed() async {
    try {
      isLoading.value = true;

      // TODO: Implement Apple Sign In
      await Future.delayed(const Duration(seconds: 1));

      ToastMessage.info(
        'Apple Sign In coming soon',
      );
    } catch (e) {
      ToastMessage.error(
        'Apple Sign In failed: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
