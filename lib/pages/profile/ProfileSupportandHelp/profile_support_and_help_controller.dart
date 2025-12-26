import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class ProfileSupportandHelpController extends GetxController {
  // Navigation methods for each menu item
  void onFAQsTap(BuildContext context) {
    context.push(AppPath.faqs);
    print('FAQs tapped');
  }

  void onContactSupportTap(BuildContext context) {
    context.push(AppPath.contactSupport);
    print('Contact Support tapped');
  }

  void onPrivacyPolicyTap(BuildContext context) {
    context.push(AppPath.privacyPolicy);
    print('Privacy Policy tapped');
  }

  void onTermsAndConditionsTap(BuildContext context) {
    context.push(AppPath.termsAndConditions);
    print('Terms & Conditions tapped');
  }
}
