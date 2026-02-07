import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../utils/nav_bar/nav_bar_controller.dart';
import '../../../core/custom_assets/custom_assets.dart';
import '../../../view/custom_back_button/custom_back_button.dart';
import 'create_scenario_controller.dart';

class CreateScenarioScreen extends StatelessWidget {
  const CreateScenarioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navBarController = Get.find<NavBarController>();

    return GetBuilder<CreateScenarioController>(
      init: CreateScenarioController(),
      autoRemove: true,
      builder: (controller) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              // Ensure we stay on home tab (index 0) after back navigation
              navBarController.returnToTab(0);
            }
          },
          child: Scaffold(
            extendBody: true,
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
                    // App Bar
                    _buildAppBar(context),
                    SizedBox(height: 20.h),
                    // Main Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Scenario Title
                            _buildScenarioTitle(controller),
                            
                            SizedBox(height: 16.h),
                            
                            // Description
                            _buildDescription(controller),
                            
                            SizedBox(height: 16.h),
                            
                            // Difficulty Level
                            _buildDifficultyLevel(controller),
                            
                            SizedBox(height: 122.h),
                            
                            // Start Scenario Button
                            _buildStartScenarioButton(controller, context),
                            
                            SizedBox(height: 100.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // bottomNavigationBar: SafeArea(
            //   child: CustomNavBar(controller: navBarController),
            // ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomBackButton(
            onPressed: () {
              // Ensure home tab (index 0) stays selected
              final navController = Get.find<NavBarController>();
              navController.returnToTab(0);
              Navigator.pop(context);
            },
            width: 35,
            height: 35,
            borderRadius: 17,
            size: 24,
          ),
          SizedBox(width: 41.w),
          Text(
            'Create Your Own Scenario',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioTitle(CreateScenarioController controller) {
    return Obx(() => Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Scenario Title',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  height: 1.05,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
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
              onChanged: controller.updateTitle,
              style: TextStyle(
                color: const Color(0xFFF6F6F6),
                fontSize: 14.sp,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 1.05,
              ),
              decoration: InputDecoration(
                hintText: 'Write scenario title (min 3 characters)',
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
          if (controller.scenarioTitle.value.isNotEmpty && 
              controller.scenarioTitle.value.trim().length < 3) ...[
            SizedBox(height: 4.h),
            Text(
              'Title must be at least 3 characters',
              style: TextStyle(
                color: Colors.red.withValues(alpha: 0.8),
                fontSize: 12.sp,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ],
      ),
    ));
  }

  Widget _buildDescription(CreateScenarioController controller) {
    return Obx(() => Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Description',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  height: 1.05,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            height: 95.h,
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
              onChanged: controller.updateDescription,
              maxLines: 4,
              style: TextStyle(
                color: const Color(0xFFF6F6F6),
                fontSize: 14.sp,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 1.05,
              ),
              decoration: InputDecoration(
                hintText: 'Write details about the situation (min 10 characters)...',
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
          if (controller.description.value.isNotEmpty && 
              controller.description.value.trim().length < 10) ...[
            SizedBox(height: 4.h),
            Text(
              'Description must be at least 10 characters',
              style: TextStyle(
                color: Colors.red.withValues(alpha: 0.8),
                fontSize: 12.sp,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ],
      ),
    ));
  }

  Widget _buildDifficultyLevel(CreateScenarioController controller) {
    return Container(
      width: double.infinity,
      height:  115.h,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Difficulty Level',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              height: 1.05,
            ),
          ),
          SizedBox(height: 10.h),
          Obx(() => Container(
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
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: DropdownButton<String>(
              value: controller.difficultyLevel.value,
              isExpanded: true,
              underline: SizedBox(),
              dropdownColor: Color(0xFF1A1A3E),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
              style: TextStyle(
                color: const Color(0xFFF6F6F6),
                fontSize: 14.sp,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 1.05,
              ),
              items: controller.difficultyOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.updateDifficulty(newValue);
                }
              },
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStartScenarioButton(CreateScenarioController controller, BuildContext context) {
    return Obx(() => Center(
      child: GestureDetector(
        onTap: controller.isLoading.value ? null : () => controller.startScenario(context),
        child: Container(
          width: 284.w,
          height: 41.h,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(CustomAssets.start_conversation_button_background),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: controller.isLoading.value
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Start Scenario',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    ));
  }
}
