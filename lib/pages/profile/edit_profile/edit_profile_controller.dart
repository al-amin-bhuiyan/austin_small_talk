import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/global/profile_controller.dart';
import '../../../data/global/shared_preference.dart';
import '../../../service/auth/api_service/api_services.dart';
import '../../../service/auth/api_constant/api_constant.dart';
import '../../../service/auth/models/user_profile_response_model.dart';
import '../../../utils/toast_message/toast_message.dart';
import '../profile_controller.dart';
import '../../home/home_controller.dart';

/// Edit Profile Controller
class EditProfileController extends GetxController {
  // Services
  final ApiServices _apiServices = ApiServices();

  // Text controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  
  // Observable fields
  final selectedGender = 'Female'.obs;
  final profileImage = Rxn<String>();
  final profileImageUrl = ''.obs; // For network image URL
  final isLoading = false.obs;
  final selectedDate = Rxn<DateTime>();
  final userName = 'Sophia Adams'.obs;
  final userEmail = 'sophia@gmail.com'.obs;
  
  // Gender options
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  
  // Image picker
  final ImagePicker _picker = ImagePicker();
  
  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }
  
  /// Load user data from API
  Future<void> _loadUserData() async {
    try {
      isLoading.value = true;
      
      // Get access token
      final accessToken = SharedPreferencesUtil.getAccessToken();
      
      if (accessToken == null || accessToken.isEmpty) {
        print('❌ No access token found for edit profile');
        isLoading.value = false;
        return;
      }

      print('📡 Fetching user profile for edit...');
      
      // Call API
      final profile = await _apiServices.getUserProfile(
        accessToken: accessToken,
      );

      // Update user data
      userName.value = profile.name;
      userEmail.value = profile.email;
      fullNameController.text = profile.name;
      emailController.text = profile.email;
      
      // Set date of birth
      if (profile.dateOfBirth != null && profile.dateOfBirth!.isNotEmpty) {
        try {
          // Parse date from API format (2018-08-09) to display format (dd/MM/yyyy)
          final parsedDate = DateTime.parse(profile.dateOfBirth!);
          selectedDate.value = parsedDate;
          dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(parsedDate);
        } catch (e) {
          print('Error parsing date: $e');
        }
      }
      
      // Set gender
      if (profile.voice != null && profile.voice!.isNotEmpty) {
        // Capitalize first letter
        final gender = profile.voice!.substring(0, 1).toUpperCase() + 
                       profile.voice!.substring(1);
        if (genderOptions.contains(gender)) {
          selectedGender.value = gender;
        }
      }
      
      // Set profile image URL
      profileImageUrl.value = profile.getFullImageUrl(ApiConstant.baseUrl) ?? '';
      
      print('✅ User profile loaded for edit: ${profile.name}');
      print('📸 Profile image URL: ${profileImageUrl.value}');
    } catch (e) {
      print('❌ Error fetching user profile for edit: $e');
      ToastMessage.error('Failed to load profile');
    } finally {
      isLoading.value = false;
    }
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
  Future<void> saveProfile(BuildContext context) async {
    print('');
    print('╔═══════════════════════════════════════════╗');
    print('║     SAVE PROFILE BUTTON PRESSED           ║');
    print('╚═══════════════════════════════════════════╝');
    
    // Validation
    if (fullNameController.text.trim().isEmpty) {
      ToastMessage.error(
        'Full name is required',
        title: 'Missing Field',
      );
      return;
    }
    
    if (fullNameController.text.trim().length < 2) {
      ToastMessage.error(
        'Full name must be at least 2 characters',
        title: 'Invalid Name',
      );
      return;
    }
    
    if (dateOfBirthController.text.trim().isEmpty) {
      ToastMessage.error(
        'Date of birth is required',
        title: 'Missing Field',
      );
      return;
    }
    
    // Show loading
    isLoading.value = true;
    
    try {
      // Get access token
      final accessToken = SharedPreferencesUtil.getAccessToken();
      
      if (accessToken == null || accessToken.isEmpty) {
        print('❌ No access token found');
        ToastMessage.error(
          'Please log in first',
          title: 'Authentication Required',
        );
        isLoading.value = false;
        return;
      }

      // Convert date from UI format (dd/MM/yyyy) to API format (yyyy-MM-dd)
      String? apiDateFormat;
      if (selectedDate.value != null) {
        apiDateFormat = DateFormat('yyyy-MM-dd').format(selectedDate.value!);
      }

      // Convert gender to lowercase for voice field (Female -> female, Male -> male)
      final voiceValue = selectedGender.value.toLowerCase();

      print('═══════════════════════════════════════════');
      print('📤 SENDING PROFILE UPDATE REQUEST');
      print('═══════════════════════════════════════════');
      print('📝 Name: ${fullNameController.text.trim()}');
      print('📝 Email: ${emailController.text.trim()} (read-only)');
      print('📝 Date of Birth (UI): ${dateOfBirthController.text}');
      print('📝 Date of Birth (API): $apiDateFormat');
      print('📝 Voice/Gender: $voiceValue');
      print('📸 Has new image: ${profileImage.value != null && profileImage.value!.isNotEmpty}');
      if (profileImage.value != null) {
        print('📸 Image path: ${profileImage.value}');
      }
      print('═══════════════════════════════════════════');

      // Call update API - use multipart if there's a new image
      final UserProfileResponseModel updatedProfile;
      if (profileImage.value != null && profileImage.value!.isNotEmpty) {
        // Update with image (multipart/form-data)
        print('🔄 Calling updateUserProfileWithImage...');
        updatedProfile = await _apiServices.updateUserProfileWithImage(
          accessToken: accessToken,
          name: fullNameController.text.trim(),
          dateOfBirth: apiDateFormat,
          voice: voiceValue,
          imagePath: profileImage.value,
        );
      } else {
        // Update without image (JSON)
        print('🔄 Calling updateUserProfile (no image)...');
        updatedProfile = await _apiServices.updateUserProfile(
          accessToken: accessToken,
          name: fullNameController.text.trim(),
          dateOfBirth: apiDateFormat,
          voice: voiceValue,
        );
      }

      print('═══════════════════════════════════════════');
      print('✅ PROFILE UPDATE SUCCESSFUL');
      print('═══════════════════════════════════════════');
      print('📋 Updated Name: ${updatedProfile.name}');
      print('📋 Updated Email: ${updatedProfile.email}');
      print('📋 Updated Image: ${updatedProfile.image}');
      print('═══════════════════════════════════════════');

      // Update observable values with response
      userName.value = updatedProfile.name;
      userEmail.value = updatedProfile.email;
      profileImageUrl.value = updatedProfile.getFullImageUrl(ApiConstant.baseUrl) ?? '';
      
      print('🔄 Updating controllers...');
      
      // ✅ UPDATE GLOBAL PROFILE CONTROLLER - This syncs ALL screens instantly!
      try {
        GlobalProfileController.instance.updateAllProfileData(
          imageUrl: profileImageUrl.value,
          name: updatedProfile.name,
          email: updatedProfile.email,
        );
        print('✅ GlobalProfileController updated - ALL screens will update instantly!');
      } catch (e) {
        print('⚠️ GlobalProfileController not found (should never happen): $e');
      }
      
      // Update ProfileController if it exists
      try {
        final profileController = Get.find<ProfileController>();
        profileController.userName.value = updatedProfile.name;
        profileController.userEmail.value = updatedProfile.email;
        profileController.userAvatar.value = profileImageUrl.value;
        print('✅ ProfileController updated');
      } catch (e) {
        print('⚠️ ProfileController not found: $e');
      }

      // Update HomeController if it exists
      try {
        final homeController = Get.find<HomeController>();
        homeController.userName.value = updatedProfile.name;
        homeController.userProfileImage.value = profileImageUrl.value;
        print('✅ HomeController updated');
      } catch (e) {
        print('⚠️ HomeController not found: $e');
      }
      
      // Success
      print('✅ All controllers updated');
      print('🎉 Showing success message and navigating back');
      print('');
      print('╔══════════════════════════════════════════╗');
      print('║   ✅ SHOWING SUCCESS TOAST MESSAGE      ║');
      print('╚══════════════════════════════════════════╝');
      
      ToastMessage.success(
        'Profile updated successfully!',
        title: 'Success',
      );
      
      print('✅ Toast message called');
      print('🔙 Navigating back to profile screen...');
      
      // Small delay to ensure toast is visible before navigation
      await Future.delayed(Duration(milliseconds: 500));
      
      // Navigate back
      context.pop();
      
      print('✅ Navigation completed');
      print('╔══════════════════════════════════════════╗');
      
    } catch (e, stackTrace) {
      print('');
      print('❌❌❌ ERROR SAVING PROFILE ❌❌❌');
      print('Error: $e');
      print('Stack trace:');
      print(stackTrace);
      print('═══════════════════════════════════════════');
      
      // Parse error message to show user-friendly message
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      // Check for specific error types
      if (errorMessage.contains('401') || errorMessage.contains('Session expired')) {
        ToastMessage.error(
          'Your session has expired. Please log in again.',
          title: 'Session Expired',
        );
      } else if (errorMessage.contains('404') || errorMessage.contains('not found')) {
        ToastMessage.error(
          'Profile update service unavailable',
          title: 'Service Error',
        );
      } else if (errorMessage.contains('Network') || errorMessage.contains('SocketException')) {
        ToastMessage.error(
          'Please check your internet connection',
          title: 'Network Error',
        );
      } else {
        ToastMessage.error(
          errorMessage,
          title: 'Update Failed',
        );
      }
    } finally {
      isLoading.value = false;
      print('═══════════════════════════════════════════');
    }
  }
  
  /// Change gender
  void changeGender(String? value) {
    if (value != null) {
      selectedGender.value = value;
    }
  }
  
  /// Public method for pull-to-refresh
  Future<void> loadUserProfile() async {
    print('🔄 Refreshing edit profile data...');
    await _loadUserData();
  }
  
  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    dateOfBirthController.dispose();
    super.onClose();
  }
}

