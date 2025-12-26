import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/custom_assets/custom_assets.dart';
import '../../../../utils/app_fonts/app_fonts.dart';
import '../../../../view/custom_back_button/custom_back_button.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                        'Small Talk is committed to protecting your privacy. This policy explains what information we collect, how we use it, and the choices you have.',
                        style: AppFonts.poppinsRegular(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Section 1
                      _buildSectionTitle('1. Information We Collect'),
                      SizedBox(height: 12.h),
                      Text(
                        'We collect the following types of data to provide and improve the app:',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 12.h),
                      _buildBulletPoint('Account Information', 'Email address, password, and subscription details.'),
                      _buildBulletPoint('Usage Data', 'Interaction logs, selected scenarios, and non-identifiable conversation summaries.'),
                      _buildBulletPoint('Voice Processing Data', 'Your spoken input is processed in real time to generate responses. We do not store raw audio.'),
                      _buildBulletPoint('Device Information', 'Device model, operating system, and app version.'),
                      SizedBox(height: 24.h),

                      // Section 2
                      _buildSectionTitle('2. How We Use Your Information'),
                      SizedBox(height: 12.h),
                      Text(
                        'We use your data to:',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 8.h),
                      _buildSimpleBullet('Enable AI conversations'),
                      _buildSimpleBullet('Provide personalized feedback'),
                      _buildSimpleBullet('Improve performance and accuracy'),
                      _buildSimpleBullet('Manage subscriptions and payments'),
                      _buildSimpleBullet('Offer customer support'),
                      _buildSimpleBullet('Maintain app security and analytics'),
                      SizedBox(height: 24.h),

                      // Section 3
                      _buildSectionTitle('3. Voice & Conversation Data'),
                      SizedBox(height: 12.h),
                      _buildSimpleBullet('Conversations are processed by AI to generate responses.'),
                      _buildSimpleBullet('Raw audio is not stored.'),
                      _buildSimpleBullet('Text summaries may be saved to your history for your reference.'),
                      _buildSimpleBullet('We do not use your data to identify you personally.'),
                      SizedBox(height: 24.h),

                      // Section 4
                      _buildSectionTitle('4. Third-Party Services'),
                      SizedBox(height: 12.h),
                      Text(
                        'We may use trusted third-party providers for:',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 8.h),
                      _buildSimpleBullet('Speech recognition'),
                      _buildSimpleBullet('Text-to-speech'),
                      _buildSimpleBullet('Subscription payments (Apple & Google)'),
                      SizedBox(height: 8.h),
                      Text(
                        'These services follow their own privacy policies.',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 24.h),

                      // Section 5
                      _buildSectionTitle('5. Your Controls & Choices'),
                      SizedBox(height: 12.h),
                      Text(
                        'You can:',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 8.h),
                      _buildSimpleBullet('Update your email or password'),
                      _buildSimpleBullet('Delete your account'),
                      _buildSimpleBullet('Request removal of stored summaries'),
                      _buildSimpleBullet('Manage or cancel your subscription'),
                      SizedBox(height: 24.h),

                      // Section 6
                      _buildSectionTitle('6. Data Security'),
                      SizedBox(height: 12.h),
                      Text(
                        'We take appropriate measures to protect your information. However, no method of transmission is completely secure.',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 24.h),

                      // Section 7
                      _buildSectionTitle("7. Children's Privacy"),
                      SizedBox(height: 12.h),
                      Text(
                        'Small Talk is not intended for children under 13. We do not knowingly collect information from anyone under this age.',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 24.h),

                      // Section 8
                      _buildSectionTitle('8. Changes to This Policy'),
                      SizedBox(height: 12.h),
                      Text(
                        'We may update this Privacy Policy from time to time. The "Last Updated" date will reflect the most recent version.',
                        style: _bodyStyle(),
                      ),
                      SizedBox(height: 24.h),

                      // Section 9
                      _buildSectionTitle('9. Contact Us'),
                      SizedBox(height: 12.h),
                      Text(
                        'If you have questions or concerns about this Privacy Policy, contact us at:',
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
              'Privacy Policy',
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

  Widget _buildBulletPoint(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
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
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$title\n',
                    style: AppFonts.poppinsMedium(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: description,
                    style: AppFonts.poppinsRegular(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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