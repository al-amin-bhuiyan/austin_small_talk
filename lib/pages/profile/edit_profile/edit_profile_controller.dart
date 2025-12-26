import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../utils/toast_message/toast_message.dart';

/// Edit Profile Controller
class EditProfileController extends GetxController {
  // Text controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  
  // Observable fields
  final selectedGender = 'Female'.obs;
  final profileImage = Rxn<String>();
  final isLoading = false.obs;
  final selectedDate = Rxn<DateTime>();
  
  // Gender options
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  
  // Image picker
  final ImagePicker _picker = ImagePicker();
  
  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }
  
  /// Load user data from signup (mock data for now)
  void _loadUserData() {
    // TODO: Get actual user data from storage/API
    // Leave fields empty - values shown as hint text
    fullNameController.text = '';
    emailController.text = '';
    dateOfBirthController.text = '';
    selectedGender.value = 'Female';
    profileImage.value = null; // Set user profile image if exists
  }
  
  /// Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        profileImage.value = image.path;
        ToastMessage.success('Profile image updated');
      }
    } catch (e) {
      ToastMessage.error('Failed to pick image: $e');
    }
  }
  
  /// Show date picker
  Future<void> selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Color(0xFF00D9FF),
              onPrimary: Colors.white,
              surface: Color(0xFF1F2937),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      selectedDate.value = picked;
      dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }
  
  /// Validate and save profile
  Future<void> saveProfile() async {
    // Validation
    if (fullNameController.text.trim().isEmpty) {
      ToastMessage.error('Please enter your full name');
      return;
    }
    
    if (emailController.text.trim().isEmpty) {
      ToastMessage.error('Please enter your email address');
      return;
    }
    
    if (!GetUtils.isEmail(emailController.text.trim())) {
      ToastMessage.error('Please enter a valid email address');
      return;
    }
    
    if (dateOfBirthController.text.trim().isEmpty) {
      ToastMessage.error('Please select your date of birth');
      return;
    }
    
    // Show loading
    isLoading.value = true;
    
    try {
      // TODO: Implement actual API call to update profile
      await Future.delayed(Duration(seconds: 2)); // Simulate API call
      
      // Success
      ToastMessage.success('Profile updated successfully');
      Get.back(); // Go back to profile screen
    } catch (e) {
      ToastMessage.error('Failed to update profile: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Change gender
  void changeGender(String? value) {
    if (value != null) {
      selectedGender.value = value;
    }
  }
  
  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    dateOfBirthController.dispose();
    super.onClose();
  }
}
