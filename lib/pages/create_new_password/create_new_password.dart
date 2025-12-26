import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_fonts/app_fonts.dart';
import '../../view/custom_button/custom_button.dart';
import '../../view/custom_text_field/custom_text_field.dart';
import 'create_new_password_controller.dart';

class CreateNewPasswordScreen extends StatelessWidget {
  const CreateNewPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateNewPasswordController>();

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
            child: Form(
              key: controller.formKey,
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
                    'Create new password',
                    style: AppFonts.poppinsBold(
                      fontSize: 18.sp,
                      color: AppColors.whiteColor,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Description
                  Text(
                    'Your new password must be different from previous used passwords.',
                    style: AppFonts.poppinsRegular(
                      fontSize: 16,
                      color: AppColors.whiteColor.withAlpha(200),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // New Password Field
                  CustomTextField(
                    label: 'New Password',
                    hintText: 'Enter new password',
                    controller: controller.newPasswordController,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    validator: controller.validateNewPassword,
                  ),

                  SizedBox(height: 16.h),

                  // Confirm Password Field
                  CustomTextField(
                    label: 'Confirm Password',
                    hintText: 'Confirm your password',
                    controller: controller.confirmPasswordController,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    validator: controller.validateConfirmPassword,
                  ),

                  SizedBox(height: 32.h),

                  // Terms and Conditions Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: Checkbox(
                            value: controller.acceptTerms.value,
                            onChanged: (_) => controller.toggleTerms(),
                            activeColor: AppColors.deepblue,
                            checkColor: AppColors.whiteColor,
                            side: BorderSide(
                              color: AppColors.whiteColor.withAlpha(100),
                              width: 1.5.w,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'I agree to Small Talk ',
                            style: AppFonts.poppinsRegular(
                              fontSize: 14,
                              color: AppColors.whiteColor.withAlpha(200),
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms of Use',
                                style: AppFonts.poppinsMedium(
                                  fontSize: 14,
                                  color: AppColors.deepblue,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = controller.onTermsPressed,
                              ),
                              TextSpan(
                                text: ' and ',
                                style: AppFonts.poppinsRegular(
                                  fontSize: 14,
                                  color: AppColors.whiteColor.withAlpha(200),
                                ),
                              ),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: AppFonts.poppinsMedium(
                                  fontSize: 14,
                                  color: AppColors.deepblue,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = controller.onPrivacyPolicyPressed,
                              ),
                              TextSpan(
                                text: '.',
                                style: AppFonts.poppinsRegular(
                                  fontSize: 14,
                                  color: AppColors.whiteColor.withAlpha(200),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Forget Password Button
                  Obx(
                    () => CustomButton(
                      label: 'Forget Password',
                      onPressed: () => controller.onForgetPasswordPressed(context),
                      isLoading: controller.isLoading.value,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Support Text
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'If you still need help, contact ',
                        style: AppFonts.poppinsRegular(
                          fontSize: 14,
                          color: AppColors.whiteColor.withAlpha(200),
                        ),
                        children: [
                          TextSpan(
                            text: 'Small Talk Support',
                            style: AppFonts.poppinsMedium(
                              fontSize: 14,
                              color: AppColors.deepblue,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = controller.onSupportPressed,
                          ),
                          TextSpan(
                            text: '.',
                            style: AppFonts.poppinsRegular(
                              fontSize: 14,
                              color: AppColors.whiteColor.withAlpha(200),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
