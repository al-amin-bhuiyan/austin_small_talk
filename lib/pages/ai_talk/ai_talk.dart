import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:wave_blob/wave_blob.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../../core/app_route/app_path.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_fonts/app_fonts.dart';
import '../../utils/nav_bar/nav_bar.dart';
import '../../utils/nav_bar/nav_bar_controller.dart';
import '../../view/custom_back_button/custom_back_button.dart';
import 'ai_talk_controller.dart';

class AiTalkScreen extends StatelessWidget {
  const AiTalkScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiTalkController());
    final navBarController = Get.find<NavBarController>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background image covering full screen
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(CustomAssets.backgroundImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // App Bar
                _buildAppBar(context),

                // Main Content
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      _buildGreeting_name(),
                      SizedBox(height: 3.h),
                      _buildGreeting(),
                      SizedBox(height: 80.h),
                      _buildAICircle(context, controller),
                      SizedBox(height: 150.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Text field and nav bar at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text field

                SizedBox(height: 4.h),
                // Nav bar
                Obx(
                      () =>
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: controller.showNavBar.value ? null : 0,
                        child: controller.showNavBar.value
                            ? SafeArea(
                          child: CustomNavBar(controller: navBarController),
                        )
                            : const SizedBox.shrink(),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [

          Expanded(
            child: Text(
              'AI Talk',
              textAlign: TextAlign.center,
              style: AppFonts.poppinsSemiBold(
                fontSize: 18,
                color: AppColors.whiteColor,
              ),
            ),
          ),
          SizedBox(width: 40.w), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildGreeting_name() {
    return Padding(
      padding: EdgeInsets.only(left: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi Sophia!',
            style: AppFonts.poppinsRegular(
              fontSize: 16,
              color: AppColors.whiteColor.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Padding(
      padding: EdgeInsets.only(left: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'How Can I Help You Today?',
                textStyle: AppFonts.poppinsSemiBold(
                  fontSize: 22,
                  color: AppColors.whiteColor,
                ),
                speed: const Duration(milliseconds: 80),
              ),
            ],
            totalRepeatCount: 1,
            displayFullTextOnTap: true,
            stopPauseOnTap: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAICircle(BuildContext context, AiTalkController controller) {
    return GetBuilder<AiTalkController>(
      builder: (ctrl) {
        return SizedBox(
          width: 310.w,
          height: 310.h,
          child: WaveBlob(
            blobCount: 2,
            amplitude: ctrl.waveAmplitude,
            scale: ctrl.waveScale,
            autoScale: ctrl.autoScale,
            centerCircle: true,
            overCircle: true,
            circleColors: const [Colors.transparent],
            colors: const [Color(0x996B8CFF), Color(0xFF4B006E)],
            child: Center(
              child: Image.asset(
                CustomAssets.ai_talk_image,
                width: 210.w,
                height: 210.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}


