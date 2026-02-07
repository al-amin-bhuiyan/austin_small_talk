import 'package:austin_small_talk/global/controller/splash_controller.dart';
import 'package:austin_small_talk/core/global/profile_controller.dart';
import 'package:austin_small_talk/pages/ai_talk/voice_chat/voice_chat_controller.dart';
import 'package:austin_small_talk/pages/home/home_controller.dart';
import 'package:austin_small_talk/utils/nav_bar/nav_bar_controller.dart';
import 'package:austin_small_talk/pages/create_account/create_account_controller.dart';
import 'package:austin_small_talk/pages/forget_password/forget_password_controller.dart';
import 'package:austin_small_talk/pages/verify_email/verify_email_controller.dart';
import 'package:austin_small_talk/pages/verify_email_from_forget_password/verify_email_from_forget_password_controller.dart';
import 'package:austin_small_talk/pages/create_new_password/create_new_password_controller.dart';
import 'package:austin_small_talk/pages/verified/verified_from_create_new_password_controller.dart';
import 'package:austin_small_talk/pages/verified_from_verify_email/verified_from_verify_email_controller.dart';
import 'package:austin_small_talk/pages/prefered_gender/prefered_gender_controller.dart';
import 'package:get/get.dart';

class Dependency {
  static void init() {
    // ✅ TRULY GLOBAL CONTROLLERS - persist across the entire app lifecycle
    // Global Profile Controller - ensures profile updates sync instantly across all screens
    Get.put(GlobalProfileController(), permanent: true);
    
    // ✅ ONLY truly global controllers - these persist across the app
    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);
    Get.lazyPut<NavBarController>(() => NavBarController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<VoiceChatController>(() => VoiceChatController(), fenix: true);
    
    // ✅ Authentication flow controllers (global for seamless auth experience)
    Get.lazyPut<CreateAccountController>(() => CreateAccountController(), fenix: true);
    Get.lazyPut<ForgetPasswordController>(() => ForgetPasswordController(), fenix: true);
    Get.lazyPut<VerifyEmailController>(() => VerifyEmailController(), fenix: true);
    Get.lazyPut<VerifyEmailFromForgetPasswordController>(() => VerifyEmailFromForgetPasswordController(), fenix: true);
    Get.lazyPut<CreateNewPasswordController>(() => CreateNewPasswordController(), fenix: true);
    Get.lazyPut<VerifiedControllerFromCreateNewPassword>(() => VerifiedControllerFromCreateNewPassword(), fenix: true);
    Get.lazyPut<VerifiedControllerFromVerifyEmail>(() => VerifiedControllerFromVerifyEmail(), fenix: true);
    Get.lazyPut<PreferredGenderController>(() => PreferredGenderController(), fenix: true);

    // ❌ REMOVED: All page-specific controllers
    // These are now initialized only when their pages are opened using GetBuilder with autoRemove
    // - HistoryController (pages/history/)
    // - ProfileController (pages/profile/)
    // - AiTalkController (pages/ai_talk/)
    // - MessageScreenController (pages/ai_talk/message_screen/)
    // - EditProfileController (pages/profile/edit_profile/)
    // - NotificationController (pages/home/notification/)
    // - CreateScenarioController (pages/home/create_scenario/)
    // - ProfileSecurityController (pages/profile/profile_security/)
    // - ProfileNotificationController (pages/profile/profile_notification/)
    // - SubscriptionController (pages/profile/subscription/)
    // - ProfileSupportandHelpController (pages/profile/ProfileSupportandHelp/)
  }
}
