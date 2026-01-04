import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_fonts/app_fonts.dart';
import '../../utils/nav_bar/nav_bar.dart';
import '../../utils/nav_bar/nav_bar_controller.dart';
import 'home_controller.dart';

/// Home Screen - Main screen with scenario selection
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final navBarController = Get.find<NavBarController>();
    
    // Set nav bar to home tab (index 0)
    navBarController.selectedIndex.value = 0;

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
              // Header Section
              _buildHeader(controller, context),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        _buildTitle(),
                        SizedBox(height: 8.h),
                        _buildSubtitle(),
                        SizedBox(height: 24.h),
                        _buildSectionTitle(),
                        SizedBox(height: 16.h),
                        _buildScenarioGrid(controller, context),
                        SizedBox(height: 12.h),
                        _buildCreateOwnScenario(controller, context),
                     //   SizedBox(height: 12.h),
                      ],
                    ),
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

  Widget _buildTitle() {
    return Text(
      'Small Talk',
      style: AppFonts.poppinsBold(
        fontSize: 22,
        color: AppColors.whiteColor,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Improve your real-life\ncommunication skills',
      style: AppFonts.poppinsRegular(
        fontSize: 16,
        color: AppColors.whiteColor.withAlpha(230),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Text(
      'Choose a Scenario to Practice',
      style: AppFonts.poppinsSemiBold(
        fontSize: 16,
        color: AppColors.whiteColor,
      ),
    );
  }


  // This widget builds the scenario grid with multiple scenario cards.
  Widget _buildScenarioGrid(HomeController controller, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildScenarioCard(
                icon: CustomAssets.plan,
                title: 'On a Plane',
                description: 'Talk naturally with someone sitting next to you.',
                onTap: () => controller.onScenarioTap(context, 'Plane', CustomAssets.plan, 'Plane'),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: _buildScenarioCard(
                icon: CustomAssets.social_event,
                title: 'Social Event',
                description: 'Practice conversation at parties or networking.',
                onTap: () => controller.onScenarioTap(context, 'Social Event', CustomAssets.social_event, 'Social Event'),
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        Row(
          children: [
            Expanded(
              child: _buildScenarioCard(
                icon: CustomAssets.workplace,
                title: 'Workplace',
                description: 'Improve your daily professional communication.',
                onTap: () => controller.onScenarioTap(context, 'Workplace', CustomAssets.workplace, 'Workplace'),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: _buildScenarioCard(
                icon: CustomAssets.daily_topic,
                title: 'Daily Topic',
                description: 'A fresh AI-generated scenario every 24 hours.',
                onTap: () => controller.onScenarioTap(context, 'Daily Topic', CustomAssets.daily_topic, 'Daily Topic'),
              ),
            ),
          ],
        ),
      ],
    );
  }

// This widget defines the structure of a single scenario card.
  Widget _buildScenarioCard({
    required String icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 177.w,
        height: 128.h,
        padding: EdgeInsets.all(12.w),
        decoration: ShapeDecoration(
          color: const Color(0x33F6F6F6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x28FFFFFF),
              blurRadius: 6,
              offset: Offset(0, 3),
              spreadRadius: 0,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and title row
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular icon container
                Container(
                  padding: EdgeInsets.all(0.w),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(321.r),
                    ),
                  ),
                  child: SvgPicture.asset(
                    icon,
                    width: 24.w,
                    height: 24.h,

                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFFF6F6F6),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.05,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            // Description text
            SizedBox(
              width: 153.w,
              child: Text(
                description,
                style: TextStyle(
                  color: const Color(0xFFF6F6F6),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.20,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateOwnScenario(HomeController controller, BuildContext context) {
    return GestureDetector(
      onTap: () => controller.onCreateOwnScenario(context),
      child: Container(
        width: 370.w,
        height: 128.h,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: const Color(0x33F6F6F6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          shadows: [
            BoxShadow(
              color: Color(0x28FFFFFF),
              blurRadius: 6,
              offset: Offset(0, 3),
              spreadRadius: 0,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF576875),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(321),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Container(
                        width: 24.w, // You may use screen util for responsive width
                        height: 24.h, // You may use screen util for responsive height
                        decoration: BoxDecoration(
                          color: Colors.transparent, // Or any color you'd like
                          borderRadius: BorderRadius.circular(12.r), // Optional: if you want rounded corners
                        ),
                        clipBehavior: Clip.hardEdge, // or Clip.antiAlias based on your preference
                        child: SvgPicture.asset(
                          CustomAssets.create_your_own_scenario,
                          width: 24.w,
                          height: 24.h,
                        ),
                      )

                    ],
                  ),
                ),
                Text(
                  'Create Your Own Scenario',
                  style: TextStyle(
                    color: const Color(0xFFF6F6F6),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 1.05,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 346,
              child: Text(
                'Type any situation ( e.g., “Job interview for nurse”) and practice instantly.',
                style: TextStyle(
                  color: const Color(0xFFF6F6F6),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  height: 1.20,
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildHeader(HomeController controller, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          _buildUserProfile(controller),
          const Spacer(),
          _buildNotificationIcon(controller, context),
        ],
      ),
    );
  }

  Widget _buildUserProfile(HomeController controller) {
    return Container(
      padding: EdgeInsets.all(2.w),

      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.asset(
              CustomAssets.person,
              width: 50.w,
              height: 50.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50.w,
                  height: 50.h,
                  color: Colors.grey,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30.sp,
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hi,',
                style: AppFonts.poppinsRegular(
                  fontSize: 12,
                  color: AppColors.whiteColor.withAlpha(200),
                ),
              ),
              Obx(
                () => Text(
                  controller.userName.value,
                  style: AppFonts.poppinsSemiBold(
                    fontSize: 14,
                    color: AppColors.whiteColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10.w),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(HomeController controller, BuildContext context) {
    return GestureDetector(
      onTap: () => controller.onNotificationTap(context),
      child: Container(
        width: 48.w,
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Shadow color
              offset: Offset(0, 4), // Shadow position
              blurRadius: 6, // Shadow blur
              spreadRadius: 3, // How much the shadow spreads
            ),
          ],
        ),
        child: Icon(
          Icons.notifications_none_rounded,
          color: AppColors.whiteColor,
          size: 24.sp,
        ),
      ),
    );
  }

}
