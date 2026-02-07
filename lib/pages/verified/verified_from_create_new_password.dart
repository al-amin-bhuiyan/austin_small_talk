import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_fonts/app_fonts.dart';
import '../../view/custom_button/custom_button.dart';
import 'verified_from_create_new_password_controller.dart';

class VerifiedScreenFromCreateNewPassword extends StatelessWidget {
  const VerifiedScreenFromCreateNewPassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Use Get.put to ensure controller is always available
    final controller = Get.put(VerifiedControllerFromCreateNewPassword());

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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 40.h),

                // Logo
                Center(
                  child: Image.asset(
                    CustomAssets.splashLogo,
                    width: 100.w,
                    height: 100.h,
                  ),
                ),

                // Add spacing to center the content
              SizedBox(height: 24.h,),

                // Checkmark Icon with circular background
                Container(
                  width: 80.w,
                  height: 80.h,
                  child:Center(
                    child: Image.asset(CustomAssets.verfied,
                    height: 48.h,width: 48.w,),

                  ),
                  ),


                SizedBox(height: 16.h),

                // Verified Title
                Text(
                  'Verified',
                  style: AppFonts.poppinsBold(
                    fontSize:
                    18,
                    color: AppColors.whiteColor,
                  ),
                ),

                SizedBox(height: 16.h),

                // Description
                Text(
                  'You have successfully verified your account.',
                  textAlign: TextAlign.center,
                  style: AppFonts.poppinsRegular(
                    fontSize: 14,
                    color: AppColors.whiteColor.withAlpha(200),
                  ),
                ),

                SizedBox(height: 32.h),

                // Login to your Account Button
                Obx(
                  () => CustomButton(
                    label: 'Login to your Account',
                    onPressed: () => controller.onLoginToAccountPressed(context),
                    isLoading: controller.isLoading.value,
                    height: 56.h,
                  ),
                ),

                // Add spacing at the bottom
                const Spacer(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
