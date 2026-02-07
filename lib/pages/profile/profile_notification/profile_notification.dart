import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/custom_assets/custom_assets.dart';
import '../../../utils/app_colors/app_colors.dart';
import '../../../utils/app_fonts/app_fonts.dart';
import '../../../utils/nav_bar/nav_bar.dart';
import '../../../utils/nav_bar/nav_bar_controller.dart';
import '../../../view/custom_back_button/custom_back_button.dart';
import 'profile_notification_controller.dart';

class ProfileNotificationScreen extends StatelessWidget {
  const ProfileNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navBarController = Get.find<NavBarController>();

    return GetBuilder<ProfileNotificationController>(
      init: ProfileNotificationController(),
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
                            _buildNotificationItem(
                              title: 'Receive notifications when new\nscenario arrived',
                              value: controller.receiveNewScenario,
                              onChanged: controller.toggleReceiveNewScenario,
                            ),
                            SizedBox(height: 12.h),
                            _buildNotificationItem(
                              title: 'Notify me about practice reminder',
                              value: controller.practiceReminder,
                              onChanged: controller.togglePracticeReminder,
                            ),
                            SizedBox(height: 12.h),
                            _buildNotificationItem(
                              title: 'Security alerts',
                              value: controller.securityAlerts,
                              onChanged: controller.toggleSecurityAlerts,
                            ),
                            SizedBox(height: 12.h),
                            _buildNotificationItem(
                              title: 'Push notifications',
                              value: controller.pushNotifications,
                              onChanged: controller.togglePushNotifications,
                            ),
                            SizedBox(height: 12.h),
                            _buildNotificationItem(
                              title: 'Email notifications',
                              value: controller.emailNotifications,
                              onChanged: controller.toggleEmailNotifications,
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
              'Notification',
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

  Widget _buildNotificationItem({
    required String title,
    required RxBool value,
    required Function(bool) onChanged,
  }) {
    return Obx(() => Container(
          width: double.infinity,
          height:69.h,
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
              Expanded(
                child: Text(
                  title,
                  style: AppFonts.poppinsRegular(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              _buildAnimatedSwitch(
                value: value.value,
                onChanged: onChanged,
              ),
            ],
          ),
        ));
  }

  Widget _buildAnimatedSwitch({
    required bool value,
    required Function(bool) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        width: 51.w,
        height: 31.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.5.r),
          color: value ? const Color(0xFF4C8BF5) : const Color(0xFF4A5568),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 27.w,
            height: 27.h,
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
