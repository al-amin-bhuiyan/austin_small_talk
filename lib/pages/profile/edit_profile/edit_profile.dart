import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/custom_assets/custom_assets.dart';
import '../../../utils/app_colors/app_colors.dart';
import '../../../utils/app_fonts/app_fonts.dart';
import '../../../utils/toast_message/toast_message.dart';
import '../../../view/custom_back_button/custom_back_button.dart';
import '../../../view/custom_button/custom_button.dart';
import 'edit_profile_controller.dart';

/// Edit Profile Screen
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileController());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(CustomAssets.backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(context),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 24.h),
                      
                      // Profile Image Section
                      _buildProfileImageSection(controller),
                      
                      SizedBox(height: 8.h),
                      
                      // Name
                      Obx(
                        () => Text(
                          controller.userName.value,
                          style: AppFonts.poppinsSemiBold(
                            fontSize: 18,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 4.h),
                      
                      // Email
                      Obx(
                        () => Text(
                          controller.userEmail.value,
                          style: AppFonts.poppinsRegular(
                            fontSize: 14,
                            color: AppColors.whiteColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 32.h),
                      
                      // Personal Information Section
                      _buildPersonalInformationSection(context, controller),
                      
                      SizedBox(height: 32.h),
                      
                      // Save Button
                      Obx(() => CustomButton(
                        label: 'Save',
                        onPressed:()=> controller.saveProfile(context),
                        isLoading: controller.isLoading.value,
                      )),
                      
                      SizedBox(height: 100.h), // Space for nav bar
                    ],
                  ),
                ),
              ),
              
              // Navigation Bar
              // CustomNavBar(controller: navBarController),
              // SizedBox(height: 34.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Build App Bar
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          // Back Button
          CustomBackButton(
            onPressed: () {
              // Navigate back to profile page explicitly
              context.go('/profile');
            },
          ),
          
          Expanded(
            child: Center(
              child: Text(
                'Edit Profile',
                style: AppFonts.poppinsSemiBold(
                  fontSize: 18,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ),
          
          // Spacer for alignment
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  /// Build Profile Image Section
  Widget _buildProfileImageSection(EditProfileController controller) {
    return Obx(() {
      final hasLocalImage = controller.profileImage.value != null;
      final networkImageUrl = controller.profileImageUrl.value;
      
      return Stack(
        children: [
          // Profile Image
          Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.whiteColor.withValues(alpha: 0.3),
                width: 2.w,
              ),
            ),
            child: ClipOval(
              child: hasLocalImage
                  ? Image.file(
                      File(controller.profileImage.value!),
                      fit: BoxFit.cover,
                    )
                  : networkImageUrl.isNotEmpty
                      ? Image.network(
                          networkImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              CustomAssets.person,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          CustomAssets.person,
                          fit: BoxFit.cover,
                        ),
            ),
          ),
          
          // Camera Icon
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => controller.pickImageFromGallery(),
              child: Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white, Colors.white,
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.blackColor,
                    width: 1.w,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color:Colors.black,
                  size: 16.sp,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Build Personal Information Section
  Widget _buildPersonalInformationSection(
    BuildContext context,
    EditProfileController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          'Personal Information',
          style: AppFonts.poppinsSemiBold(
            fontSize: 16,
            color: AppColors.whiteColor,
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // Full Name Field
        _buildFieldLabel('Full Name'),
        SizedBox(height: 8.h),
        Container(
          height: 47.h,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
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
            controller: controller.fullNameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            autofocus: false,
            enabled: true,
            readOnly: false,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(
              color: const Color(0xFFF6F6F6),
              fontSize: 14.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1.05,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.60),
                fontSize: 14.sp,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 1.05,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            ),
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // Email Address Field
        _buildFieldLabel('Email Address'),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () {
            ToastMessage.info('Email address cannot be edited');
          },
          child: Container(
            height: 47.h,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              shadows: [
                BoxShadow(
                  color: Color(0x28000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                  spreadRadius: 0,
                )
              ],
            ),
            child: AbsorbPointer(
              child: TextField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: false, // Make email field read-only
                style: TextStyle(
                  color: const Color(0xFFF6F6F6),
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  height: 1.05,
                ),
                decoration: InputDecoration(
                  hintText: 'sophia@gmail.com',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.60),
                    fontSize: 14.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.05,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                ),
              ),
            ),
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // Date of Birth Field
        Row(
          children: [
            Text(
              'Date of Birth',
              style: AppFonts.poppinsRegular(
                fontSize: 14,
                color: AppColors.whiteColor.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => controller.selectDateOfBirth(context),
          child: AbsorbPointer(
            child: Container(
              height: 47.h,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                shadows: [
                  BoxShadow(
                    color: Color(0x28000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 20.sp,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller.dateOfBirthController,
                      style: TextStyle(
                        color: const Color(0xFFF6F6F6),
                        fontSize: 14.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.05,
                      ),
                      decoration: InputDecoration(
                        hintText: '12/11/2001',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.60),
                          fontSize: 14.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 1.05,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // Gender Field
        _buildFieldLabel('Gender'),
        SizedBox(height: 8.h),
        Obx(() => _buildGenderDropdown(controller)),
      ],
    );
  }

  /// Build Field Label
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppFonts.poppinsRegular(
        fontSize: 14,
        color: AppColors.whiteColor.withValues(alpha: 0.8),
      ),
    );
  }

  /// Build Gender Dropdown
  Widget _buildGenderDropdown(EditProfileController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedGender.value,
          isExpanded: true,
          dropdownColor: Color(0xFF1F2937),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.whiteColor.withValues(alpha: 0.6),
          ),
          style: AppFonts.poppinsRegular(
            fontSize: 14,
            color: AppColors.whiteColor,
          ),
          items: controller.genderOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: controller.changeGender,
        ),
      ),
    );
  }
}