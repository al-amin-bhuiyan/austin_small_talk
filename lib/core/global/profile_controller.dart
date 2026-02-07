import 'package:get/get.dart';
import '../../data/global/shared_preference.dart';

/// Global Profile Controller - Singleton for profile data synchronization across all screens
/// This ensures that profile updates (like image changes) are instantly reflected everywhere
class GlobalProfileController extends GetxController {
  static GlobalProfileController get instance => Get.find();
  
  // Observable profile data - all screens listen to these
  final RxString profileImageUrl = ''.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }
  
  /// Load profile data from SharedPreferences
  void loadProfileData() {
    print('🔄 GlobalProfileController: Loading profile data...');
    final prefs = SharedPreferencesUtil.instance;
    
    profileImageUrl.value = prefs.getString('profile_image') ?? '';
    userName.value = prefs.getString('user_name') ?? 'User';
    userEmail.value = prefs.getString('user_email') ?? '';
    
    print('✅ Profile data loaded:');
    print('   - Name: ${userName.value}');
    print('   - Email: ${userEmail.value}');
    print('   - Image: ${profileImageUrl.value}');
  }
  
  /// Update profile image globally - all screens react instantly
  void updateProfileImage(String imageUrl) {
    print('🔄 GlobalProfileController: Updating profile image...');
    print('   New URL: $imageUrl');
    
    profileImageUrl.value = imageUrl;
    SharedPreferencesUtil.instance.setString('profile_image', imageUrl);
    
    print('✅ Profile image updated globally - all screens will reflect this change');
  }
  
  /// Update user name globally
  void updateUserName(String name) {
    print('🔄 GlobalProfileController: Updating user name to: $name');
    
    userName.value = name;
    SharedPreferencesUtil.instance.setString('user_name', name);
    
    print('✅ User name updated globally');
  }
  
  /// Update user email globally
  void updateUserEmail(String email) {
    print('🔄 GlobalProfileController: Updating user email to: $email');
    
    userEmail.value = email;
    SharedPreferencesUtil.instance.setString('user_email', email);
    
    print('✅ User email updated globally');
  }
  
  /// Update all profile data at once
  void updateAllProfileData({
    String? imageUrl,
    String? name,
    String? email,
  }) {
    print('🔄 GlobalProfileController: Updating all profile data...');
    
    if (imageUrl != null) {
      profileImageUrl.value = imageUrl;
      SharedPreferencesUtil.instance.setString('profile_image', imageUrl);
      print('   ✓ Image updated: $imageUrl');
    }
    
    if (name != null) {
      userName.value = name;
      SharedPreferencesUtil.instance.setString('user_name', name);
      print('   ✓ Name updated: $name');
    }
    
    if (email != null) {
      userEmail.value = email;
      SharedPreferencesUtil.instance.setString('user_email', email);
      print('   ✓ Email updated: $email');
    }
    
    print('✅ All profile data updated globally');
  }
  
  /// Clear profile data (on logout)
  void clearProfileData() {
    print('🗑️ GlobalProfileController: Clearing profile data...');
    
    profileImageUrl.value = '';
    userName.value = '';
    userEmail.value = '';
    
    SharedPreferencesUtil.instance.remove('profile_image');
    SharedPreferencesUtil.instance.remove('user_name');
    SharedPreferencesUtil.instance.remove('user_email');
    
    print('✅ Profile data cleared');
  }
}
