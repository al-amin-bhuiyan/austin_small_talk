import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors/app_colors.dart';
import '../../../utils/app_fonts/app_fonts.dart';
import '../../../utils/nav_bar/nav_bar.dart';
import '../../../utils/nav_bar/nav_bar_controller.dart';
import '../../../view/custom_back_button/custom_back_button.dart';
import 'notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());
    final navBarController = Get.find<NavBarController>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A2342),
              const Color(0xFF1A1A3E),
              const Color(0xFF2D1B4E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(context),
              
              // Notifications List
              Expanded(
                child: Obx(() => controller.notifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        itemCount: controller.notifications.length,
                        itemBuilder: (context, index) {
                          final notification = controller.notifications[index];
                          return _buildNotificationItem(
                            notification: notification,
                            onTap: () => controller.markAsRead(index),
                          );
                        },
                      )),
              ),
              
              // Navigation Bar
            //  CustomNavBar(controller: navBarController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          CustomBackButton(
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Notification',
                style: AppFonts.poppinsSemiBold(
                  fontSize: 18,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 40.w), // Balance
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required NotificationItem notification,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.10),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row with Icon, Title, and Time
            Row(
              children: [
                // Icon (no border)
                SvgPicture.asset(
                  notification.icon,
                  width: 24.w,
                  height: 24.h,
                ),

                SizedBox(width: 12.w),
                
                // Title
                Expanded(
                  child: Text(
                    notification.title,
                    style: AppFonts.poppinsSemiBold(
                      fontSize: 16,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
                
                SizedBox(width: 8.w),
                
                // Time
                Text(
                  notification.time,
                  style: AppFonts.poppinsRegular(
                    fontSize: 12,
                    color: AppColors.whiteColor.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8.h),
            
            // Divider
            Divider(
              color: Colors.white.withValues(alpha: 0.1),
              thickness: 1,
              height: 1,
            ),
            
            SizedBox(height: 8.h),
            
            // Description
            Text(
              notification.description,
              style: AppFonts.poppinsRegular(
                fontSize: 14,
                color: AppColors.whiteColor.withValues(alpha: 0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80.sp,
            color: AppColors.whiteColor.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Notifications',
            style: AppFonts.poppinsSemiBold(
              fontSize: 20,
              color: AppColors.whiteColor.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You have no notifications at the moment',
            style: AppFonts.poppinsRegular(
              fontSize: 14,
              color: AppColors.whiteColor.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
