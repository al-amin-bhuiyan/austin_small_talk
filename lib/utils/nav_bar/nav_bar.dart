import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../app_colors/app_colors.dart';
import 'nav_bar_controller.dart';

/// Custom Navigation Bar Widget
/// OOP style implementation with clean separation of concerns
class CustomNavBar extends StatelessWidget {
  final NavBarController controller;

  const CustomNavBar({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.h,
      margin: EdgeInsets.symmetric(horizontal: 50.w, vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.9),
            offset: Offset(0, 4),
            blurRadius: 6,
            spreadRadius: 3,
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavBarItem(
            icon: CustomAssets.home_nav_bar,
            label: 'Home',
            index: 0,
            controller: controller,
          ),
          _NavBarItem(
            icon: CustomAssets.history_nav_bar,
            label: 'History',
            index: 1,
            controller: controller,
          ),
          _NavBarItem(
            icon: CustomAssets.voice_nav_bar,
            label: 'Voice',
            index: 2,
            controller: controller,
          ),
          _NavBarItem(
            icon: CustomAssets.profile_nav_bar,
            label: 'Profile',
            index: 3,
            controller: controller,
          ),
        ],
      ),
    );
  }
}

/// Individual Navigation Bar Item
/// Private class following OOP encapsulation
class _NavBarItem extends StatelessWidget {
  final String icon;
  final String label;
  final int index;
  final NavBarController controller;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.controller,
  });

  // Get selected icon based on the unselected icon
  String _getSelectedIcon(String unselectedIcon) {
    switch (unselectedIcon) {
      case CustomAssets.home_nav_bar:
        return CustomAssets.home_nav_bar_select;
      case CustomAssets.history_nav_bar:
        return CustomAssets.history_nav_bar_select;
      case CustomAssets.voice_nav_bar:
        return CustomAssets.voice_nav_bar_select;
      case CustomAssets.profile_nav_bar:
        return CustomAssets.profile_nav_bar_select;
      default:
        return unselectedIcon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final isSelected = controller.isSelected(index);

        return GestureDetector(
          onTap: () => controller.changeIndex(index, context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: isSelected ? 74.w : 40.w,
            height: isSelected ? 50.h : 40.h,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: isSelected 
                  ? BorderRadius.circular(22.r)
                  : BorderRadius.circular(22.r),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.35),
                width: 1,
              ),
                boxShadow: [
                BoxShadow(
                color: Color(0x28000000),
            blurRadius: 9,
            offset: Offset(9, 9),
            spreadRadius: 0,
          )]
            ),
            child: isSelected
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        _getSelectedIcon(icon),
                        width: 24.w,
                        height: 24.h,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: SvgPicture.asset(
                      icon,
                      width: 24.w,
                      height: 24.h,
                      colorFilter: ColorFilter.mode(
                        AppColors.whiteColor.withValues(alpha: 0.6),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
