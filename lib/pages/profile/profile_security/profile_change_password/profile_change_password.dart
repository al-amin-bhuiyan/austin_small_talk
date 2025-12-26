import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/custom_assets/custom_assets.dart';
import '../../../../utils/app_fonts/app_fonts.dart';
import '../../../../view/custom_back_button/custom_back_button.dart';
import '../../../../view/custom_start_conversation_button/custom_start_conversation_button.dart';
import 'profile_change_password_controller.dart';

class ProfileChangePasswordScreen extends StatelessWidget {
  const ProfileChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileChangePasswordController());

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Password
                      _buildFieldLabel('Current Password'),
                      SizedBox(height: 8.h),
                      Obx(() => _buildPasswordField(
                            controller: controller.currentPasswordController,
                            isObscured: controller.isCurrentPasswordObscured.value,
                            onToggle: controller.toggleCurrentPassword,
                          )),
                      SizedBox(height: 16.h),

                      // New Password
                      _buildFieldLabel('New Password'),
                      SizedBox(height: 8.h),
                      Obx(() => _buildPasswordField(
                            controller: controller.newPasswordController,
                            isObscured: controller.isNewPasswordObscured.value,
                            onToggle: controller.toggleNewPassword,
                          )),
                      SizedBox(height: 16.h),

                      // Confirm Password
                      _buildFieldLabel('Confirm Password'),
                      SizedBox(height: 8.h),
                      Obx(() => _buildPasswordField(
                            controller: controller.confirmPasswordController,
                            isObscured: controller.isConfirmPasswordObscured.value,
                            onToggle: controller.toggleConfirmPassword,
                          )),
                      SizedBox(height: 32.h),

                      // Save Button
                      CustomStartConversationButton(
                        label: 'Save',
                        onPressed: controller.changePassword,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          CustomBackButton(
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(
              'Change Password',
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

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppFonts.poppinsRegular(
        fontSize: 14,
        color: Colors.white,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    return Container(
      height: 47.h,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 6,
            offset: Offset(0, 3),
            spreadRadius: 0,
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscured,
        style: TextStyle(
          color: const Color(0xFFF6F6F6),
          fontSize: 14.sp,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          height: 1.05,
        ),
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.60),
            fontSize: 14.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            height: 1.05,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          suffixIcon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: IconButton(
              key: ValueKey<bool>(isObscured),
              icon: Icon(
                isObscured ? Icons.visibility_off : Icons.visibility,
                color: Colors.white.withValues(alpha: 0.70),
                size: 20.sp,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ),
    );
  }
}
