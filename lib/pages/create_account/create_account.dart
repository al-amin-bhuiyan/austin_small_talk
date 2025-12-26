import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/number_symbols_data.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_fonts/app_fonts.dart';
import '../../view/custom_button/custom_button.dart';
import '../../view/custom_text_field/custom_text_field.dart';
import 'create_account_controller.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   final controller =Get.find<CreateAccountController>();

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
                  SizedBox(height: 20.h),

                  // Logo
                  Image.asset(
                    CustomAssets.splashLogo,
                    width: 80.w,
                    height: 80.h,
                  ),



                  SizedBox(height: 32.h),

                  // Title
                  Text(
                    'Create your Free Account',
                    style: AppFonts.poppinsBold(
                      fontSize: 18,
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

                  // Username Field
                  CustomTextField(
                    label: 'Username',
                    hintText: 'Bonnie Green',
                    controller: controller.usernameController,
                    textInputAction: TextInputAction.next,
                    validator: controller.validateUsername,
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

                  // Birth Date Label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Birth Date',
                      style: AppFonts.poppinsSemiBold(
                        fontSize: 14,
                        color: AppColors.whiteColor.withAlpha(230),
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Day Dropdown
                  Obx(
                    () => _buildDropdown(
                      hint: 'Day',
                      value: controller.selectedDay.value.isEmpty ? null : controller.selectedDay.value,
                      items: controller.getDaysList(),
                      onChanged: (value) {
                        if (value != null) controller.setDay(value);
                      },
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Month Dropdown
                  Obx(
                    () => _buildDropdown(
                      hint: 'Month',
                      value: controller.selectedMonth.value.isEmpty ? null : controller.selectedMonth.value,
                      items: controller.months,
                      onChanged: (value) {
                        if (value != null) controller.setMonth(value);
                      },
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Year Dropdown
                  Obx(
                    () => _buildDropdown(
                      hint: 'Year',
                      value: controller.selectedYear.value.isEmpty ? null : controller.selectedYear.value,
                      items: controller.getYearsList(),
                      onChanged: (value) {
                        if (value != null) controller.setYear(value);
                      },
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Terms and Conditions Checkbox
                  Obx(
                    () => Row(
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
                                text: 'I accept the ',
                                style: AppFonts.poppinsRegular(
                                  fontSize: 12,
                                  color: AppColors.whiteColor.withAlpha(200),
                                ),
                                children: [
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: controller.onTermsPressed,
                                      child: Text(
                                        'Terms and Conditions',
                                        style: AppFonts.poppinsMedium(
                                          fontSize: 12,
                                          color: AppColors.deepblue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
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

                  SizedBox(height: 16.h),

                  // Create Account Button
                  Obx(
                    () => CustomButton(
                      label: 'Create account',
                      onPressed: ()=> controller.onCreateAccountPressed(context),
                      isLoading: controller.isLoading.value,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Already have an account
                  GestureDetector(
                    onTap:()=>controller.onLoginPressed(context),
                    child: Text(
                      'Already have an account?',
                      style: AppFonts.poppinsMedium(
                        fontSize: 14,
                        color: Color(0xFF00D9FF),
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

  /// Build dropdown widget
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.whiteColor.withAlpha(31),
          width: 1.w,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: AppFonts.poppinsRegular(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey[600],
            size: 24.sp,
          ),
          style: AppFonts.poppinsRegular(
            fontSize: 16,
            color: Colors.black,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
