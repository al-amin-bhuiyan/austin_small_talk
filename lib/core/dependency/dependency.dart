import 'package:austin_small_talk/global/controller/splash_controller.dart';
import 'package:austin_small_talk/pages/create_account/create_account_controller.dart';
import 'package:austin_small_talk/pages/create_new_password/create_new_password_controller.dart';
import 'package:austin_small_talk/pages/forget_password/forget_password_controller.dart';
import 'package:austin_small_talk/pages/history/history_controller.dart';
import 'package:austin_small_talk/pages/home/home_controller.dart';
import 'package:austin_small_talk/pages/prefered_gender/prefered_gender_controller.dart';
import 'package:austin_small_talk/pages/profile/profile_security/profile_security_controller.dart';
import 'package:austin_small_talk/pages/verified/verified_from_create_new_password_controller.dart';
import 'package:austin_small_talk/pages/verified_from_verify_email/verified_from_verify_email_controller.dart';
import 'package:austin_small_talk/pages/verify_email/verify_email_controller.dart';
import 'package:austin_small_talk/pages/verify_email_from_forget_password/verify_email_from_forget_password_controller.dart';
import 'package:austin_small_talk/pages/ai_talk/ai_talk_controller.dart';
import 'package:austin_small_talk/pages/ai_talk/message_screen/message_screen_controller.dart';
import 'package:austin_small_talk/pages/ai_talk/voice_chat/voice_chat_controller.dart';
import 'package:austin_small_talk/pages/ai_talk/voice_chat/service/voice_chat_manager.dart';
import 'package:austin_small_talk/pages/profile/profile_controller.dart';
import 'package:austin_small_talk/pages/profile/edit_profile/edit_profile_controller.dart';
import 'package:austin_small_talk/pages/home/notification/notification_controller.dart';
import 'package:austin_small_talk/pages/home/create_scenario/create_scenario_controller.dart';
import 'package:austin_small_talk/utils/nav_bar/nav_bar_controller.dart';
import 'package:get/get.dart';

class Dependency {
  static void init() {
    // ✅ Initialize WebSocket Manager as PERMANENT singleton
    // Get.lazyPut<VoiceChatManager>(VoiceChatManager.instance, permanent: true);
    Get.lazyPut<VoiceChatController>(() => VoiceChatController(), fenix: true);

    // Global Controllers
    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);
    Get.lazyPut<NavBarController>(() => NavBarController(), fenix: true);

    // Authentication Controllers
    //Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<ProfileSecurityController>(
      () => ProfileSecurityController(),
      fenix: true,
    );

    Get.lazyPut<CreateAccountController>(
      () => CreateAccountController(),
      fenix: true,
    );
    Get.lazyPut<ForgetPasswordController>(
      () => ForgetPasswordController(),
      fenix: true,
    );
    Get.lazyPut<VerifyEmailController>(
      () => VerifyEmailController(),
      fenix: true,
    );
    Get.lazyPut<VerifyEmailFromForgetPasswordController>(
      () => VerifyEmailFromForgetPasswordController(),
      fenix: true,
    );
    Get.lazyPut<CreateNewPasswordController>(
      () => CreateNewPasswordController(),
      fenix: true,
    );

    // Verified Screen Controllers
    Get.lazyPut<VerifiedControllerFromCreateNewPassword>(
      () => VerifiedControllerFromCreateNewPassword(),
      fenix: true,
    );
    Get.lazyPut<VerifiedControllerFromVerifyEmail>(
      () => VerifiedControllerFromVerifyEmail(),
      fenix: true,
    );

    // Preferred Gender Controller
    Get.lazyPut<PreferredGenderController>(
      () => PreferredGenderController(),
      fenix: true,
    );

    // Home Controller
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);

    // History Controller
    Get.lazyPut<HistoryController>(() => HistoryController(), fenix: true);

    // AI Talk Controller
    Get.lazyPut<AiTalkController>(() => AiTalkController(), fenix: true);

    // Message Screen Controller
    Get.lazyPut<MessageScreenController>(
      () => MessageScreenController(),
      fenix: true,
    );

    // Voice Chat Controller
    Get.lazyPut<VoiceChatController>(() => VoiceChatController(), fenix: true);

    // Profile Controller
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut(() => AiTalkController(), fenix: true);

    // Edit Profile Controller
    Get.lazyPut<EditProfileController>(
      () => EditProfileController(),
      fenix: true,
    );

    // Notification Controller
    Get.lazyPut<NotificationController>(
      () => NotificationController(),
      fenix: true,
    );

    // Create Scenario Controller
    Get.lazyPut<CreateScenarioController>(
      () => CreateScenarioController(),
      fenix: true,
    );
  }
}
