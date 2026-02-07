import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:austin_small_talk/core/global/profile_controller.dart';
import 'package:austin_small_talk/data/global/scenario_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../core/custom_assets/custom_assets.dart';
import '../../../utils/app_colors/app_colors.dart';
import '../../../utils/app_fonts/app_fonts.dart';
import 'message_screen_controller.dart';

/// Message Screen - AI Talk Chat Interface
class MessageScreen extends StatefulWidget {
  final dynamic scenarioData;

  const MessageScreen({super.key, this.scenarioData});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late final MessageScreenController controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    print('═══════════════════════════════════════════');
    print('🎬 MESSAGE SCREEN initState() CALLED');
    print('═══════════════════════════════════════════');
    print('📦 widget.scenarioData: ${widget.scenarioData}');
    print('🔍 scenarioData is null: ${widget.scenarioData == null}');
    print('🔍 scenarioData type: ${widget.scenarioData.runtimeType}');

    // Extract ScenarioData from either direct pass or Map (from history)
    ScenarioData? actualScenarioData;

    if (widget.scenarioData != null) {
      if (widget.scenarioData is ScenarioData) {
        // Direct ScenarioData (from Home, Create Scenario)
        actualScenarioData = widget.scenarioData as ScenarioData;
        print('✅ Direct ScenarioData received:');
        print('   - ID: ${actualScenarioData.scenarioId}');
        print('   - Title: ${actualScenarioData.scenarioTitle}');
        print('   - Type: ${actualScenarioData.scenarioType}');
        print('   - Source Screen: ${actualScenarioData.sourceScreen}');
      } else if (widget.scenarioData is Map) {
        // Map with scenarioData (from History with existing session)
        final dataMap = widget.scenarioData as Map;
        final baseScenarioData = dataMap['scenarioData'] as ScenarioData?;

        if (baseScenarioData != null) {
          // If sourceScreen is already set in the ScenarioData, use it
          // Otherwise it should already be set by the history controller
          actualScenarioData = baseScenarioData;

          print('✅ ScenarioData from Map (History):');
          print('   - ID: ${actualScenarioData.scenarioId}');
          print('   - Title: ${actualScenarioData.scenarioTitle}');
          print('   - Source Screen: ${actualScenarioData.sourceScreen}');
          print('   - Existing Session ID: ${dataMap['existingSessionId']}');
          print('   - Existing Messages: ${dataMap['existingMessages']?.length ?? 0}');
        }
      }
    }

    print('═══════════════════════════════════════════');

    // Initialize controller once
    controller = Get.put(MessageScreenController(), tag: 'message_${DateTime.now().millisecondsSinceEpoch}');

    // Set scenario data if we have it - only once after first frame
    if (actualScenarioData != null) {
      print('🔄 Scheduling setScenarioData call in postFrameCallback...');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('⏰ PostFrameCallback triggered');
        print('🔍 _initialized: $_initialized, mounted: $mounted');
        if (!_initialized && mounted) {
          _initialized = true;
          print('✅ Calling controller.setScenarioData()...');
          // Just pass scenario data - controller will handle storage/API logic
          controller.setScenarioData(actualScenarioData!);
        } else {
          print('⚠️ Skipped setScenarioData (already initialized or not mounted)');
        }
      });
    } else {
      print('❌ No valid scenario data - chat will not start');
    }
  }

  @override
  void dispose() {
    // Don't delete controller here - let GetX handle it
    super.dispose();
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

              // Chat Messages with RefreshIndicator
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.refreshMessageData(),
                  color: AppColors.whiteColor,
                  backgroundColor: Color(0xFF4B006E),
                  strokeWidth: 3.0,
                  child: _buildMessagesList(controller),
                ),
              ),

              // Input Area
              _buildInputArea(context, controller),

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
      () {
        // Show loading indicator while starting session
        if (controller.isLoading.value && controller.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Starting conversation...',
                  style: AppFonts.poppinsRegular(
                    fontSize: 14,
                    color: AppColors.whiteColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        }

        // Show empty state if no messages
        if (controller.messages.isEmpty) {
          return Center(
            child: Text(
              'No messages yet',
              style: AppFonts.poppinsRegular(
                fontSize: 14,
                color: AppColors.whiteColor.withValues(alpha: 0.5),
              ),
            ),
          );
        }

        // Show messages list with optimizations
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          itemCount: controller.messages.length,
          // Performance optimization: provide estimated height
          itemExtent: null, // Let it calculate but cache
          cacheExtent: 1000, // Cache offscreen items
          addAutomaticKeepAlives: true, // Keep alive for better performance
          itemBuilder: (context, index) {
            final message = controller.messages[index];
            // Use keyed widget for better performance
            return _buildMessageBubble(message, index);
          },
        );
      },
    );
  }

  /// Build Message Bubble - Optimized version
  Widget _buildMessageBubble(ChatMessage message, int index) {
    // Format timestamp
    final timeString = _formatMessageTime(message.timestamp);

    // Check animation state ONCE - not with Obx
    final shouldAnimate = !message.isUser && 
                         controller.latestAiMessageId.value == message.id &&
                         !controller.animatedMessageIds.contains(message.id);

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: message.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
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
                    child: message.isUser
                        ? Text(
                      message.text,
                      style: AppFonts.poppinsRegular(
                        fontSize: 14,
                        color: AppColors.whiteColor,
                        height: 1.4,
                      ),
                    )
                        : shouldAnimate
                        ? AnimatedTextKit(
                            key: ValueKey(message.id), // Force rebuild when message changes
                            animatedTexts: [
                              TypewriterAnimatedText(
                                message.text,
                                textStyle: AppFonts.poppinsRegular(
                                  fontSize: 14,
                                  color: AppColors.whiteColor,
                                  height: 1.4,
                                ),
                                speed: const Duration(milliseconds: 15), // ✅ 2.7x faster (was 40ms)
                              ),
                            ],
                            totalRepeatCount: 1,
                            displayFullTextOnTap: true,
                            stopPauseOnTap: false,
                            onFinished: () {
                              // Ensure it's marked as animated after completion
                              controller.animatedMessageIds.add(message.id);
                            },
                          )
                        : Text(
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
                Obx(() {
                  // ✅ Use GlobalProfileController for instant updates across all screens
                  final imageUrl = GlobalProfileController.instance.profileImageUrl.value;
                  return Container(
                    width: 32.w,
                    height: 32.h,
                    margin: EdgeInsets.only(left: 8.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 32.w,
                              height: 32.h,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: SizedBox(
                                    width: 16.w,
                                    height: 16.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('❌ Error loading profile image: $error');
                                // Fallback to default asset image on error
                                return Image.asset(
                                  CustomAssets.person,
                                  width: 32.w,
                                  height: 32.h,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              CustomAssets.person,
                              width: 32.w,
                              height: 32.h,
                              fit: BoxFit.cover,
                            ),
                    ),
                  );
                }),
              ],
            ],
          ),

          // Timestamp below message bubble
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(
              left: message.isUser ? 0 : 40.w, // Align with message (after avatar)
              right: message.isUser ? 40.w : 0, // Align with message (before avatar)
            ),
            child: Text(
              timeString,
              style: AppFonts.poppinsRegular(
                fontSize: 11,
                color: AppColors.whiteColor.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Format message timestamp to readable time
  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    // Format time as HH:MM
    final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    if (messageDate == today) {
      // Today - just show time
      return timeStr;
    } else if (messageDate == today.subtract(Duration(days: 1))) {
      // Yesterday
      return 'Yesterday $timeStr';
    } else if (now.difference(messageDate).inDays < 7) {
      // Within a week - show day name
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[messageDate.weekday - 1]} $timeStr';
    } else {
      // Older - show date
      return '${messageDate.day}/${messageDate.month} $timeStr';
    }
  }

  /// Build Input Area
  Widget _buildInputArea(BuildContext context, MessageScreenController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          // Text Input Field Container with Add Icon inside
          Expanded(
            child: Obx(
              () => Container(
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
                        enabled: !controller.isSending.value,
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
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
                          if (!controller.isSending.value) {
                            controller.sendMessage();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // Send Button


          SizedBox(width: 8.w),

          // Voice Button
          Obx(
            () => GestureDetector(
              onTap: controller.isSending.value
                  ? null
                  : () => controller.toggleRecording(context),
              child: Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Color(0xFF8B5CF6).withValues(
                    alpha: controller.isSending.value ? 0.4 : 0.8,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mic,
                  color: AppColors.whiteColor,
                  size: 24.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w,),
          Obx(
                () => GestureDetector(
              onTap: controller.isSending.value
                  ? null
                  : () => controller.sendMessage(),
              child: Container(
                width: 50.w,
                height: 50.h,
                child: controller.isSending.value
                    ? Center(
                  child: SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                    ),
                  ),
                )
                    : Center(
                  child: SvgPicture.asset(
                    CustomAssets.send_svg_icon,
                    width: 40.w,
                    height: 40.h,
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