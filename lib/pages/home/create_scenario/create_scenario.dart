import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../utils/nav_bar/nav_bar.dart';
import '../../../utils/nav_bar/nav_bar_controller.dart';
import '../../../core/custom_assets/custom_assets.dart';
import '../../../view/custom_back_button/custom_back_button.dart';
import 'create_scenario_controller.dart';

class CreateScenarioScreen extends StatelessWidget {
  const CreateScenarioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateScenarioController());
    final navBarController = Get.find<NavBarController>();

    return Scaffold(
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
                      
                      SizedBox(height: 16.h),
                      
                      // AI Setting
                      _buildAISetting(controller),
                      
                      SizedBox(height: 32.h),
                      
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
      
      bottomNavigationBar: SafeArea(
        child: CustomNavBar(controller: navBarController),
      ),
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
            onPressed: () => Navigator.pop(context),
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
    return Container(
      width: double.infinity,
      height: 115.h,
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
            'Scenario Title',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              height: 1.05,
            ),
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
                hintText: 'Write scenario',
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
    );
  }

  Widget _buildDescription(CreateScenarioController controller) {
    return Container(
      width: double.infinity,
      height: 163.h,
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
            'Description',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              height: 1.05,
            ),
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
                hintText: 'Write a few details about the situation...',
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
    );
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

  Widget _buildAISetting(CreateScenarioController controller) {
    return Container(
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
          Text(
            'AI Setting',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              height: 1.05,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Conversation Length',
            style: TextStyle(
              color: const Color(0xFFF6F6F6),
              fontSize: 14.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1.05,
            ),
          ),
          SizedBox(height: 16.h),
          Obx(() => SizedBox(
            width: 300.w,
            child: Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 8.h,
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: 6.r,
                    ),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 14.r),
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: Colors.white,
                  ),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Background track (gray)
                      Container(
                        width: 320.w,
                        height: 8.h,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFEDEFF2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      // Active track with gradient
                      Container(
                        width: 320.w * controller.conversationLength.value,
                        height: 8.h,
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(0.00, 0.50),
                            end: Alignment(1.00, 0.50),
                            colors: [
                              const Color(0xFF4C98A6),
                              const Color(0xFF4B64A0),
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      // Slider on top
                      Slider(
                        value: controller.conversationLength.value,
                        onChanged: controller.updateConversationLength,
                        min: 0.0,
                        max: 1.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          SizedBox(height: 8.h),
          SizedBox(
            width: 320.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Start',
                  style: TextStyle(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 12.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                ),
                Text(
                  'End',
                  style: TextStyle(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 12.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartScenarioButton(CreateScenarioController controller, BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => controller.startScenario(context),
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
            child: Text(
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
    );
  }
}
