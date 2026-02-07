import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../../global/controller/splash_controller.dart';
import '../../core/app_route/app_path.dart';
import '../../data/global/shared_preference.dart';
import '../../data/global/token_manager.dart';

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
      Future.delayed(const Duration(seconds: 3), () async {
        if (context.mounted) {
          // Check if user is logged in and has valid token
          final isLoggedIn = SharedPreferencesUtil.isLoggedIn();
          
          if (isLoggedIn) {
            // Validate token
            final hasValidSession = await TokenManager.hasValidSession();
            
            if (hasValidSession) {
              // User has valid session, go to home (no flicker)
              context.go(AppPath.home);
            } else {
              // Token is invalid and couldn't be refreshed, go to login (no flicker)
              context.go(AppPath.login);
            }
          } else {
            // User is not logged in, go to login screen (no flicker)
            context.go(AppPath.login);
          }
        }
      });
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(CustomAssets.backgroundImage), // main_background.png
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Image.asset(
            CustomAssets.splashLogo, // main_logo.png
            width: 200.w,
            height: 200.h,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}