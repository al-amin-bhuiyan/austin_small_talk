import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_fonts/app_fonts.dart';
import 'history_controller.dart';

/// History Screen - Shows chat history with conversations
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with WidgetsBindingObserver, RouteAware {
  bool _hasRefreshed = false;

  @override
  void initState() {
    super.initState();
    // Add observer to detect when app resumes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove observer when widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset refresh flag when route changes (user navigates to this screen)
    _hasRefreshed = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data when app comes to foreground or page becomes visible
    if (state == AppLifecycleState.resumed) {
      final controller = Get.find<HistoryController>();
      controller.refreshHistoryData();
      _hasRefreshed = false; // Reset flag when app resumes
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HistoryController>(
      init: HistoryController(),
      autoRemove: false, // Keep alive during tab navigation
      builder: (controller) {
        // ✅ Refresh data when navigating back, but only once per screen appearance
        if (!_hasRefreshed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_hasRefreshed) {
              _hasRefreshed = true;
              controller.refreshHistoryData();
            }
          });
        }

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

              // Scrollable Content with RefreshIndicator
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.refreshHistoryData,
                  color: AppColors.whiteColor,
                  backgroundColor: Color(0xFF4B006E),
                  strokeWidth: 3.0,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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

                          SizedBox(height: 20.h),
                        ],
                      ),
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
      },
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
}
