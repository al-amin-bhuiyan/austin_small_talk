// Create a reusable CustomBackButton widget usable across the project
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors/app_colors.dart';

/// A reusable back button that matches project style.
///
/// Usage:
/// - Place `CustomBackButton()` anywhere you need a back button.
/// - Customize via `onPressed`, `color`, `size`, `backgroundColor`.
class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color color;
  final Color backgroundColor;
  final double size;
  final double width;
  final double height;
  final double borderRadius;

  const CustomBackButton({
    Key? key,
    this.onPressed,
    this.color = AppColors.whiteColor,
    this.backgroundColor = const Color(0x1AFFFFFF), // 10% white
    this.size = 20,
    this.width = 40,
    this.height = 40,
    this.borderRadius = 20,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () {
        // Use GoRouter's canPop for proper navigation handling
        if (context.canPop()) {
          context.pop();
        } else {
          // Fallback to Navigator if GoRouter can't pop
          Navigator.of(context).maybePop();
        }
      },
      child: Container(
        width: width.w,
        height: height.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
        child: Icon(
          Icons.arrow_back,
          color: color,
          size: size.sp,
        ),
      ),
    );
  }

}
