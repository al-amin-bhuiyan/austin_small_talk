import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_route/app_path.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../../data/global/scenario_data.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_fonts/app_fonts.dart';
import '../../utils/nav_bar/nav_bar_controller.dart';
import '../../service/auth/models/scenario_model.dart';
import 'history_controller.dart';

/// History Screen - Shows chat history with conversations
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();
    final navBarController = Get.find<NavBarController>();
    
    // Set nav bar to history tab (index 1) after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navBarController.selectedIndex.value != 1) {
        navBarController.selectedIndex.value = 1;
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
                        
                        // AI Scenario Chat History
                        _buildConversationList(controller, context),
                        
                     //   SizedBox(height: 20.h),
                        
                        // Create Your Own Scenario Button
                     //   _buildNewScenarioButton(controller, context),
                        
                        SizedBox(height: 20.h),
                        
                        // Created Scenarios Header
                        _buildCreatedScenariosHeader(),
                        
                        SizedBox(height: 16.h),
                        
                        // User Created Scenarios List
                        _buildUserScenarios(controller, context),
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
      () {
        // Show loading indicator while fetching
        if (controller.isLoading.value && controller.filteredConversations.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
        }

        // Show empty state if no conversations
        if (controller.filteredConversations.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: Text(
                'No conversations found',
                style: AppFonts.poppinsRegular(
                  fontSize: 16,
                  color: AppColors.whiteColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          );
        }

        // Display conversations
        return Column(
          children: controller.filteredConversations.map((conversation) {
            return _buildConversationItem(controller, conversation, context);
          }).toList(),
        );
      },
    );
  }

  Widget _buildConversationItem(
      HistoryController controller, ConversationItem conversation, BuildContext context) {
    return GestureDetector(
      onTap: () => controller.onConversationTap(conversation.id, context),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon - Centered vertically
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Center(
                child: _getConversationIcon(conversation.icon, conversation.isEmoji),
              ),
            ),
            SizedBox(width: 12.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Difficulty Badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          conversation.title,
                          style: AppFonts.poppinsSemiBold(
                            fontSize: 16,
                            color: AppColors.whiteColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.difficulty.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        _buildDifficultyBadge(conversation.difficulty),
                      ],
                    ],
                  ),
                  SizedBox(height: 6.h),
                  // Description
                  Text(
                    conversation.description,
                    style: AppFonts.poppinsRegular(
                      fontSize: 13,
                      color: AppColors.whiteColor.withValues(alpha: 0.65),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  // Message count (left) and Date (right)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Message count
                      Text(
                        'Total ${conversation.messageCount} ${conversation.messageCount == 1 ? 'message' : 'messages'}',
                        style: AppFonts.poppinsRegular(
                          fontSize: 12,
                          color: AppColors.whiteColor.withValues(alpha: 0.5),
                        ),
                      ),
                      // Date
                      Text(
                        conversation.time,
                        style: AppFonts.poppinsRegular(
                          fontSize: 12,
                          color: AppColors.whiteColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color badgeColor;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        badgeColor = Color(0xFF10B981); // Green
        break;
      case 'medium':
        badgeColor = Color(0xFFF59E0B); // Orange
        break;
      case 'hard':
        badgeColor = Color(0xFFEF4444); // Red
        break;
      default:
        badgeColor = Color(0xFF6B7280); // Gray
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: AppFonts.poppinsSemiBold(
          fontSize: 10,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _getConversationIcon(String iconType, bool isEmoji) {
    // If it's an emoji, display it as text
    if (isEmoji) {
      return Center(
        child: Text(
          iconType,
          style: TextStyle(fontSize: 24.sp),
        ),
      );
    }
    
    // Otherwise, use SVG asset
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

  Widget _buildNewScenarioButton(HistoryController controller, BuildContext context) {
    return GestureDetector(
      onTap: () => controller.onNewScenario(context),
      child: Container(
        width: double.infinity,
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4B006E),
              Color(0xFF8B5CF6),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF8B5CF6).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppColors.whiteColor,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              'Create Your Own Scenario',
              style: AppFonts.poppinsSemiBold(
                fontSize: 16,
                color: AppColors.whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatedScenariosHeader() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.whiteColor.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Created Scenarios',
            style: AppFonts.poppinsSemiBold(
              fontSize: 14,
              color: AppColors.whiteColor.withValues(alpha: 0.8),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.whiteColor.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildUserScenarios(HistoryController controller, BuildContext context) {
    return Obx(() {
      if (controller.isScenariosLoading.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(20.h),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.whiteColor),
            ),
          ),
        );
      }

      if (controller.userScenarios.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(20.h),
            child: Text(
              'No scenarios created yet',
              style: AppFonts.poppinsRegular(
                fontSize: 14,
                color: AppColors.whiteColor.withValues(alpha: 0.5),
              ),
            ),
          ),
        );
      }

      return Column(
        children: controller.userScenarios.map((scenario) {
          return _buildScenarioItem(scenario, context);
        }).toList(),
      );
    });
  }

  Widget _buildScenarioItem(ScenarioModel scenario, BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('🎯 History scenario tapped - ID: ${scenario.id}, Title: ${scenario.scenarioTitle}');
        print('📝 Scenario ID from API: ${scenario.scenarioId}');
        
        // Create scenario data object for message screen
        final scenarioData = ScenarioData(
          scenarioId: scenario.scenarioId,  // Use actual scenario_id from API
          scenarioTitle: scenario.scenarioTitle,
          scenarioDescription: scenario.description,
          scenarioIcon: '🎯',  // Default icon for user-created scenarios
          scenarioType: 'user_created',
          difficulty: scenario.difficultyLevel,
          sourceScreen: 'history', // Track that user came from History
        );
        
        print('📤 Navigating to message screen from history');
        print('📊 ScenarioData: scenarioId=${scenarioData.scenarioId}, title=${scenarioData.scenarioTitle}');
        print('📌 Source Screen: ${scenarioData.sourceScreen}');
        
        // Navigate to message screen
        context.push(AppPath.messageScreen, extra: scenarioData);
      },
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon - Centered vertically (same as conversations)
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Center(
                child: Text(
                  '🎯', // User-created scenario icon
                  style: TextStyle(fontSize: 24.sp),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Difficulty Badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          scenario.scenarioTitle,
                          style: AppFonts.poppinsSemiBold(
                            fontSize: 16,
                            color: AppColors.whiteColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (scenario.difficultyLevel.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        _buildDifficultyBadge(scenario.difficultyLevel),
                      ],
                    ],
                  ),
                  SizedBox(height: 6.h),
                  // Description
                  Text(
                    scenario.description,
                    style: AppFonts.poppinsRegular(
                      fontSize: 13,
                      color: AppColors.whiteColor.withValues(alpha: 0.65),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  // Status indicator (left aligned)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // "Your Scenario" label
                      Text(
                        'Your Scenario',
                        style: AppFonts.poppinsRegular(
                          fontSize: 12,
                          color: AppColors.whiteColor.withValues(alpha: 0.5),
                        ),
                      ),
                      // Empty space or you can add creation date here
                      Text(
                        'Tap to start',
                        style: AppFonts.poppinsRegular(
                          fontSize: 12,
                          color: AppColors.whiteColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
