import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/custom_assets/custom_assets.dart';
import '../../../utils/app_fonts/app_fonts.dart';
import '../../../utils/nav_bar/nav_bar_controller.dart';
import '../../../view/custom_back_button/custom_back_button.dart';
import 'profile_support_and_help_controller.dart';

class ProfileSupportandHelpScreen extends StatelessWidget {
  const ProfileSupportandHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navBarController = Get.find<NavBarController>();

    return GetBuilder<ProfileSupportandHelpController>(
      init: ProfileSupportandHelpController(),
      autoRemove: true,
      builder: (controller) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              // Ensure we stay on profile tab (index 3) after back navigation
              navBarController.returnToTab(3);
            }
          },
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(CustomAssets.backgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 100.h),
                        child: Column(
                          children: [
                            _buildMenuItem(
                              title: 'FAQs',
                              onTap: ()=>controller.onFAQsTap(context),
                            ),
                            SizedBox(height: 12.h),
                            _buildMenuItem(
                              title: 'Contact Support',
                              onTap: () => controller.onContactSupportTap(context),
                            ),
                            SizedBox(height: 12.h),
                            _buildMenuItem(
                              title: 'Privacy Policy',
                              onTap: () => controller.onPrivacyPolicyTap(context),
                            ),
                            SizedBox(height: 12.h),
                            _buildMenuItem(
                              title: 'Terms & Conditions',
                              onTap: () => controller.onTermsAndConditionsTap(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // bottomNavigationBar: SafeArea(
            //   child: CustomNavBar(controller: navBarController),
            // ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          CustomBackButton(
            onPressed: () {
              // Ensure profile tab (index 3) stays selected
              final navController = Get.find<NavBarController>();
              navController.returnToTab(3);
              context.pop();
            },
          ),
          Expanded(
            child: Text(
              'Support & Help',
              textAlign: TextAlign.center,
              style: AppFonts.poppinsSemiBold(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFF2C3E5C),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8.w,
              height: 8.h,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: AppFonts.poppinsRegular(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
