import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../core/custom_assets/custom_assets.dart';
import '../../../utils/app_colors/app_colors.dart';
import '../../../utils/app_fonts/app_fonts.dart';
import '../../../view/custom_back_button/custom_back_button.dart';
import 'message_screen_controller.dart';

/// Message Screen - AI Talk Chat Interface
class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessageScreenController());

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
              
              // Chat Messages
              Expanded(
                child: _buildMessagesList(controller),
              ),
              
              // Input Area
              _buildInputArea(controller),
              
              SizedBox(height: 16.h),

              // Navigation Bar
          //    CustomNavBar(controller: navBarController),
              
            //  SizedBox(height: 34.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Build App Bar
  Widget _buildAppBar(BuildContext context, MessageScreenController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => controller.goBack(context),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.whiteColor,
                size: 18.sp,
              ),
            ),
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

  /// Build Messages List
  Widget _buildMessagesList(MessageScreenController controller) {
    return Obx(
      () => ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final message = controller.messages[index];
          return _buildMessageBubble(message);
        },
      ),
    );
  }

  /// Build Message Bubble
  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          ],
          
          // Message Bubble
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? LinearGradient(
                        begin: Alignment(0.00, 0.50),
                        end: Alignment(1.00, 0.50),
                        colors: [Color(0xFF0856FF), Color(0xFF00A3C4)],
                      )
                    : null,
                color: message.isUser 
                    ? null 
                    : Color(0xFF374151).withValues(alpha: 0.8) ,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: message.isUser ? Radius.circular(16.r) : Radius.circular(4.r),
                  bottomRight: message.isUser ? Radius.circular(4.r) : Radius.circular(16.r),
                ),
              ),
              child: Text(
                message.text,
                style: AppFonts.poppinsRegular(
                  fontSize: 14,
                  color: AppColors.whiteColor,
                  height: 1.4,
                ),
              ),
            ),
          ),
          
          // User Avatar (right side for user messages)
          if (message.isUser) ...[
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
    );
  }

  /// Build Input Area
  Widget _buildInputArea(MessageScreenController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          // Text Input Field Container with Add Icon inside
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Color(0xFF1F2937).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Add Button inside text field

                  
                  SizedBox(width: 12.w),
                  
                  // Text Input Field
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      style: AppFonts.poppinsRegular(
                        fontSize: 14,
                        color: AppColors.whiteColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'I like working on the',
                        hintStyle: AppFonts.poppinsRegular(
                          fontSize: 14,
                          color: AppColors.whiteColor.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => controller.sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(width: 8.w),
          
          // Send Button
          GestureDetector(
            onTap: () => controller.sendMessage(),
            child: Container(
              width: 40.w,
              height: 40.h,

              child: Center(
                child: SvgPicture.asset(
                  CustomAssets.send_svg_icon,
                  width: 40.w,
                  height:40.h,

                ),
              ),
            ),
          ),
          
          SizedBox(width: 8.w),
          
          // Voice Button
          Obx(
            () => GestureDetector(
              onTap: () => controller.toggleRecording(),
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: controller.isRecording.value
                      ? Color(0xFFEF4444)
                      : Color(0xFF8B5CF6).withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  controller.isRecording.value ? Icons.stop : Icons.mic,
                  color: AppColors.whiteColor,
                  size: 20.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
