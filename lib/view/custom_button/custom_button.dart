import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_fonts/app_fonts.dart';

/// A project-wide button that uses the image background defined in `CustomAssets.button_background`.
///
/// Visual behavior:
/// - Uses the image asset as the button background (BoxFit.cover).
/// - Clips to rounded corners and provides touch ripple using InkWell.
/// - Shows a loading indicator when `isLoading == true`.
/// - Can be disabled via `enabled == false`.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final double? width;
  final double? height;
  final Widget? leading;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  const CustomButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.height,
    this.leading,
    this.textStyle,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double _height = height ?? 44.h;
    final BorderRadius _radius = (borderRadius as BorderRadius?) ?? BorderRadius.circular(12.r);

    final Widget content = Center(
      child: isLoading
          ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.whiteColor),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  leading!,
                  SizedBox(width: 8.w),
                ],
                Text(
                  label,
                  style: textStyle ?? AppFonts.poppinsSemiBold(
                    fontSize: 16,
                    color: AppColors.whiteColor,
                  ),
                ),
              ],
            ),
    );

    // Disabled overlay: slightly desaturate when disabled
    const int alpha35 = 89; // ~0.35 * 255
    const int alpha40 = 102; // ~0.40 * 255
    const int alpha20 = 51; // ~0.20 * 255

    final Widget disabledOverlay = Container(
      decoration: BoxDecoration(
        color: AppColors.blackColor.withAlpha(alpha35),
        borderRadius: _radius,
      ),
    );

    return SizedBox(
      width: width ?? double.infinity,
      height: _height,
      child: ClipRRect(
        borderRadius: _radius,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image from assets
              Image.asset(
                CustomAssets.button_background,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback: gradient background similar to the design
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF00D9FF), Color(0xFF9B4BFF)],
                      ),
                    ),
                  );
                },
              ),

              // InkWell for ripple/tap
              InkWell(
                onTap: (enabled && !isLoading) ? onPressed : null,
                splashColor: AppColors.whiteColor.withAlpha(alpha40),
                highlightColor: AppColors.whiteColor.withAlpha(alpha20),
                child: Padding(
                  padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
                  child: content,
                ),
              ),

              // Disabled overlay
              if (!enabled) disabledOverlay,
            ],
          ),
        ),
      ),
    );
  }
}