import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_fonts/app_fonts.dart';
import '../../utils/nav_bar/nav_bar.dart';
import '../../utils/nav_bar/nav_bar_controller.dart';
import 'history_controller.dart';

/// History Screen - Shows chat history with conversations
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();
    final navBarController = Get.find<NavBarController>();
    
    // Set nav bar to history tab (index 1)

    navBarController.selectedIndex.value = 1;

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
              _buildHeader(context),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        _buildSectionTitle(),
                        SizedBox(height: 16.h),
                        _buildSearchBar(controller),
                        SizedBox(height: 20.h),
                        _buildConversationList(controller, context),
                        SizedBox(height: 20.h),
                        _buildNewScenarioButton(controller,context),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          // Back Button
          // GestureDetector(
          //   onTap: () =>context.pop(),
          //   child: Container(
          //     width: 40.w,
          //     height: 40.h,
          //     decoration: BoxDecoration(
          //       color: Colors.white.withValues(alpha: 0.1),
          //       shape: BoxShape.circle,
          //       border: Border.all(
          //         color: Colors.white.withValues(alpha: 0.2),
          //         width: 1.w,
          //       ),
          //     ),
          //     child: Icon(
          //       Icons.arrow_back_ios_new,
          //       color: AppColors.whiteColor,
          //       size: 18.sp,
          //     ),
          //   ),
          // ),
          const Spacer(),
          // Title
          Text(
            'Chat History',
            style: AppFonts.poppinsBold(
              fontSize: 20,
              color: AppColors.whiteColor,
            ),
          ),
          const Spacer(),
          SizedBox(width: 40.w), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Text(
      'Recent Conversations',
      style: AppFonts.poppinsSemiBold(
        fontSize: 16,
        color: AppColors.whiteColor,
      ),
    );
  }

  Widget _buildSearchBar(HistoryController controller) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        style: AppFonts.poppinsRegular(
          fontSize: 14,
          color: AppColors.whiteColor,
        ),
        decoration: InputDecoration(
          hintText: 'Search past conversations',
          hintStyle: AppFonts.poppinsRegular(
            fontSize: 14,
            color: AppColors.whiteColor.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.whiteColor.withValues(alpha: 0.99),
            size: 24.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildConversationList(HistoryController controller, BuildContext context) {
    return Obx(
      () => Column(
        children: controller.filteredConversations.map((conversation) {
          return _buildConversationItem(controller, conversation, context);
        }).toList(),
      ),
    );
  }

  Widget _buildConversationItem(
      HistoryController controller, ConversationItem conversation, BuildContext context) {
    return GestureDetector(
      onTap: () => controller.onConversationTap(conversation.id,  context),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18.r),
              ),
            //  padding: EdgeInsets.all(12.w),
              child: _getConversationIcon(conversation.icon),
            ),
            SizedBox(width: 12.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        conversation.title,
                        style: AppFonts.poppinsSemiBold(
                          fontSize: 16,
                          color: AppColors.whiteColor,
                        ),
                      ),
                      Text(
                        conversation.time,
                        style: AppFonts.poppinsRegular(
                          fontSize: 12,
                          color: AppColors.whiteColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    conversation.preview,
                    style: AppFonts.poppinsRegular(
                      fontSize: 14,
                      color: AppColors.whiteColor.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getConversationIcon(String iconType) {
    String iconPath;
    switch (iconType) {
      case 'plan':
        iconPath = CustomAssets.plan;
        break;
      case 'social_event':
        iconPath = CustomAssets.social_event;
        break;
      case 'workplace':
        iconPath = CustomAssets.workplace;
        break;
      case 'create_your_own_scenario':
        iconPath = CustomAssets.create_your_own_scenario;
        break;
      default:
        iconPath = CustomAssets.plan;
    }

    return SvgPicture.asset(
      iconPath,
      width: 24.w,
      height: 24.h,

    );
  }

  Widget _buildNewScenarioButton(HistoryController controller,BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap:()=> controller.onNewScenario(context),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Text(
            'New Scenario',
            style: AppFonts.poppinsSemiBold(
              fontSize: 14,
              color: AppColors.whiteColor,
            ),
          ),
        ),
      ),
    );
  }
}
