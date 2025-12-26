import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_route/app_path.dart';
import '../../utils/toast_message/toast_message.dart';

/// Controller for PreferredGenderScreen - handles gender selection logic
class PreferredGenderController extends GetxController {
  // Observable states
  final RxString selectedGender = ''.obs;
  final RxBool isLoading = false.obs;

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
      ToastMessage.warning(
        'Please select your preferred AI voice',
        title: 'Selection Required',
      );
      return;
    }

    try {
      isLoading.value = true;

      // TODO: Save preferred gender selection to backend
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to verify email with flag=false (signup flow)
      context.push('${AppPath.verifyEmail}?flag=false');
    } catch (e) {
      ToastMessage.error(
        'Failed to save preference: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
