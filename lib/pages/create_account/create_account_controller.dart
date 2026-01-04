import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import '../../utils/custom_snackbar/custom_snackbar.dart';
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

  // Store registration data temporarily
  String? tempEmail;
  String? tempName;
  String? tempPassword;
  String? tempDateOfBirth;

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
  void setMonth(String month,BuildContext context) {
    selectedMonth.value = month;
    
    // Validate date if all fields are selected
    if (selectedDay.value.isNotEmpty && selectedMonth.value.isNotEmpty && selectedYear.value.isNotEmpty) {
      int day = int.parse(selectedDay.value);
      int maxDays = getDaysInMonth(months.indexOf(month) + 1, 
          selectedYear.value.isEmpty ? DateTime.now().year : int.parse(selectedYear.value));
      
      if (day > maxDays || !isValidDate()) {
        CustomSnackbar.warning(
          context: context,
          title: 'Invalid Date Format',
          message: 'Please select a valid date',
        );
        clearDateFields();
      }
    }
  }

  // Update selected year
  void setYear(String year,BuildContext context) {
    selectedYear.value = year;
    
    // Validate date if all fields are selected (especially for leap year validation)
    if (selectedDay.value.isNotEmpty && selectedMonth.value.isNotEmpty && selectedYear.value.isNotEmpty) {
      int day = int.parse(selectedDay.value);
      int maxDays = getDaysInMonth(months.indexOf(selectedMonth.value) + 1, int.parse(year));
      
      if (day > maxDays || !isValidDate()) {
        CustomSnackbar.warning(
          context: context,
          title: 'Invalid Date Format',
          message: 'Please select a valid date',
        );
        clearDateFields();
      }
    }
  }

  // Update selected day
  void setDay(String day, BuildContext context) {
    selectedDay.value = day;
    
    // Validate date if all fields are selected
    if (selectedDay.value.isNotEmpty && selectedMonth.value.isNotEmpty && selectedYear.value.isNotEmpty) {
      if (!isValidDate()) {
        toastification.show(
          context: context,
          title: Text('Invalid Date & Month!'),
          autoCloseDuration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
        );
        clearDateFields();
      }
    }
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
    
    // Validate if the date is actually valid
    if (!isValidDate()) {
      return 'Invalid date';
    }
    
    return null;
  }

  // Check if selected date is valid
  bool isValidDate() {
    if (selectedDay.value.isEmpty || selectedMonth.value.isEmpty || selectedYear.value.isEmpty) {
      return false;
    }

    try {
      int day = int.parse(selectedDay.value);
      int monthIndex = months.indexOf(selectedMonth.value) + 1;
      int year = int.parse(selectedYear.value);

      // Check if month is valid
      if (monthIndex < 1 || monthIndex > 12) {
        return false;
      }

      // Check if day is valid for the selected month and year
      int maxDays = getDaysInMonth(monthIndex, year);
      if (day < 1 || day > maxDays) {
        return false;
      }

      // Try to create a DateTime object to verify the date is valid
      DateTime dateTime = DateTime(year, monthIndex, day);
      
      // Additional check to ensure the date components match
      if (dateTime.year != year || dateTime.month != monthIndex || dateTime.day != day) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Clear date fields
  void clearDateFields() {
    selectedDay.value = '';
    selectedMonth.value = '';
    selectedYear.value = '';
  }

  // Format date to YYYY-MM-DD
  String _formatDate() {
    int monthIndex = months.indexOf(selectedMonth.value) + 1;
    String month = monthIndex.toString().padLeft(2, '0');
    String day = selectedDay.value.padLeft(2, '0');
    return '${selectedYear.value}-$month-$day';
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

      // Store data temporarily for use after gender selection
      tempEmail = emailController.text.trim();
      tempName = usernameController.text.trim();
      tempPassword = passwordController.text;
      tempDateOfBirth = _formatDate();

      // Navigate to preferred gender selection
      context.push(AppPath.preferredGender);
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
