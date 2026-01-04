import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../data/global/shared_preference.dart';
import '../../service/auth/api_service/api_services.dart';
import '../../service/auth/models/login_request_model.dart';
import '../../utils/custom_snackbar/custom_snackbar.dart';
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
  
  // API service
  final ApiServices _apiServices = ApiServices();

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
  }
  
  /// Load saved credentials if Remember Me was enabled
  void _loadSavedCredentials() {
    if (SharedPreferencesUtil.isRememberMeEnabled()) {
      final savedEmail = SharedPreferencesUtil.getSavedEmail();
      final savedPassword = SharedPreferencesUtil.getSavedPassword();
      
      if (savedEmail != null && savedPassword != null) {
        emailController.text = savedEmail;
        passwordController.text = savedPassword;
        rememberMe.value = true;
      }
    }
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
        isLoading.value = true;

        // Create login request
        final request = LoginRequestModel(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        // Call login API
        final response = await _apiServices.loginUser(request);

        // Save user session
        await SharedPreferencesUtil.saveUserSession(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          userId: response.userId,
          userName: response.userName,
          email: response.email ?? emailController.text.trim(),
        );

        // Save credentials if Remember Me is checked
        if (rememberMe.value) {
          await SharedPreferencesUtil.saveLoginCredentials(
            email: emailController.text.trim(),
            password: passwordController.text,
          );
        } else {
          // Clear saved credentials if Remember Me is unchecked
          await SharedPreferencesUtil.clearLoginCredentials();
        }

        if (context.mounted) {
          CustomSnackbar.success(
            context: context,
            title: 'Success',
            message: response.message,
          );
        }

        // Navigate to home screen
        if (context.mounted) {
          context.go(AppPath.home);
        }
      } catch (e) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        
        if (!context.mounted) return;
        
        CustomSnackbar.error(
          context: context,
          title: 'Login Failed',
          message: errorMessage,
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

      // CustomSnackbar requires context, so we'll skip showing message for now
      // Or you can pass context from the UI
    } catch (e) {
      // Handle error
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

      // CustomSnackbar requires context, so we'll skip showing message for now
      // Or you can pass context from the UI
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }
}
