import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:austin_small_talk/view/custom_start_conversation_button/custom_start_conversation_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/custom_assets/custom_assets.dart';
import '../../../utils/app_colors/app_colors.dart';
import '../../../utils/app_fonts/app_fonts.dart';

class ScenarioDialog extends StatelessWidget {
  final String scenarioType;
  final String scenarioIcon;
  final String scenarioTitle;

  const ScenarioDialog({
    Key? key,
    required this.scenarioType,
    required this.scenarioIcon,
    required this.scenarioTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('🎬 ScenarioDialog building - Type: $scenarioType, Icon: $scenarioIcon, Title: $scenarioTitle');
    return Dialog(
      backgroundColor: Colors.transparent,
     insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        width: double.infinity,
        height: 310.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          image: DecorationImage(
            image: AssetImage(CustomAssets.start_conversation_background),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Main Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 2.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20.h),
                  
                  // Scenario Icon
                  Container(
                    width: 48.w,
                    height: 48.h,

                    child: Center(
                      child: SvgPicture.asset(
                        scenarioIcon,
                        width: 48.w,
                        height: 48.h,

                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Title
                  Text(
                    'practice a Conversation',
                    style: AppFonts.poppinsSemiBold(
                      fontSize: 20,
                      color: AppColors.whiteColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // Subtitle
                  Text(
                    'on a $scenarioTitle',
                    style: AppFonts.poppinsSemiBold(
                      fontSize: 20,
                      color: AppColors.whiteColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Description
                  Text(
                    _getDescription(scenarioType),
                    style: AppFonts.poppinsRegular(
                      fontSize: 16,
                      color: AppColors.whiteColor.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  ),
                  
                  SizedBox(height: 16 .h),
                  
                  // Start Conversation Button
                  CustomStartConversationButton(
                    label: 'Start Conversation',
                    onPressed: () {

                      // TODO: Navigate to conversation screen
                      context.push(AppPath.messageScreen);
                    },
                    width: double.infinity,
                  ),
                ],
              ),
            ),
            
            // Close Button
            Positioned(
              top: 16.h,
              right: 16.w,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 24.w,
                  height: 24.h,

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
    );
  }

  String _getDescription(String scenarioType) {
    switch (scenarioType.toLowerCase()) {
      case 'plane':
        return 'Practice talking naturally with the person next to you.';
      case 'social event':
        return 'Practice conversation at parties or networking.';
      case 'workplace':
        return 'Improve your daily professional communication.';
      case 'daily topic':
        return 'A fresh AI-generated scenario every 24 hours.';
      default:
        return 'Start practicing your conversation skills now.';
    }
  }
}
