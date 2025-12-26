import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/custom_assets/custom_assets.dart';
import '../../../../utils/app_fonts/app_fonts.dart';
import '../../../../view/custom_back_button/custom_back_button.dart';

class TermsAndConditionScreen extends StatelessWidget {
  const TermsAndConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 100.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Introduction
                      Text(
                        'By using Small Talk, you agree to the following terms. Please read them carefully before using the app.',
                        style: AppFonts.poppinsRegular(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Section 1
                      _buildSectionTitle('1. Acceptance of Terms'),
                      SizedBox(height: 12.h),
                      Text(
                        'By creating an account or using Small Talk, you agree to comply with these Terms & Conditions and our Privacy Policy. If you do not agree, please stop using the app.',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 24.h),

                      // Section 2
                      _buildSectionTitle('2. Use of the App'),
                      SizedBox(height: 12.h),
                      Text(
                        'You agree to:',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 8.h),
                      _buildSimpleBullet('Use the app for personal, non-commercial purposes'),
                      _buildSimpleBullet('Provide accurate information when creating your account'),
                      _buildSimpleBullet('Not misuse or attempt to disrupt the service'),
                      SizedBox(height: 8.h),
                      Text(
                        'You must be at least 13 years old to use Small Talk.',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 24.h),

                      // Section 3
                      _buildSectionTitle('3. Subscription & Payments'),
                      SizedBox(height: 12.h),
                      _buildSimpleBullet('Small Talk offers a free trial and paid subscription.'),
                      _buildSimpleBullet('Payments are handled through Apple App Store and Google Play.'),
                      _buildSimpleBullet('Subscriptions renew automatically unless canceled 24 hours before the renewal date.'),
                      _buildSimpleBullet('Refunds follow App Store and Google Play policies.'),
                      SizedBox(height: 24.h),

                      // Section 4
                      _buildSectionTitle('4. AI Conversations'),
                      SizedBox(height: 12.h),
                      _buildSimpleBullet('AI-generated responses are for practice only and may not always be accurate.'),
                      _buildSimpleBullet('Small Talk is not liable for decisions made based on AI outputs.'),
                      _buildSimpleBullet('Conversations are processed in real time; raw audio is not stored.'),
                      SizedBox(height: 24.h),

                      // Section 5
                      _buildSectionTitle('5. User Content'),
                      SizedBox(height: 12.h),
                      Text(
                        'Your conversation summaries, scenario inputs, and feedback logs belong to you.',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'You grant Small Talk permission to process this content to improve your experience.',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'You may not upload or create content that is:',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 8.h),
                      _buildSimpleBullet('Harmful or abusive'),
                      _buildSimpleBullet('Illegal'),
                      _buildSimpleBullet('Misleading'),
                      _buildSimpleBullet('Intended to harass others'),
                      SizedBox(height: 24.h),

                      // Section 6
                      _buildSectionTitle('6. Prohibited Activities'),
                      SizedBox(height: 12.h),
                      Text(
                        'You agree not to:',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 8.h),
                      _buildSimpleBullet('Attempt to access restricted areas of the app'),
                      _buildSimpleBullet('Reverse engineer any part of the service'),
                      _buildSimpleBullet('Use the app for harmful or malicious purposes'),
                      _buildSimpleBullet('Share your account with others'),
                      SizedBox(height: 24.h),

                      // Section 7
                      _buildSectionTitle('7. Account Termination'),
                      SizedBox(height: 12.h),
                      Text(
                        'We reserve the right to suspend or terminate accounts that violate these Terms or impact the safety of the platform.',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 24.h),

                      // Section 8
                      _buildSectionTitle('8. Liability Disclaimer'),
                      SizedBox(height: 12.h),
                      Text(
                        'Small Talk provides communication practice tools but does not guarantee specific learning outcomes. We are not responsible for:',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 8.h),
                      _buildSimpleBullet('Network issues'),
                      _buildSimpleBullet('Device malfunctions'),
                      _buildSimpleBullet('Third-party service interruptions'),
                      SizedBox(height: 24.h),

                      // Section 9
                      _buildSectionTitle('9. Changes to the Terms'),
                      SizedBox(height: 12.h),
                      Text(
                        'We may update these Terms & Conditions at any time. The "Last Updated" date will show the newest version.',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 24.h),

                      // Section 10
                      _buildSectionTitle('10. Contact Us'),
                      SizedBox(height: 12.h),
                      Text(
                        'If you have questions about these Terms, please contact:',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'support@smalltalk.ai',
                        style: AppFonts.poppinsMedium(
                          fontSize: 14,
                          color: const Color(0xFF4A9FFF),
                        ),
                      ),
                    ],
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
              'Terms & Conditions',
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppFonts.poppinsSemiBold(
        fontSize: 16,
        color: Colors.white,
      ),
    );
  }

  TextStyle _bodyStyle() {
    return AppFonts.poppinsRegular(
      fontSize: 14,
      color: Colors.white.withValues(alpha: 0.8),
      height: 1.5,
    );
  }

  Widget _buildSimpleBullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8.h),
            width: 6.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: AppFonts.poppinsRegular(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}