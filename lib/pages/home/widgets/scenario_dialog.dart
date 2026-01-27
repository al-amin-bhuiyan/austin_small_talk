import 'package:austin_small_talk/core/app_route/app_path.dart';
import 'package:austin_small_talk/data/global/scenario_data.dart';
import 'package:austin_small_talk/view/custom_start_conversation_button/custom_start_conversation_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/custom_assets/custom_assets.dart';
import '../../../utils/app_colors/app_colors.dart';
import '../../../utils/app_fonts/app_fonts.dart';

class ScenarioDialog extends StatelessWidget {
  final ScenarioData scenarioData;

  const ScenarioDialog({
    Key? key,
    required this.scenarioData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('🎬 ScenarioDialog building - Type: ${scenarioData.scenarioType}, Title: ${scenarioData.scenarioTitle}');
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
                  
                  // Scenario Icon - Handle both emoji and SVG
                  Container(
                    width: 48.w,
                    height: 48.h,
                    child: Center(
                      child: _buildIcon(),
                    ),
                  ),
                  
                  SizedBox(height: 10.h),
                  
                  // Title
                  Text(
                    'practice a Conversation',
                    style: AppFonts.poppinsSemiBold(
                      fontSize: 20.sp,
                      color: AppColors.whiteColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // Subtitle
                  Text(
                    'on a ${scenarioData.scenarioTitle}',
                    style: AppFonts.poppinsSemiBold(
                      fontSize: 20.sp,
                      color: AppColors.whiteColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Description
                  Text(
                    scenarioData.scenarioDescription,
                    style: AppFonts.poppinsRegular(
                      fontSize: 16.sp,
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
                      print('🚀 Starting conversation with scenario: ${scenarioData.scenarioTitle}');
                      print('📊 ScenarioData details:');
                      print('   - scenarioId: ${scenarioData.scenarioId}');
                      print('   - title: ${scenarioData.scenarioTitle}');
                      print('   - type: ${scenarioData.scenarioType}');
                      print('   - sourceScreen: home');
                      
                      // Close the dialog first
                      Navigator.of(context).pop();
                      
                      // Create new ScenarioData with sourceScreen
                      final scenarioDataWithSource = ScenarioData(
                        scenarioId: scenarioData.scenarioId,
                        scenarioType: scenarioData.scenarioType,
                        scenarioIcon: scenarioData.scenarioIcon,
                        scenarioTitle: scenarioData.scenarioTitle,
                        scenarioDescription: scenarioData.scenarioDescription,
                        difficulty: scenarioData.difficulty,
                        sourceScreen: 'home', // Track that user came from Home
                      );
                      
                      // Navigate to message screen with scenario data
                      GoRouter.of(context).push(AppPath.messageScreen, extra: scenarioDataWithSource);
                      print('✅ Navigation to message screen initiated from Home');
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

  /// Build icon widget - handles both emoji and SVG
  Widget _buildIcon() {
    // Check if icon is emoji (doesn't contain .svg or assets path)
    if (!scenarioData.scenarioIcon.contains('.svg') && 
        !scenarioData.scenarioIcon.contains('assets')) {
      return Text(
        scenarioData.scenarioIcon,
        style: TextStyle(fontSize: 24.sp),
      );
    } else {
      return SvgPicture.asset(
        scenarioData.scenarioIcon,
        width: 24.w,
        height: 24.h,
      );
    }
  }
}
