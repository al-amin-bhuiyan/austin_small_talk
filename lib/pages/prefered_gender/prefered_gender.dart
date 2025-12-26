import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_fonts/app_fonts.dart';
import '../../view/custom_button/custom_button.dart';
import 'prefered_gender_controller.dart';

class PreferredGenderScreen extends StatelessWidget {
  const PreferredGenderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PreferredGenderController>();

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
            //    SizedBox(height: 10.h),

                // Logo
                Center(
                  child: Image.asset(
                    CustomAssets.splashLogo,
                    width: 100.w,
                    height: 100.h,
                  ),
                ),

                SizedBox(height: 20.h),

                // Title
                Text(
                  'Which gender you preferred',
                  style: AppFonts.poppinsBold(
                    fontSize: 20,
                    color: AppColors.whiteColor,
                  ),
                ),

                SizedBox(height: 8.h),

                // Subtitle
                Text(
                  'Please Select prefered AI Voice',
                  style: AppFonts.poppinsRegular(
                    fontSize: 14,
                    color: AppColors.whiteColor.withAlpha(200),
                  ),
                ),

                SizedBox(height: 50.h),

                // Male Selection
                Obx(
                  () => GestureDetector(
                    onTap: controller.selectMale,
                    child: Column(
                      children: [
                        _buildGenderCard(
                          image: CustomAssets.male,
                          isSelected: controller.isMaleSelected,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Male',
                          style: AppFonts.poppinsMedium(
                            fontSize: 16,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30.h),

                // Female Selection
                Obx(
                  () => GestureDetector(
                    onTap: controller.selectFemale,
                    child: Column(
                      children: [
                        _buildGenderCard(
                          image: CustomAssets.female,
                          isSelected: controller.isFemaleSelected,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Female',
                          style: AppFonts.poppinsMedium(
                            fontSize: 16,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Login to your Account Button
                Obx(
                  () => CustomButton(
                    label: 'Login to your Account',
                    onPressed: () => controller.onLoginToAccountPressed(context),
                    isLoading: controller.isLoading.value,
                    height: 56.h,
                  ),
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard({
    required String image,
    required bool isSelected,
  }) {
    return Container(
      width: 140.w,
      height: 140.h,
      padding: EdgeInsets.all(15.w),
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.64, 1.00),
          end: Alignment(0.47, 0.00),
          colors: isSelected
              ? [const Color(0xFFAC3EC1), const Color(0xFF00C1C0)]
              : [
                  const Color(0xFFAC3EC1).withValues(alpha: 0.3),
                  const Color(0xFF00C1C0).withValues(alpha: 0.3)
                ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 40,
            offset: Offset(0, 30),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        width: 110.w,
        height: 110.h,
        decoration: ShapeDecoration(
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}
