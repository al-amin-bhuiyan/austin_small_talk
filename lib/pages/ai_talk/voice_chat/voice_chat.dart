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
class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> with WidgetsBindingObserver {
  late final VoiceChatController controller;

  @override
  void initState() {
    super.initState();
    // ✅ Get the global VoiceChatController (no tag since it's registered globally)
    controller = Get.find<VoiceChatController>();
    print('🎙️ Using global VoiceChatController');
    WidgetsBinding.instance.addObserver(this);
    
    // Check if we need to reconnect when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onResumed();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came to foreground
      controller.onResumed();
    }
  }



  @override
  Widget build(BuildContext context) {

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

              // Chat Messages Area with RefreshIndicator
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.refreshVoiceChat,
                  color: AppColors.whiteColor,
                  backgroundColor: Color(0xFF4B006E),
                  strokeWidth: 3.0,
                  child: _buildMessagesArea(controller),
                ),
              ),

              // Control Buttons
              _buildControlButtons(controller),

              SizedBox(height: 16.h),
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
          CustomBackButton(onPressed: () => controller.goBack(context)),

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
      () =>
          controller.messages.isEmpty && controller.recognizedText.value.isEmpty
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
              itemCount:
                  controller.messages.length +
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
                final int messageIndex =
                    controller.messages.length - 1 - adjustedIndex;

                if (messageIndex < 0 ||
                    messageIndex >= controller.messages.length) {
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
                            : [
                                const Color(0xFF2C2E2F),
                                const Color(0xFF8B9195),
                              ],
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
                  Obx(() {
                    final userImage = controller.userProfileImage.value ?? '';
                    return Container(
                      width: 32.w,
                      height: 32.h,
                      margin: EdgeInsets.only(left: 8.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: Colors.grey[800],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: userImage.isNotEmpty
                            ? Image.network(
                                userImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    CustomAssets.person,
                                    fit: BoxFit.cover,
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              )
                            : Image.asset(
                                CustomAssets.person,
                                fit: BoxFit.cover,
                              ),
                      ),
                    );
                  }),
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
          // Siri Wave Visualization Area
          Obx(
            () => Container(
              height: 250.h,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Show Siri Wave and WaveBlob ONLY when mic is ON
                  if (controller.isMicOn.value) ...[
                    // Siri Wave Background
                    Positioned.fill(
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          controller.isSpeaking.value
                              ? Color(0xFF00D9FF) // AI Speaking - Cyan
                              : Color(0xFF4CAF50), // Listening - Green
                          BlendMode.srcATop,
                        ),
                        child: SiriWaveform.ios9(
                          controller: controller.siriController,
                          options: const IOS9SiriWaveformOptions(
                            height: 250,
                            showSupportBar: true,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Show hint when mic is off
                  ],

                  // Mic Button - Center (ONLY control for mic)
                  Positioned(
                    child: GestureDetector(
                      onTap: controller.isConnected.value
                          ? () => controller.toggleMicrophone()
                          : null,
                      child: SizedBox(
                        width: 120.w,
                        height: 120.h,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // WaveBlob animation ONLY when mic is ON
                            if (controller.isMicOn.value)
                              WaveBlob(
                                blobCount: 2,
                                speed: controller.isSpeaking.value ? 15 : 10,
                                child: Container(width: 120.w, height: 120.h),
                                colors: [Colors.green, Colors.green],
                              ),

                            // Mic icon
                            Container(
                              width: 80.w,
                              height: 80.h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: controller.isMicOn.value
                                      ? controller.isSpeaking.value
                                            ? [
                                                Color(0xFF00D9FF),
                                                Color(0xFF0A84FF),
                                              ] // AI speaking
                                            : [
                                                Color(0xFF4CAF50),
                                                Color(0xFF45A049),
                                              ] // Listening
                                      : [
                                          Color(0xFF666666),
                                          Color(0xFF444444),
                                        ], // Off
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
                                controller.isMicOn.value
                                    ? Icons.mic
                                    : Icons.mic_off,
                                color: AppColors.whiteColor,
                                size: 24.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Close Button - Top Right
                  Positioned(
                    top: 100.h,
                    right: 20.w,
                    child: GestureDetector(
                      onTap: () => controller.goBack(Get.context!),
                      child: Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFF44336).withValues(alpha: 0.8),
                              Color(0xFFD32F2F).withValues(alpha: 0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close,
                          color: AppColors.whiteColor,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // Status indicator at bottom
          Obx(() {
            String status = '';
            Color statusColor = AppColors.whiteColor.withValues(alpha: 0.7);

            if (!controller.isConnected.value) {
              status = 'Connecting...';
            } else if (!controller.isMicOn.value) {
              status = 'Mic Off - Tap to start';
              statusColor = Color(0xFF666666);
            } else if (controller.isSpeaking.value) {
              status = '🔊 AI Speaking...';
              statusColor = Color(0xFF00D9FF);
            } else if (controller.recognizedText.value.isNotEmpty) {
              status = '🎤 You: ${controller.recognizedText.value}';
              statusColor = Color(0xFF4CAF50);
            } else if (controller.isProcessing.value) {
              status = '⏳ Processing...';
            } else {
              status = '👂 Listening...';
              statusColor = Color(0xFF4CAF50);
            }

            return Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Text(
                status,
                style: AppFonts.poppinsRegular(
                  fontSize: 14,
                  color: statusColor,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }),
        ],
      ),
    );
  }

}
