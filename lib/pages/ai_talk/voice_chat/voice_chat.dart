import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wave_blob/wave_blob.dart';
import 'package:siri_wave/siri_wave.dart';
import '../../../core/custom_assets/custom_assets.dart';
import '../../../utils/app_colors/app_colors.dart';
import '../../../utils/app_fonts/app_fonts.dart';
import '../../../view/custom_back_button/custom_back_button.dart';
import 'voice_chat_controller.dart';

/// Voice Chat Screen - AI Talk with Voice
class VoiceChatScreen extends StatelessWidget {
  const VoiceChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VoiceChatController());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(CustomAssets.backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(context, controller),
              
              // Chat Messages Area
              Expanded(
                child: _buildMessagesArea(controller),
              ),
              
              // Control Buttons
              _buildControlButtons(controller),
              
              SizedBox(height: 16.h),
              
              // Listening Text at bottom
              Obx(() => controller.isListening.value
                  ? Padding(
                      padding: EdgeInsets.only(bottom: 24.h),
                      child: Text(
                        'Listening...',
                        style: AppFonts.poppinsRegular(
                          fontSize: 14,
                          color: AppColors.whiteColor.withValues(alpha: 0.7),
                        ),
                      ),
                    )
                  : SizedBox(height: 40.h)),
            ],
          ),
        ),
      ),
    );
  }

  /// Build App Bar
  Widget _buildAppBar(BuildContext context, VoiceChatController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          // Back Button
          CustomBackButton(
            onPressed: () => controller.goBack(context),
          ),
          
          Expanded(
            child: Center(
              child: Text(
                'AI Talk',
                style: AppFonts.poppinsSemiBold(
                  fontSize: 18,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ),
          
          // Spacer for alignment
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  /// Build Messages Area
  Widget _buildMessagesArea(VoiceChatController controller) {
    return Obx(
      () => controller.messages.isEmpty && controller.recognizedText.value.isEmpty
          ? Center(
              child: Text(
                'Tap the mic to start talking',
                style: AppFonts.poppinsRegular(
                  fontSize: 16,
                  color: AppColors.whiteColor.withValues(alpha: 0.5),
                ),
              ),
            )
          : ListView.builder(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              itemCount: controller.messages.length +
                  (controller.recognizedText.value.isNotEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                // Temporary bubble for live speech at the very top
                if (index == 0 && controller.recognizedText.value.isNotEmpty) {
                  return _buildMessageBubble(
                    ChatMessage(
                      text: controller.recognizedText.value,
                      isUser: true,
                      timestamp: DateTime.now(),
                    ),
                    isTemporary: true,
                  );
                }

                // Map reversed index to the correct message
                final bool hasTemp = controller.recognizedText.value.isNotEmpty;
                final int adjustedIndex = hasTemp ? index - 1 : index;
                final int messageIndex = controller.messages.length - 1 - adjustedIndex;

                if (messageIndex < 0 || messageIndex >= controller.messages.length) {
                  return const SizedBox.shrink();
                }

                return _buildMessageBubble(controller.messages[messageIndex]);
              },
            ),
    );
  }

  /// Build Message Bubble
  Widget _buildMessageBubble(ChatMessage message, {bool isTemporary = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Opacity(
        opacity: isTemporary ? 0.7 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: message.isUser 
              ? CrossAxisAlignment.end 
              : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // AI Avatar (left side for AI messages)
                if (!message.isUser) ...[
                  Container(
                    width: 32.w,
                    height: 32.h,
                    margin: EdgeInsets.only(right: 8.w),
                    child: Center(
                      child: SvgPicture.asset(
                        CustomAssets.ai_assistant_icon,
                        width: 20.w,
                        height: 20.h,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                ], 
                
                // Message Bubble
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.00, 0.50),
                        end: Alignment(1.00, 0.50),
                        colors: message.isUser
                            ? [const Color(0xFF004E92), const Color(0xFF00C2CB)]
                            : [const Color(0xFF2C2E2F), const Color(0xFF8B9195)],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: message.isUser
                            ? BorderRadius.only(
                                topLeft: Radius.circular(20.r),
                                bottomLeft: Radius.circular(20.r),
                                bottomRight: Radius.circular(20.r),
                              )
                            : BorderRadius.only(
                                topRight: Radius.circular(20.r),
                                bottomLeft: Radius.circular(20.r),
                                bottomRight: Radius.circular(20.r),
                              ),
                      ),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w300,
                        height: 1.10,
                      ),
                    ),
                  ),
                ),
                
                // User Avatar (right side for user messages)
                if (message.isUser) ...[
                  SizedBox(width: 6.w),
                  Container(
                    width: 32.w,
                    height: 32.h,
                    margin: EdgeInsets.only(left: 8.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      image: DecorationImage(
                        image: AssetImage(CustomAssets.person),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build Control Buttons with Siri Wave and Blob Animation
  Widget _buildControlButtons(VoiceChatController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // Siri Wave Visualization Area with buttons on top
          Obx(() => Container(
            height: 200.h,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Siri Wave Background (only when listening)
                if (controller.isListening.value)
                  Positioned.fill(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Color(0xFF00D9FF),
                        BlendMode.srcATop,
                      ),
                      child: SiriWaveform.ios9(
                        controller: controller.siriController,
                        options: const IOS9SiriWaveformOptions(
                          height: 200,
                          showSupportBar: true,
                        ),
                      ),
                    ),
                  )
                else
                  // Show hint text when not listening
                  Positioned(
                    top: 40.h,
                    child: Text(
                      '',
                      style: AppFonts.poppinsRegular(
                        fontSize: 16,
                        color: AppColors.whiteColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                
                // Control Buttons Row - Positioned at center
                Positioned(
                  bottom: 50.h,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pause Button
                      GestureDetector(
                        onTap: () => controller.toggleListening(),
                        child: Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF8B5CF6).withValues(alpha: 0.8),
                                Color(0xFF6B46C1).withValues(alpha: 0.8)
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          child: Icon(
                            controller.isListening.value ? Icons.pause : Icons.play_arrow,
                            color: AppColors.whiteColor,
                            size: 24.sp,
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 20.w),
                      
                      // Mic Icon with Blob Animation (ALWAYS VISIBLE in row)
                      GestureDetector(
                        onTap: () => controller.toggleListening(),
                        child: SizedBox(
                          width: 100.w,
                          height: 100.h,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Blob animation behind the icon when listening
                              if (controller.isListening.value)
                                WaveBlob(
                                  blobCount: 2,
                                  speed: 10,
                                  child: Container(
                                    width: 100.w,
                                    height: 100.h,

                                  ),
                                ),
                              
                              // Mic icon container (always visible on top)
                              Container(
                                width: 70.w,
                                height: 70.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFF00D9FF), Color(0xFF0A84FF)],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.mic,
                                  color: AppColors.whiteColor,
                                  size: 28.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 20.w),
                      
                      // Cross Button
                      GestureDetector(
                        onTap: () => controller.goBack(Get.context!),
                        child: Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF8B5CF6).withValues(alpha: 0.8),
                                Color(0xFF6B46C1).withValues(alpha: 0.8)
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          child: Icon(
                            Icons.close,
                            color: AppColors.whiteColor,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}