import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/custom_assets/custom_assets.dart';
import '../../../../utils/app_fonts/app_fonts.dart';
import '../../../../view/custom_back_button/custom_back_button.dart';
import 'faqs_controller.dart';

class FAQsScreen extends GetView<FAQsController> {
  const FAQsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Register controller if not already registered
    if (!Get.isRegistered<FAQsController>()) {
      Get.put(FAQsController());
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(CustomAssets.backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: GetBuilder<FAQsController>(
                  builder: (_) => ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 100.h),
                    itemCount: controller.faqList.length,
                    itemBuilder: (context, index) {
                      final faq = controller.faqList[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _buildFAQItem(
                          question: faq['question']!,
                          answer: faq['answer']!,
                          isExpanded: controller.expandedIndex == index,
                          onTap: () => controller.toggleExpansion(index),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          CustomBackButton(
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(
              'FAQs',
              textAlign: TextAlign.center,
              style: AppFonts.poppinsSemiBold(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFF2C3E5C),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isExpanded
                ? const Color(0xFF4A9FFF)
                : Colors.white.withValues(alpha: 0.1),
            width: isExpanded ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: AppFonts.poppinsMedium(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: isExpanded ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Text(
                  answer,
                  style: AppFonts.poppinsRegular(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
