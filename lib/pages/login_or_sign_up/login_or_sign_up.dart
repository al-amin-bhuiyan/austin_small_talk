import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_fonts/app_fonts.dart';
import '../../view/custom_button/custom_button.dart';
import '../../view/custom_text_field/custom_text_field.dart';
import 'login_or_sign_up_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

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



                  SizedBox(height: 16.h),

                  // Title
                  Text(
                    'Log in or signup',
                    style: AppFonts.poppinsBold(
                      fontSize: 18.sp,
                      color: AppColors.whiteColor,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Email Field
                  CustomTextField(
                    label: 'Email',
                    hintText: 'name@example.com',
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: controller.validateEmail,
                  ),

                  SizedBox(height: 20.h),

                  // Password Field
                  CustomTextField(
                    label: 'Password',
                    hintText: '••••••••••',
                    controller: controller.passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: controller.validatePassword,
                  ),

                  SizedBox(height: 20.h),

                  // Remember me & Forgot password row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remember me checkbox
                      Obx(
                        () => InkWell(
                          onTap: controller.toggleRememberMe,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: Checkbox(
                                  value: controller.rememberMe.value,
                                  onChanged: (_) => controller.toggleRememberMe(),
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
                              Text(
                                'Remember me',
                                style: AppFonts.poppinsRegular(
                                  fontSize: 12,
                                  color: AppColors.whiteColor.withAlpha(200),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Forgot password
                      InkWell(
                        onTap:()=> controller.onForgotPasswordPressed(context),
                        child: Text(
                          'Forgot password?',
                          style: AppFonts.poppinsMedium(
                            fontSize: 12,
                            color: AppColors.deepblue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Continue Button
                  Obx(
                    () => CustomButton(
                      label: 'Continue',
                      onPressed:()=> controller.onLoginPressed(context),
                      isLoading: controller.isLoading.value,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Don't have an account row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account yet? ',
                        style: AppFonts.poppinsRegular(
                          fontSize: 12,
                          color: AppColors.whiteColor.withAlpha(180),
                        ),
                      ),
                      InkWell(
                        onTap:() =>controller.onSignUpPressed(context),
                        child: Text(
                          'Sign up',
                          style: AppFonts.poppinsSemiBold(
                            fontSize: 12,
                            color: AppColors.deepblue           ,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 32.h),

                  // OR divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.whiteColor.withAlpha(80),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'or',
                          style: AppFonts.poppinsRegular(
                            fontSize: 12,
                            color: AppColors.whiteColor.withAlpha(150),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.whiteColor.withAlpha(80),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Google Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: OutlinedButton(
                      onPressed: ()=>controller.onGoogleSignInPressed,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.whiteColor.withAlpha(80),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            CustomAssets.google,
                            width: 24.w,
                            height: 24.h,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Sign up with Google',
                            style: AppFonts.poppinsMedium(
                              fontSize: 14,
                              color: AppColors.whiteColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Apple Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: OutlinedButton(
                      onPressed: controller.onAppleSignInPressed,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.whiteColor.withAlpha(80),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            CustomAssets.apple,
                            width: 24.w,
                            height: 24.h,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Sign up with Apple',
                            style: AppFonts.poppinsMedium(
                              fontSize: 14,
                              color: AppColors.whiteColor,
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
