import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wave_blob/wave_blob.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_fonts/app_fonts.dart';
import '../../utils/nav_bar/nav_bar.dart';
import '../../utils/nav_bar/nav_bar_controller.dart';
import 'ai_talk_controller.dart';

class AiTalkScreen extends StatelessWidget {
  const AiTalkScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiTalkController());
    final navBarController = Get.find<NavBarController>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                      SizedBox(height: 230.h),
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
            bottom: MediaQuery.of(context).viewInsets.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text field with voice icon
                _buildMessageInput(context, controller),
                // Nav bar
                Obx(
                  () => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: controller.showNavBar.value ? null : 0,
                    child: controller.showNavBar.value
                        ? CustomNavBar(controller: navBarController)
                        : const SizedBox.shrink(),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
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

  Widget _buildMessageInput(BuildContext context, AiTalkController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.blackColor.withValues(alpha: 0.56),
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: AppColors.whiteColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller.textController,
                focusNode: controller.textFocusNode,
                style: AppFonts.poppinsRegular(
                  fontSize: 14,
                  color: AppColors.whiteColor,
                ),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: AppFonts.poppinsRegular(
                    fontSize: 14,
                    color: AppColors.whiteColor.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Obx(
            () => GestureDetector(
              onTap: () {
                if (controller.textFocusNode.hasFocus || controller.hasText.value) {
                  // Send message when focused or has text
                  controller.onSendPressed(context);
                } else {
                  // Navigate to voice chat screen
                  controller.goToVoiceChat(context);
                }
              },
              child: Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: (controller.textFocusNode.hasFocus || controller.hasText.value)
                      ? const Color(0xFF4B006E)
                      : AppColors.whiteColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    (controller.textFocusNode.hasFocus || controller.hasText.value)
                        ? CustomAssets.send_icon
                        : CustomAssets.voice_icon,
                    width: 48.w,
                    height: 48.h,

                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}