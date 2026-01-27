import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:austin_small_talk/pages/profile/ProfileSupportandHelp/FAQs/faqs.dart';
import 'package:austin_small_talk/pages/profile/ProfileSupportandHelp/contactHelp/contact_help.dart';
import 'package:austin_small_talk/pages/profile/ProfileSupportandHelp/privacy_policy/privacy_policy.dart';
import 'package:austin_small_talk/pages/profile/ProfileSupportandHelp/termsandcondition/termsandcondition.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../pages/main_navigation/main_navigation.dart';
import '../../pages/login_or_sign_up/login_or_sign_up.dart';
import '../../pages/create_account/create_account.dart';
import '../../pages/forget_password/forget_password.dart';
import '../../pages/verified/verified_from_create_new_password.dart';
import '../../pages/verified_from_verify_email/verified_from_verify_email.dart';
import '../../pages/verify_email/verify_email.dart';
import '../../pages/create_new_password/create_new_password.dart';
import '../../pages/prefered_gender/prefered_gender.dart';
import '../../pages/home/notification/notification.dart';
import '../../pages/home/create_scenario/create_scenario.dart';
import '../../pages/ai_talk/message_screen/message_screen.dart';
import '../../pages/ai_talk/voice_chat/voice_chat.dart';
import '../../pages/profile/edit_profile/edit_profile.dart';
import '../../pages/profile/subscription/subscription.dart';
import '../../pages/profile/profile_notification/profile_notification.dart';
import '../../pages/profile/profile_security/profile_security.dart';
import '../../pages/profile/profile_security/profile_change_password/profile_change_password.dart';
import '../../pages/profile/ProfileSupportandHelp/profile_support_and_help.dart';
import '../../pages/verify_email_from_forget_password/verify_email_from_forget_password.dart';
import '../../view/screen/splash_screen.dart';

class RoutePath {
  static final GoRouter router = GoRouter(
    initialLocation: AppPath.splash,
    routes: [
      GoRoute(
        path: AppPath.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ✅ Shell route with IndexedStack - All 4 tabs share ONE MainNavigation instance
      // This eliminates white screen flicker completely
      ShellRoute(
        builder: (context, state, child) => const MainNavigation(),
        routes: [
          GoRoute(
            path: AppPath.home,
            name: 'home',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SizedBox.shrink(), // Placeholder - MainNavigation handles display
            ),
          ),
          GoRoute(
            path: AppPath.history,
            name: 'history',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SizedBox.shrink(),
            ),
          ),
          GoRoute(
            path: AppPath.aitalk,
            name: 'aitalk',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SizedBox.shrink(),
            ),
          ),
          GoRoute(
            path: AppPath.profile,
            name: 'profile',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SizedBox.shrink(),
            ),
          ),
        ],
      ),

      // ✅ All other routes use NoTransitionPage for ZERO flicker
      GoRoute(
        path: AppPath.login,
        name: 'login',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppPath.createAccount,
        name: 'createAccount',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const CreateAccountScreen(),
        ),
      ),
      GoRoute(
        path: AppPath.forgetPassword,
        name: 'forgetPassword',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ForgetPasswordScreen(),
        ),
      ),
      GoRoute(
        path: AppPath.verifyEmail,
        name: 'verifyEmail',
        pageBuilder: (context, state) {
          final flag = state.uri.queryParameters['flag'];
          final email = state.extra as String?;
          return NoTransitionPage(
            key: state.pageKey,
            child: VerifyEmailScreen(
              flag: flag,
              email: email,
            ),
          );
        },
      ),
      GoRoute(
        path: AppPath.verifyEmailFromForgetPassword,
        name: 'verifyEmailFromForgetPassword',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const VerifyEmailFromForgetPasswordScreen(),
        ),
      ),
      GoRoute(
        path: AppPath.createNewPassword,
        name: 'createNewPassword',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const CreateNewPasswordScreen(),
        ),
      ),
      GoRoute(
        path: AppPath.verifiedfromcreatenewpassword,
        name: 'verifiedfromcreatenewpassword',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const VerifiedScreenFromCreateNewPassword(),
        ),
      ),
      GoRoute(
        path: AppPath.verifiedfromverifyemail,
        name: 'verifiedfromverifyemail',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const VerifiedScreenFromVerifyEmail(),
        ),
      ),
      GoRoute(
        path: AppPath.preferredGender,
        name: 'preferredGender',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const PreferredGenderScreen(),
        ),
      ),

      GoRoute(
        path: AppPath.notification,
        name: 'notification',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const NotificationScreen(),
        ),
      ),

      GoRoute(
        path: AppPath.createScenario,
        name: 'createScenario',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const CreateScenarioScreen(),
        ),
      ),

      GoRoute(
        path: AppPath.messageScreen,
        name: 'messageScreen',
        pageBuilder: (context, state) {
          final scenarioData = state.extra;
          return NoTransitionPage(
            key: state.pageKey,
            child: MessageScreen(scenarioData: scenarioData),
          );
        },
      ),

      GoRoute(
        path: AppPath.voiceChat,
        name: 'voiceChat',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const VoiceChatScreen(),
        ),
      ),

      GoRoute(
        path: AppPath.editProfile,
        name: 'editProfile',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const EditProfileScreen(),
        ),
      ),

      GoRoute(
        path: AppPath.subscription,
        name: 'subscription',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const SubscriptionScreen(),
        ),
      ),

      GoRoute(
        path: AppPath.profileNotification,
        name: 'profileNotification',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ProfileNotificationScreen(),
        ),
      ),

      GoRoute(
        path: AppPath.profileSecurity,
        name: 'profileSecurity',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ProfileSecurityScreen(),
        ),
      ),

      GoRoute(
        path: AppPath.changePassword,
        name: 'changePassword',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ProfileChangePasswordScreen(),
        ),
      ),

      GoRoute(
        path: AppPath.supportandhelp,
        name: 'support-and-help',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ProfileSupportandHelpScreen(),
        ),
      ),
      GoRoute(
        path: AppPath.faqs,
        name: 'faqs',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const FAQsScreen(),
        ),
      ),
      GoRoute(
        path: AppPath.contactSupport,
        name: 'contactSupport',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const ContactHelpScreen(),
        ),
      ),
      GoRoute(
        path: AppPath.privacyPolicy,
        name: 'privacyPolicy',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const PrivacyPolicyScreen(),
        ),
      ),
      GoRoute(
        path: AppPath.termsAndConditions,
        name: 'termsAndConditions',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const TermsAndConditionScreen(),
        ),
      ),

    ]

  );
}