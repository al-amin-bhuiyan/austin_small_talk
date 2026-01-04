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
    if (selectedGender.value.isEmpty) {
      CustomSnackbar.warning(
        context: context,
        title: 'Selection Required',
        message: 'Please select your preferred AI voice',
      );
      return;
    }

    try {
      isLoading.value = true;

      // Get registration data from CreateAccountController
      final createAccountController = Get.find<CreateAccountController>();

      if (createAccountController.tempEmail == null ||
          createAccountController.tempName == null ||
          createAccountController.tempPassword == null ||
          createAccountController.tempDateOfBirth == null) {
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

      // Create register request model with selected voice
      final request = RegisterRequestModel(
        email: createAccountController.tempEmail!,
        name: createAccountController.tempName!,
        password: createAccountController.tempPassword!,
        password2: createAccountController.tempPassword!,
        voice: selectedGender.value, // Use selected gender as voice
        dateOfBirth: createAccountController.tempDateOfBirth!,
      );

      // Call API
      final response = await _apiServices.registerUser(request);

      if (context.mounted) {
        CustomSnackbar.success(
          context: context,
          title: 'Success',
          message: response.message,
        );
      }

      // Clear temporary data
      createAccountController.tempEmail = null;
      createAccountController.tempName = null;
      createAccountController.tempPassword = null;
      createAccountController.tempDateOfBirth = null;

      // Navigate to verify email with flag=false (signup flow) and pass email
      if (context.mounted) {
        context.push(
          '${AppPath.verifyEmail}?flag=false',
          extra: response.email, // Pass email from API response
        );
      }
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      if (!context.mounted) return;
      
      // Check if it's an "email already exists" error
      if (errorMessage.toLowerCase().contains('email') && 
          (errorMessage.toLowerCase().contains('already exists') || 
           errorMessage.toLowerCase().contains('already registered'))) {
        CustomSnackbar.error(
          context: context,
          title: 'Email Already Registered',
          message: errorMessage,
        );
      } else {
        CustomSnackbar.error(
          context: context,
          title: 'Registration Failed',
          message: errorMessage,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
