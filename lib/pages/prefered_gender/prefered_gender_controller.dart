import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_route/app_path.dart';
import '../../service/auth/api_service/api_services.dart';
import '../../service/auth/models/register_request_model.dart';
import '../../utils/custom_snackbar/custom_snackbar.dart';
import '../create_account/create_account_controller.dart';

/// Controller for PreferredGenderScreen - handles gender selection logic
class PreferredGenderController extends GetxController {
  // Observable states
  final RxString selectedGender = ''.obs;
  final RxBool isLoading = false.obs;

  // API Service
  final ApiServices _apiServices = ApiServices();

  /// Select male gender
  void selectMale() {
    selectedGender.value = 'male';
  }

  /// Select female gender
  void selectFemale() {
    selectedGender.value = 'female';
  }

  /// Check if male is selected
  bool get isMaleSelected => selectedGender.value == 'male';

  /// Check if female is selected
  bool get isFemaleSelected => selectedGender.value == 'female';

  /// Handle login to account button press
  Future<void> onLoginToAccountPressed(BuildContext context) async {
    print('');
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║        LOGIN TO ACCOUNT BUTTON PRESSED (SIGNUP)           ║');
    print('╚═══════════════════════════════════════════════════════════╝');
    
    if (selectedGender.value.isEmpty) {
      print('❌ No gender/voice selected');
      CustomSnackbar.warning(
        context: context,
        title: 'Selection Required',
        message: 'Please select your preferred AI voice',
      );
      return;
    }
    print('✅ Gender/voice selected: ${selectedGender.value}');

    try {
      isLoading.value = true;
      print('⏳ Loading state: ${isLoading.value}');

      // Get registration data from CreateAccountController
      final createAccountController = Get.find<CreateAccountController>();
      print('📦 Getting registration data from CreateAccountController...');

      if (createAccountController.tempEmail == null ||
          createAccountController.tempName == null ||
          createAccountController.tempPassword == null ||
          createAccountController.tempDateOfBirth == null) {
        print('❌ Registration data not found:');
        print('   tempEmail: ${createAccountController.tempEmail}');
        print('   tempName: ${createAccountController.tempName}');
        print('   tempPassword: ${createAccountController.tempPassword != null ? "exists" : "null"}');
        print('   tempDateOfBirth: ${createAccountController.tempDateOfBirth}');
        
        CustomSnackbar.error(
          context: context,
          title: 'Error',
          message: 'Registration data not found. Please start over.',
        );
        if (context.mounted) {
          context.go(AppPath.createAccount);
        }
        return;
      }

      print('✅ Registration data found:');
      print('   Email: ${createAccountController.tempEmail}');
      print('   Name: ${createAccountController.tempName}');
      print('   Password length: ${createAccountController.tempPassword?.length ?? 0}');
      print('   Date of Birth: ${createAccountController.tempDateOfBirth}');
      print('   Voice: ${selectedGender.value}');

      // Create register request model with selected voice
      final request = RegisterRequestModel(
        email: createAccountController.tempEmail!,
        name: createAccountController.tempName!,
        password: createAccountController.tempPassword!,
        password2: createAccountController.tempPassword!,
        voice: selectedGender.value, // Use selected gender as voice
        dateOfBirth: createAccountController.tempDateOfBirth!,
      );
      print('📦 Registration request created');

      // Call API
      print('📡 Calling registerUser API...');
      final response = await _apiServices.registerUser(request);
      print('✅ Registration API response received');
      print('   Message: ${response.message}');
      print('   Email: ${response.email}');

      if (context.mounted) {
        print('✅ Showing success snackbar');
        CustomSnackbar.success(
          context: context,
          title: 'Success',
          message: response.message,
        );
      }

      // Clear temporary data
      print('🗑️ Clearing temporary registration data...');
      createAccountController.tempEmail = null;
      createAccountController.tempName = null;
      createAccountController.tempPassword = null;
      createAccountController.tempDateOfBirth = null;
      print('✅ Temporary data cleared');

      // Navigate to verify email with flag=false (signup flow) and pass email
      if (context.mounted) {
        print('🚀 Navigating to verify email...');
        print('   Route: ${AppPath.verifyEmail}?flag=false');
        print('   Email: ${response.email}');
        context.push(
          '${AppPath.verifyEmail}?flag=false',
          extra: response.email, // Pass email from API response
        );
        print('✅ Navigation called');
      }
      print('═══════════════════════════════════════════════════════════');
    } catch (e) {
      print('');
      print('❌❌❌ REGISTRATION ERROR ❌❌❌');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace:');
      print(StackTrace.current);
      print('═══════════════════════════════════════════════════════════');
      
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      if (!context.mounted) return;
      
      // Check if it's an "email already exists" error
      if (errorMessage.toLowerCase().contains('email') && 
          (errorMessage.toLowerCase().contains('already exists') || 
           errorMessage.toLowerCase().contains('already registered'))) {
        CustomSnackbar.error(
          context: context,
          title: 'Email Already Registered',
          message: 'This email is already registered. Please use a different email or login.',
        );
      } else if (errorMessage.toLowerCase().contains('network') ||
                 errorMessage.toLowerCase().contains('connection') ||
                 errorMessage.toLowerCase().contains('timeout')) {
        CustomSnackbar.error(
          context: context,
          title: 'Connection Error',
          message: 'Please check your internet connection and try again.',
        );
      } else if (errorMessage.toLowerCase().contains('server') ||
                 errorMessage.toLowerCase().contains('500')) {
        CustomSnackbar.error(
          context: context,
          title: 'Server Error',
          message: 'Something went wrong on our end. Please try again later.',
        );
      } else {
        // Show a generic user-friendly message for unknown errors
        CustomSnackbar.error(
          context: context,
          title: 'Registration Failed',
          message: errorMessage.isNotEmpty 
              ? errorMessage 
              : 'Unable to complete registration. Please try again.',
        );
      }
    } finally {
      isLoading.value = false;
      print('⏳ Loading state: ${isLoading.value}');
    }
  }
}
