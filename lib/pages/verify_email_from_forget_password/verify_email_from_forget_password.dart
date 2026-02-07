import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_fonts/app_fonts.dart';
import '../../view/custom_button/custom_button.dart';
import 'verify_email_from_forget_password_controller.dart';

class VerifyEmailFromForgetPasswordScreen extends StatelessWidget {
  const VerifyEmailFromForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VerifyEmailFromForgetPasswordController>();

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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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

                SizedBox(height: 20.h),

                // Title
                Text(
                  textAlign: TextAlign.start,
                  'Verify your email address',
                  style: AppFonts.poppinsBold(
                    fontSize: 18.sp,
                    color: AppColors.whiteColor,
                  ),
                ),

                SizedBox(height: 10.h),

                // Description
                Obx(
                  () => RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      text: 'We emailed you a six-digit code to ',
                      style: AppFonts.poppinsRegular(
                        fontSize: 14,
                        color: AppColors.whiteColor.withAlpha(200),
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: controller.email.value,
                          style: AppFonts.poppinsSemiBold(
                            fontSize: 14,
                            color: AppColors.whiteColor,
                            height: 1.5,
                          ),
                        ),
                        TextSpan(
                          text: '. Enter the code below to confirm your email address.',
                          style: AppFonts.poppinsRegular(
                            fontSize: 14,
                            color: AppColors.whiteColor.withAlpha(200),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30.h),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: SizedBox(
                        width: 50.w,
                        height: 50.h,
                        child: _buildOtpBox(
                          context: context,
                          controller: controller.otpControllers[index],
                          focusNode: controller.focusNodes[index],
                          index: index,
                          otpController: controller,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Paste Code Button
                Center(
                  child: GestureDetector(
                    onTap: () => controller.handlePasteFromClipboard(context),
                    child: Text(
                      'Paste Code',
                      style: AppFonts.poppinsSemiBold(
                        fontSize: 14,
                        color: AppColors.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // Help text
                Center(
                  child: Text(
                    'Make sure to keep this window open while check your inbox',
                    textAlign: TextAlign.center,
                    style: AppFonts.poppinsRegular(
                      fontSize: 12.9.sp,
                      color: AppColors.whiteColor.withAlpha(200),
                      height: 1.5,
                    ),
                  ),
                ),

                SizedBox(height: 36.h),

                // Verify Button
                Obx(
                  () => CustomButton(
                    label: 'Verify',
                    onPressed: () => controller.onVerifyPressed(context),
                    isLoading: controller.isLoading.value,
                  ),
                ),

                SizedBox(height: 24.h),

                // Resend OTP Section
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive any code? ",
                        style: AppFonts.poppinsRegular(
                          fontSize: 14,
                          color: AppColors.whiteColor.withAlpha(200),
                        ),
                      ),
                      Obx(
                        () => GestureDetector(
                          onTap: !controller.isResending.value
                              ? () => controller.onResendCode(context)
                              : null,
                          child: Text(
                            controller.isResending.value
                                ? 'Resend in ${controller.resendTimer.value}s'
                                : 'Resend OTP',
                            style: AppFonts.poppinsSemiBold(
                              fontSize: 14,
                              color: controller.isResending.value
                                  ? AppColors.whiteColor.withAlpha(150)
                                  : AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
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

  /// Build single OTP input box
  Widget _buildOtpBox({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required int index,
    required VerifyEmailFromForgetPasswordController otpController,
  }) {
    return Obx(() {
      // Check if the field has input from observable state
      final hasInput = otpController.otpValues[index].value.isNotEmpty;
      
      return Container(
        width: 45.w,
        height: 50.h,
        decoration: BoxDecoration(
          color: Color(0xFF1E2A3A), // Dark blue background
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: hasInput ? AppColors.primaryColor : AppColors.whiteColor.withAlpha(50),
            width: 1.5,
          ),
        ),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: AppFonts.poppinsBold(
            fontSize: 24,
            color: AppColors.whiteColor,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1), // STRICT: Only 1 digit per field
          ],
          onChanged: (value) {
            // Handle single digit entry or backspace
            if (value.length <= 1) {
              otpController.onDigitChanged(index, value, context);
            }
          },
          onTap: () {
            // Select all text when tapped for easy replacement
            controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            );
          },
        ),
      );
    });
  }
}
