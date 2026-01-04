import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:austin_small_talk/pages/profile/ProfileSupportandHelp/FAQs/faqs.dart';
import 'package:austin_small_talk/pages/profile/ProfileSupportandHelp/contactHelp/contact_help.dart';
import 'package:austin_small_talk/pages/profile/ProfileSupportandHelp/privacy_policy/privacy_policy.dart';
import 'package:austin_small_talk/pages/profile/ProfileSupportandHelp/termsandcondition/termsandcondition.dart';
import 'package:go_router/go_router.dart';

import '../../data/global/shared_preference.dart';
import '../../pages/home/home.dart';
import '../../pages/history/history.dart';
import '../../pages/login_or_sign_up/login_or_sign_up.dart';
import '../../pages/create_account/create_account.dart';
import '../../pages/forget_password/forget_password.dart';
import '../../pages/verified/verified_from_create_new_password.dart';
import '../../pages/verified_from_verify_email/verified_from_verify_email.dart';
import '../../pages/verify_email/verify_email.dart';
import '../../pages/create_new_password/create_new_password.dart';
import '../../pages/prefered_gender/prefered_gender.dart';
import '../../pages/ai_talk/ai_talk.dart';
import '../../pages/profile/profile.dart';
import '../../pages/home/notification/notification.dart';
import '../../pages/home/create_scenario/create_scenario.dart';
import '../../pages/ai_talk/message_screen/message_screen.dart';
import '../../pages/profile/edit_profile/edit_profile.dart';
import '../../pages/profile/subscription/subscription.dart';
import '../../pages/profile/profile_notification/profile_notification.dart';
import '../../pages/profile/profile_security/profile_security.dart';
import '../../pages/profile/profile_security/profile_change_password/profile_change_password.dart';
import '../../pages/profile/ProfileSupportandHelp/profile_support_and_help.dart';
import '../../view/screen/splash_screen.dart';

class RoutePath {
  static final GoRouter router =GoRouter(
    initialLocation: AppPath.splash,
    routes: [
      GoRoute(
        path: AppPath.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: AppPath.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppPath.history,
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppPath.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppPath.createAccount,
        name: 'createAccount',
        builder: (context, state) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: AppPath.forgetPassword,
        name: 'forgetPassword',
        builder: (context, state) => const ForgetPasswordScreen(),
      ),
      GoRoute(
        path: AppPath.verifyEmail,
        name: 'verifyEmail',
        builder: (context, state) {
          final flag = state.uri.queryParameters['flag'];
          final email = state.extra as String?;
          return VerifyEmailScreen(
            flag: flag,
            email: email,
          );
        },
      ),
      GoRoute(
        path: AppPath.createNewPassword,
        name: 'createNewPassword',
        builder: (context, state) => const CreateNewPasswordScreen(),
      ),
      GoRoute(
        path: AppPath.verifiedfromcreatenewpassword,
        name: 'verifiedfromcreatenewpassword',
        builder: (context, state) => const VerifiedScreenFromCreateNewPassword(),
      ),
      GoRoute(
        path: AppPath.verifiedfromverifyemail,
        name: 'verifiedfromverifyemail',
        builder: (context, state) => const VerifiedScreenFromVerifyEmail(),
      ),
      GoRoute(
        path: AppPath.preferredGender,
        name: 'preferredGender',
        builder: (context, state) => const PreferredGenderScreen(),
      ),

      GoRoute(
        path: AppPath.aitalk,
        name: 'aitalk',
        builder: (context, state) => const AiTalkScreen(),
      ),

      GoRoute(
        path: AppPath.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      GoRoute(
        path: AppPath.notification,
        name: 'notification',
        builder: (context, state) => const NotificationScreen(),
      ),

      GoRoute(
        path: AppPath.createScenario,
        name: 'createScenario',
        builder: (context, state) => const CreateScenarioScreen(),
      ),

      GoRoute(
        path: AppPath.messageScreen,
        name: 'messageScreen',
        builder: (context, state) => const MessageScreen(),
      ),

      GoRoute(
        path: AppPath.editProfile,
        name: 'editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),

      GoRoute(
        path: AppPath.subscription,
        name: 'subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),

      GoRoute(
        path: AppPath.profileNotification,
        name: 'profileNotification',
        builder: (context, state) => const ProfileNotificationScreen(),
      ),

      GoRoute(
        path: AppPath.profileSecurity,
        name: 'profileSecurity',
        builder: (context, state) => const ProfileSecurityScreen(),
      ),

      GoRoute(
        path: AppPath.changePassword,
        name: 'changePassword',
        builder: (context, state) => const ProfileChangePasswordScreen(),
      ),

  GoRoute(
  path: AppPath.supportandhelp,
  name: 'support-and-help',
  builder: (context, state) => const ProfileSupportandHelpScreen(),
  ),
      GoRoute(
        path: AppPath.faqs,
        name: 'faqs',
        builder: (context, state) => const FAQsScreen(),
      ),
      GoRoute(
        path: AppPath.contactSupport,
        name: 'contactSupport',
        builder: (context, state) => const ContactHelpScreen(),
      ),
      GoRoute(
        path: AppPath.privacyPolicy,
        name: 'privacyPolicy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: AppPath.termsAndConditions,
        name: 'termsAndConditions',
        builder: (context, state) => const TermsAndConditionScreen(),
      ),

    ]

  );
}