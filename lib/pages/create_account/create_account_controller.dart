import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../utils/toast_message/toast_message.dart';

/// Controller for CreateAccountScreen - handles sign up logic
class CreateAccountController extends GetxController {
  // Text editing controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool acceptTerms = false.obs;
  final RxString selectedDay = ''.obs;
  final RxString selectedMonth = ''.obs;
  final RxString selectedYear = ''.obs;

  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // List of months
  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // Get number of days in selected month/year
  int getDaysInMonth(int month, int year) {
    if (month == 2) {
      // February - check for leap year
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    } else if ([4, 6, 9, 11].contains(month)) {
      // April, June, September, November
      return 30;
    } else {
      // All other months
      return 31;
    }
  }

  // Get list of days based on selected month and year
  List<String> getDaysList() {
    if (selectedMonth.value.isEmpty || selectedYear.value.isEmpty) {
      return List.generate(31, (index) => '${index + 1}');
    }

    int monthIndex = months.indexOf(selectedMonth.value) + 1;
    int year = int.parse(selectedYear.value);
    int daysCount = getDaysInMonth(monthIndex, year);

    return List.generate(daysCount, (index) => '${index + 1}');
  }

  // Get list of years (from current year down to 1900)
  List<String> getYearsList() {
    int currentYear = DateTime.now().year;
    return List.generate(currentYear - 1899, (index) => '${currentYear - index}');
  }

  // Update selected month
  void setMonth(String month) {
    selectedMonth.value = month;
    // Reset day if it exceeds the new month's max days
    if (selectedDay.value.isNotEmpty) {
      int day = int.parse(selectedDay.value);
      int maxDays = getDaysInMonth(months.indexOf(month) + 1, 
          selectedYear.value.isEmpty ? DateTime.now().year : int.parse(selectedYear.value));
      if (day > maxDays) {
        selectedDay.value = '';
      }
    }
  }

  // Update selected year
  void setYear(String year) {
    selectedYear.value = year;
    // Reset day if it exceeds the new month's max days (leap year check)
    if (selectedDay.value.isNotEmpty && selectedMonth.value.isNotEmpty) {
      int day = int.parse(selectedDay.value);
      int maxDays = getDaysInMonth(months.indexOf(selectedMonth.value) + 1, int.parse(year));
      if (day > maxDays) {
        selectedDay.value = '';
      }
    }
  }

  // Update selected day
  void setDay(String day) {
    selectedDay.value = day;
  }

  // Toggle terms acceptance
  void toggleTerms() {
    acceptTerms.value = !acceptTerms.value;
  }

  // Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Validate username
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  // Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Validate birth date
  String? validateBirthDate() {
    if (selectedDay.value.isEmpty || selectedMonth.value.isEmpty || selectedYear.value.isEmpty) {
      return 'Please select complete birth date';
    }
    return null;
  }

  // Handle create account button press
  Future<void> onCreateAccountPressed(BuildContext context) async {
    if (!acceptTerms.value) {
      ToastMessage.error(
        'Please accept the Terms and Conditions',
        title: 'Terms Required',
      );
      return;
    }

    if (formKey.currentState?.validate() ?? false) {
      String? birthDateError = validateBirthDate();
      if (birthDateError != null) {
        ToastMessage.error(
          birthDateError,
          title: 'Birth Date Required',
        );
        return;
      }

      try {
        isLoading.value = true;

        // TODO: Implement your sign up API call here
        await Future.delayed(const Duration(seconds: 2)); // Simulating API call

        ToastMessage.success(
          'Account created successfully!',
        );

        // Navigate to login or home
        // Get.offAllNamed(AppPath.login);
        context.push(AppPath.preferredGender);
      } catch (e) {
        ToastMessage.error(
          'Failed to create account: ${e.toString()}',
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Navigate to Terms and Conditions
  void onTermsPressed() {
    ToastMessage.info(
      'Terms and Conditions page coming soon',
    );
  }

  // Navigate to Login
  void onLoginPressed(BuildContext context) {
    context.pop();
  }

  @override
  void onClose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
