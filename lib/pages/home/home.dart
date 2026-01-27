import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_fonts/app_fonts.dart';
import '../../utils/nav_bar/nav_bar_controller.dart';
import 'home_controller.dart';

/// Home Screen - Main screen with scenario selection
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final navBarController = Get.find<NavBarController>();
    
    // Set nav bar to home tab (index 0) after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navBarController.selectedIndex.value != 0) {
        navBarController.selectedIndex.value = 0;
      }
    });

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
      // ✅ Nav bar removed - MainNavigation provides it
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
    return Obx(() {
      // Show loading indicator while fetching
      if (controller.isLoading.value && controller.dailyScenarios.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      }

      // Get scenarios from controller
      final scenarios = controller.dailyScenarios;

      // If no scenarios, show empty state
      if (scenarios.isEmpty) {
        return Center(
          child: Text(
            'No scenarios available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
            ),
          ),
        );
      }

      // Build grid with scenarios
      return Column(
        children: [
          // First row
          if (scenarios.length > 0)
            Row(
              children: [
                Expanded(
                  child: _buildScenarioCard(
                    icon: scenarios[0].emoji,
                    title: scenarios[0].title,
                    description: scenarios[0].description,
                    isEmoji: true,
                    onTap: () => controller.onScenarioTap(
                      context,
                      scenarios[0].scenarioId,
                      scenarios[0].emoji,
                      scenarios[0].title,
                      scenarios[0].description,
                    ),
                  ),
                ),
                if (scenarios.length > 1) ...[
                  SizedBox(width: 15.w),
                  Expanded(
                    child: _buildScenarioCard(
                      icon: scenarios[1].emoji,
                      title: scenarios[1].title,
                      description: scenarios[1].description,
                      isEmoji: true,
                      onTap: () => controller.onScenarioTap(
                        context,
                        scenarios[1].scenarioId,
                        scenarios[1].emoji,
                        scenarios[1].title,
                        scenarios[1].description,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          // Second row
          if (scenarios.length > 2) ...[
            SizedBox(height: 15.h),
            Row(
              children: [
                Expanded(
                  child: _buildScenarioCard(
                    icon: scenarios[2].emoji,
                    title: scenarios[2].title,
                    description: scenarios[2].description,
                    isEmoji: true,
                    onTap: () => controller.onScenarioTap(
                      context,
                      scenarios[2].scenarioId,
                      scenarios[2].emoji,
                      scenarios[2].title,
                      scenarios[2].description,
                    ),
                  ),
                ),
                if (scenarios.length > 3) ...[
                  SizedBox(width: 15.w),
                  Expanded(
                    child: _buildScenarioCard(
                      icon: scenarios[3].emoji,
                      title: scenarios[3].title,
                      description: scenarios[3].description,
                      isEmoji: true,
                      onTap: () => controller.onScenarioTap(
                        context,
                        scenarios[3].scenarioId,
                        scenarios[3].emoji,
                        scenarios[3].title,
                        scenarios[3].description,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      );
    });
  }

// This widget defines the structure of a single scenario card.
  Widget _buildScenarioCard({
    required String icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    bool isEmoji = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 177.w,
        height: 158.h,
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
                  child: isEmoji
                      ? Text(
                          icon,
                          style: TextStyle(
                            fontSize: 20.sp,
                          ),
                        )
                      : SvgPicture.asset(
                          icon,
                          width: 20.w,
                          height: 20.h,
                        ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFFF6F6F6),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.05,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                  fontSize: 12.sp,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildUserProfile(controller),
          _buildNotificationIcon(controller, context),
        ],
      ),
    );
  }

  Widget _buildUserProfile(HomeController controller) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            final imageUrl = controller.userProfileImage.value;
            return Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 50.w,
                        height: 50.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30.sp,
                          );
                        },
                      )
                    : Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30.sp,
                      ),
              ),
            );
          }),
          SizedBox(width: 5.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hi,',
                  style: AppFonts.poppinsRegular(
                    fontSize: 12.sp,
                    color: AppColors.whiteColor.withAlpha(200),
                  ),
                ),
                Obx(
                  () => Text(
                    controller.userName.value,
                    style: AppFonts.poppinsSemiBold(
                      fontSize: 14.sp,
                      color: AppColors.whiteColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
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
          color: Colors.black.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: Offset(0, 4),
              blurRadius: 6,
              spreadRadius: 3,
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