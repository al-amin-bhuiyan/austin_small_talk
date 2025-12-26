import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../../core/app_route/app_path.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_fonts/app_fonts.dart';
import '../../utils/text_animation/text_animation.dart';
import '../../view/custom_button/custom_button.dart';
import '../../view/custom_text_field/custom_text_field.dart';
import 'forget_password_controller.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgetPasswordController>();

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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40.h),

                  // Logo
                  Image.asset(
                    CustomAssets.splashLogo,
                    width: 100.w,
                    height: 100.h,
                  ),

                  SizedBox(height: 32.h),

                  // Animated description text with account recovery link
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedTextWidget(
                      richText: TextSpan(
                        text: "We'll email you instructions to reset your password. If you don't have access to your email anymore, you can try ",
                        style: AppFonts.poppinsRegular(
                          fontSize: 17,
                          color: AppColors.whiteColor.withAlpha(200),
                          height: 1.5,
                        ),
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: controller.onAccountRecoveryPressed,
                              child: Text(
                                'account recovery',
                                style: AppFonts.poppinsMedium(
                                  fontSize: 14,
                                  color: Color(0xFF00D9FF),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                          TextSpan(
                            text: '.',
                            style: AppFonts.poppinsRegular(
                              fontSize: 14,
                              color: AppColors.whiteColor.withAlpha(200),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.left,
                      duration: const Duration(milliseconds: 800),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Email Field
                  CustomTextField(
                    label: 'Email',
                    hintText: 'Enter your email',
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    validator: controller.validateEmail,
                  ),

                  SizedBox(height: 20.h),

                  // Terms and Privacy Policy Checkbox
                  Obx(
                    () => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: Checkbox(
                            value: controller.acceptTerms.value,
                            onChanged: (_) => controller.toggleTerms(),
                            fillColor: WidgetStateProperty.resolveWith(
                              (states) {
                                if (states.contains(WidgetState.selected)) {
                                  return AppColors.whiteColor;
                                }
                                return Colors.transparent;
                              },
                            ),
                            checkColor: AppColors.blackColor,
                            side: BorderSide(
                              color: AppColors.whiteColor.withAlpha(150),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: controller.toggleTerms,
                            child: RichText(
                              text: TextSpan(
                                text: 'I am agree to Small Talk ',
                                style: AppFonts.poppinsRegular(
                                  fontSize: 12,
                                  color: AppColors.whiteColor.withAlpha(200),
                                ),
                                children: [
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: controller.onTermsPressed,
                                      child: Text(
                                        'Terms of Use',
                                        style: AppFonts.poppinsMedium(
                                          fontSize: 12,
                                          color: Color(0xFF1E90FF), // Deep blue
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' and ',
                                    style: AppFonts.poppinsRegular(
                                      fontSize: 12,
                                      color: AppColors.whiteColor.withAlpha(200),
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: controller.onPrivacyPolicyPressed,
                                      child: Text(
                                        'Privacy Policy',
                                        style: AppFonts.poppinsMedium(
                                          fontSize: 12,
                                          color: Color(0xFF1E90FF), // Deep blue
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: '.',
                                    style: AppFonts.poppinsRegular(
                                      fontSize: 12,
                                      color: AppColors.whiteColor.withAlpha(200),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Forget Password and Return to Login Buttons
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Obx(
                        () => CustomButton(
                          label: 'Forget password',
                          width: 180.w,
                          onPressed:()=> controller.onForgetPasswordPressed(context),
                          isLoading: controller.isLoading.value,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      // Return to Login Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push(AppPath.login),
                          child: Text(
                            'Return to login',
                            style: AppFonts.poppinsMedium(
                              fontSize: 14,
                              color: Color(0xFF00D9FF),
                            ),
                          ),
                        ),
                      ),
                    ],
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
