import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wave_blob/wave_blob.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../core/custom_assets/custom_assets.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_fonts/app_fonts.dart';
import '../profile/profile_controller.dart';
import 'ai_talk_controller.dart' hide AiTalkBlobController;
import 'ai_talk_blob_controller.dart';

class AiTalkScreen extends StatefulWidget {
  const AiTalkScreen({Key? key}) : super(key: key);

  @override
  State<AiTalkScreen> createState() => _AiTalkScreenState();
}

class _AiTalkScreenState extends State<AiTalkScreen>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  late final AiTalkController _aitalkController;
  late final AiTalkBlobController _blobController;

  @override
  void initState() {
    super.initState();

    // ✅ Initialize AiTalkController (if not already registered)
    if (!Get.isRegistered<AiTalkController>()) {
      _aitalkController = Get.put(AiTalkController(), tag: 'aitalk');
    } else {
      _aitalkController = Get.find<AiTalkController>();
    }

    // ✅ Initialize AiTalkBlobController (starts breathing animation)
    if (!Get.isRegistered<AiTalkBlobController>()) {
      _blobController = Get.put(AiTalkBlobController(), tag: 'aitalkblob');
    } else {
      _blobController = Get.find<AiTalkBlobController>();
    }

    // ✅ VoiceChatController is now global - no need to initialize here
  }

  @override
  void dispose() {
    // ✅ Clean up blob controller
    if (Get.isRegistered<AiTalkBlobController>(tag: 'aitalkblob')) {
      Get.delete<AiTalkBlobController>(tag: 'aitalkblob');
    }

    // ✅ VoiceChatController is global - don't dispose it here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background image
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
                _buildAppBar(context),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      _buildGreetingName(),
                      SizedBox(height: 3.h),
                      _buildGreeting(),
                      SizedBox(height: 80.h),
                      _buildAnimatedBlob(),
                      SizedBox(height: 230.h),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom button
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMessageInput(context),
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
      padding: EdgeInsets.symmetric(horizontal: 80.w, vertical: 15.h),
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
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  Widget _buildGreetingName() {
    final profileController = Get.find<ProfileController>();

    return Padding(
      padding: EdgeInsets.only(left: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.waving_hand,
            color: AppColors.whiteColor.withValues(alpha: 0.8),
            size: 20.sp,
          ),
          Obx(() {
            final fullName = profileController.userName.value;
            return Text(
              ' Hi $fullName  ',
              style: AppFonts.poppinsRegular(
                fontSize: 16.sp,
                color: AppColors.whiteColor.withValues(alpha: 0.8),
              ),
            );
          }),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        width: double.infinity,
        child: AnimatedTextKit(
          key: ValueKey('greeting_animation_${DateTime.now().millisecondsSinceEpoch}'),
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
          isRepeatingAnimation: false,
          repeatForever: false,
        ),
      ),
    );
  }

  Widget _buildAnimatedBlob() {
    return GetBuilder<AiTalkBlobController>(
      tag: 'aitalkblob',
      builder: (blobController) {
        return Obx(() => AnimatedScale(
          scale: blobController.blobScale.value,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut,
          child: SizedBox(
            width: 300.w,
            height: 300.h,
            child: Center(
              child: SizedBox(
                width: 300.w,
                height: 300.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // WaveBlob
                    WaveBlob(
                      blobCount: 3,
                      amplitude: _aitalkController.waveAmplitude,
                      scale: _aitalkController.waveScale,
                      autoScale: _aitalkController.autoScale,
                      centerCircle: true,
                      overCircle: false,
                      circleColors: const [Colors.transparent],
                      colors: const [
                        Color(0x996B8CFF),
                        Color(0xFF4B006E),
                      ],
                      child: Container(),
                    ),

                    // AI Image
                    Container(
                      width: 250.w,
                      height: 250.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(CustomAssets.ai_talk_image),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B8CFF).withValues(alpha: 0.4),
                            blurRadius: 50,
                            offset: const Offset(0, 25),
                            spreadRadius: -1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
      },
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: GestureDetector(
        onTap: () => _aitalkController.goToCreateScenario(context),
        child: Container(
          width: double.infinity,
          height: 56.h,
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
          child: Center(
            child: Text(
              'Create a Scenario',
              style: AppFonts.poppinsSemiBold(
                fontSize: 16,
                color: AppColors.whiteColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
