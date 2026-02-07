import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/custom_assets/custom_assets.dart';
import '../../../utils/app_fonts/app_fonts.dart';
import '../../../utils/nav_bar/nav_bar_controller.dart';
import '../../../view/custom_back_button/custom_back_button.dart';
import 'profile_security_controller.dart';

class ProfileSecurityScreen extends StatelessWidget {
  const ProfileSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileSecurityController>(
      init: ProfileSecurityController(),
      autoRemove: true,
      builder: (controller) {
        return Scaffold(
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
                            _buildChangePasswordItem(controller,context),
                            SizedBox(height: 12.h),
                            _buildToggleItem(
                              title: 'Login Activity',
                              value: controller.loginActivity,
                              onChanged: controller.toggleLoginActivity,
                            ),
                            SizedBox(height: 12.h),
                            _buildToggleItem(
                              title: 'Email & Phone Verification',
                              value: controller.emailPhoneVerification,
                              onChanged: controller.toggleEmailPhoneVerification,
                            ),
                            SizedBox(height: 12.h),
                            _buildDeleteAccountItem(context, controller),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
              'Security',
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

  Widget _buildChangePasswordItem(ProfileSecurityController controller,BuildContext context) {
    return GestureDetector(
      onTap: () => controller.onChangePassword(context),
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
            Expanded(
              child: Text(
                'Change Password',
                style: AppFonts.poppinsRegular(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.909),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required RxBool value,
    required Function(bool) onChanged,
  }) {
    return Obx(() => Container(
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
              Expanded(
                child: Text(
                  title,
                  style: AppFonts.poppinsRegular(
                    fontSize: 14,
                    color: Colors.white,
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

  Widget _buildDeleteAccountItem(BuildContext context, ProfileSecurityController controller) {
    return GestureDetector(
      onTap: () => _showDeleteAccountDialog(context, controller),
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
            Expanded(
              child: Text(
                'Delete Account',
                style: AppFonts.poppinsRegular(
                  fontSize: 14,
                  color: const Color(0xFFE74C3C),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 24.w,
              height: 24.h,
              child: Icon(
                Icons.delete,
                color: const Color(0xFFE74C3C),
                size: 24.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSwitch({
    required bool value,
    required Function(bool) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
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
  void _showDeleteAccountDialog(BuildContext context, ProfileSecurityController controller) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 276.w,
            height: 220.h,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Delete Icon
                Container(
                  width:32.w,
                  height: 32.h,

                  child: Center(
                    child: Icon(
                      Icons.delete_forever,
                      color: const Color(0xFFE74C3C),
                      size: 32.sp,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // Title
                Text(
                  'Delete Account',
                  style: AppFonts.poppinsSemiBold(
                    fontSize: 18.h,
                    color: Colors.redAccent,
                  ),
                ),

                SizedBox(height:12.h),

                // Description


                SizedBox(height: 24.h),

                // Delete Button
                GestureDetector(
                  onTap: () {

                    controller.performDeleteAccount(context); // Perform delete
                    context.push(AppPath.login);

                  },
                  child: Container(
                    width: double.infinity,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        'Delete',
                        style: AppFonts.poppinsMedium(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Cancel Button

              ],
            ),
          ),
        );
      },
    );
  }
}
