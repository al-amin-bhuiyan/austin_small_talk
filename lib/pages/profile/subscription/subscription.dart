import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/custom_assets/custom_assets.dart';
import '../../../utils/app_colors/app_colors.dart';
import '../../../utils/app_fonts/app_fonts.dart';
import '../../../utils/nav_bar/nav_bar.dart';
import '../../../utils/nav_bar/nav_bar_controller.dart';
import '../../../view/custom_back_button/custom_back_button.dart';
import 'subscription_controller.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubscriptionController());
    final navBarController = Get.find<NavBarController>();

    return Scaffold(
      extendBody: true,
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
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 100.h),
                  child: Column(
                    children: [
                      _buildPremiumCard(controller),
                      SizedBox(height: 16.h),
                      _buildFreeCard(controller),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: SafeArea(
      //   child: CustomNavBar(controller: navBarController),
      // ),
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
              'Subscription',
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

  Widget _buildPremiumCard(SubscriptionController controller) {
    return Container(
      width: 344.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x28000000),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTrialBanner(),
          _buildPremiumContent(controller),
        ],
      ),
    );
  }

  Widget _buildTrialBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE591),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.r),
          topRight: Radius.circular(8.r),
        ),
      ),
      child: Text(
        '3 Day Free Trial',
        textAlign: TextAlign.center,
        style: AppFonts.poppinsRegular(
          fontSize: 14,
          color: Colors.black,
          height: 1.05,
        ),
      ),
    );
  }

  Widget _buildPremiumContent(SubscriptionController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
          colors: [Color(0xFF6661DC), Color(0xFFA681FF)],
        ),
        border: Border.all(
          width: 1,
          color: Colors.black.withValues(alpha: 0.20),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8.r),
          bottomRight: Radius.circular(8.r),
        ),
      ),
      child: Column(
        children: [
          _buildPremiumTitle(),
          SizedBox(height: 32.h),
          _buildFeaturesList(),
          SizedBox(height: 32.h),
          _buildStartTrialButton(controller),
        ],
      ),
    );
  }

  Widget _buildPremiumTitle() {
    return Column(
      children: [
        Text(
          'Small Talk Premium',
          textAlign: TextAlign.center,
          style: AppFonts.poppinsSemiBold(
            fontSize: 24,
            color: Colors.white,
            height: 1,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$4.99 ',
              style: AppFonts.poppinsExtraBold(
                fontSize: 48,
                color: Colors.white,
                height: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 0.h),
              child: Text(
                '/month',
                style: AppFonts.poppinsSemiBold(
                  fontSize: 18,
                  color: Colors.white,
                  height: 1.67,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      'Unlimited conversations',
      'Daily topics',
      'Personalized feedback',
      'Custom scenarios',
      'Voice-based AI chat',
      'History access',
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: _buildFeatureItem(feature),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        SvgPicture.asset(
          CustomAssets.check,
          width: 16.w,
          height: 16.h,
          color: Colors.green,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: AppFonts.poppinsRegular(
              fontSize: 16,
              color: Colors.white,
              height: 1.50,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartTrialButton(SubscriptionController controller) {
    return Obx(() => GestureDetector(
          onTap: controller.isLoading.value ? null : controller.startFreeTrial,
          child: Container(
            width: 312.w,
            height: 41.h,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.39, 1.39),
                end: Alignment(0.56, -2.26),
                colors: [Color(0xFF00C1C0), Color(0xFFAC3EC1)],
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: controller.isLoading.value
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Start Free Trial',
                      textAlign: TextAlign.center,
                      style: AppFonts.poppinsMedium(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.50,
                      ),
                    ),
            ),
          ),
        ));
  }

  Widget _buildFreeCard(SubscriptionController controller) {
    return Container(
      width: 344.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x28000000),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFreeTitle(),
          SizedBox(height: 24.h),
          _buildFreeLimitations(),
          SizedBox(height: 24.h),
          _buildContinueFreeButton(controller),
        ],
      ),
    );
  }

  Widget _buildFreeTitle() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),

        ),
        Text(
          'Free',
          style: AppFonts.poppinsSemiBold(
            fontSize: 16.sp,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '\$0',
          style: AppFonts.poppinsBold(
            fontSize: 48,
            color: Colors.black,
            height: 1,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Forever',
          style: AppFonts.poppinsRegular(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFreeLimitations() {
    final limitations = [
      '1 conversation per day',
      'Limited feedback',
      'No custom scenarios',
      'Basic conversation history',
    ];

    return Column(
      children: limitations.map((limitation) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildLimitationItem(limitation),
        );
      }).toList(),
    );
  }

  Widget _buildLimitationItem(String text) {
    return Row(
      children: [
        SvgPicture.asset(
          CustomAssets.check,
          width: 16.w,
          height: 16.h,
          color: Colors.green,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: AppFonts.poppinsRegular(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueFreeButton(SubscriptionController controller) {
    return GestureDetector(
      onTap: controller.continueFree,
      child: Container(
        width: double.infinity,
        height: 41.h,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            'Continue Free',
            textAlign: TextAlign.center,
            style: AppFonts.poppinsMedium(
              fontSize: 14,
              color: Colors.white,
              height: 1.50,
            ),
          ),
        ),
      ),
    );
  }
}
