import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../../global/controller/splash_controller.dart';
import '../../core/app_route/app_path.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    // Ensure the SplashController is initialized
    Get.find<SplashController>();

    // Only navigate once using static flag
    if (!_hasNavigated) {
      _hasNavigated = true;
      Future.delayed(const Duration(seconds: 3), () {
        if (context.mounted) {
          context.push(AppPath.login);
        }
      });
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            CustomAssets.backgroundImage,
            fit: BoxFit.cover,
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo (PNG) - use Image.asset for PNG files
                Image.asset(
                  CustomAssets.splashLogo,
                  width: 150.w,
                  height: 150.h,
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
