import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/custom_assets/custom_assets.dart';
import '../../../../utils/app_fonts/app_fonts.dart';
import '../../../../view/custom_back_button/custom_back_button.dart';
import '../../../../view/custom_start_conversation_button/custom_start_conversation_button.dart';
import 'contact_help_controller.dart';

class ContactHelpScreen extends GetView<ContactHelpController> {
  const ContactHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Register controller if not already registered
    if (!Get.isRegistered<ContactHelpController>()) {
      Get.put(ContactHelpController());
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                      // Description text
                      Text(
                        "If you're facing an issue or need help, we're here for you. Describe your problem and we'll get back to you as soon as possible",
                        style: AppFonts.poppinsRegular(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Subject Field
                      _buildInputField(
                        label: 'Subject',
                        hintText: 'Short title of your issue',
                        controller: controller.subjectController,
                        maxLines: 1,
                      ),

                      // Email Address Field
                      _buildInputField(
                        label: 'Email Address',
                        hintText: 'Write your email',
                        controller: controller.emailController,
                        maxLines: 1,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      // Message Field
                      _buildInputField(
                        label: 'Message',
                        hintText: 'Please explain what happend...',
                        controller: controller.messageController,
                        maxLines: 4,
                      ),

                      // Attach Screenshot
                      GetBuilder<ContactHelpController>(
                        builder: (_) => _buildAttachmentField(),
                      ),
                      SizedBox(height: 20.h),

                      // Send Message Button
                      GetBuilder<ContactHelpController>(
                        builder: (_) => CustomStartConversationButton(
                          label: 'Send Message',
                          isLoading: controller.isLoading,
                          onPressed: controller.sendMessage,
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
              'Contact Support',
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

  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.poppinsMedium(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.w,
              ),
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              style: AppFonts.poppinsRegular(
                fontSize: 14,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppFonts.poppinsRegular(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentField() {
    return GestureDetector(
      onTap: controller.attachScreenshot,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                controller.attachedImagePath != null
                    ? 'Screenshot attached'
                    : 'Attach screenshot ( if relevent )',
                style: AppFonts.poppinsRegular(
                  fontSize: 14,
                  color: controller.attachedImagePath != null
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
            if (controller.attachedImagePath != null)
              GestureDetector(
                onTap: controller.removeAttachment,
                child: Icon(
                  Icons.close,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 20.sp,
                ),
              )
            else
              Icon(
                Icons.attach_file,
                color: Colors.white.withValues(alpha: 0.5),
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}