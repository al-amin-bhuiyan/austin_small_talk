import 'package:austin_small_talk/core/custom_assets/custom_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_fonts/app_fonts.dart';
import 'profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

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
              _buildAppBar(context),
              
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        SizedBox(height: 24.h),
                        
                        // Profile Header
                        _buildProfileHeader(controller),
                        
                        SizedBox(height: 22.h),
                        
                        // Menu Items Group 1
                        _buildMenuGroup1(controller, context),
                        
                        SizedBox(height: 16.h),
                        
                        // Menu Items Group 2
                        _buildMenuGroup2(controller, context),
                        
                        SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                ),
              ),
              
              // ✅ Nav bar removed - MainNavigation provides it
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // GestureDetector(
          //   onTap: () => Navigator.pop(context),
          //   child: Container(
          //     width: 40.w,
          //     height: 40.h,
          //     decoration: BoxDecoration(
          //       color: Colors.white.withValues(alpha: 0.1),
          //       shape: BoxShape.circle,
          //     ),
          //    /* child: Icon(
          //       Icons.arrow_back_ios_new,
          //       color: AppColors.whiteColor,
          //       size: 18.sp,
          //     ),*/
          //   ),
          // ),
          Expanded(
            child: Center(
              child: Text(
                'Profile',
                style: AppFonts.poppinsSemiBold(
                  fontSize: 18,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 40.w), // Balance
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ProfileController controller) {
    return Container(
      width: double.infinity,
      height: 186.h,
      decoration: BoxDecoration(
        color: AppColors.profile_item_background,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          // Avatar
          Obx(() {
            final imageUrl = controller.userAvatar.value;
            return Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6B8CFF),
                    Color(0xFF8B5CF6),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: ClipOval(
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 94.w,
                          height: 94.h,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          CustomAssets.person,
                          width: 94.w,
                          height: 94.h,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            );
          }),

          SizedBox(height: 16.h),

          // Name
          Obx(
            () => Text(
              controller.userName.value,
              style: AppFonts.poppinsSemiBold(
                fontSize: 20,
                color: AppColors.whiteColor,
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Email
          Obx(
            () => Text(
              controller.userEmail.value,
              style: AppFonts.poppinsRegular(
                fontSize: 14,
                color: AppColors.whiteColor.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroup1(ProfileController controller, BuildContext context) {
    return Container(
      decoration: BoxDecoration(

        color: AppColors.profile_item_background,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Column(
        children: [
          _buildMenuItem(

            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () => controller.onEditProfile(context),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.attach_money_rounded,
            title: 'Subscription',
            onTap: () => controller.onSubscription(context),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notification',
            onTap: () => controller.onNotification(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroup2(ProfileController controller, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.profile_item_background,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Column(
        children: [
          _buildMenuItem(

            icon: Icons.security,
            title: 'Security',
            onTap: () => controller.onSecurity(context),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.headphones_sharp,
            title: 'Support & Help',
            onTap: () => controller.onSupportHelp(context),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () => _showLogoutDialog(context, controller),
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 34.w,
              height: 34.h,
              decoration: ShapeDecoration(
                color: const Color(0xFFF4F7FD),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignOutside,
                    color: const Color(0xFFC6C5C6),
                  ),
                  borderRadius: BorderRadius.circular(17.r),
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20.sp,
                  color: Colors.black,
                ),
              ),
            ),
            
            SizedBox(width: 16.w),
            
            // Title
            Expanded(
              child: Text(
                title,
                style: AppFonts.poppinsMedium(
                  fontSize: 16,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
            
            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.whiteColor.withValues(alpha: 1.5),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Divider(
        color: Colors.grey.withValues(alpha: 0.34),
        height: 1,
        thickness: 2,
      ),
    );
  }

  /// Show custom logout dialog
  void _showLogoutDialog(BuildContext context, ProfileController controller) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 276.w,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logout Icon
                Container(
                  width: 56.w,
                  height: 56.h,

                  child: Center(
                    child: SvgPicture.asset(
                      CustomAssets.logout_dialog_icon,
                      width: 32.w,
                      height: 32.h,
                    ),
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Title
                Text(
                  'Logout from the app',
                  style: AppFonts.poppinsSemiBold(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Logout Button
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // Close dialog
                    controller.performLogout(context); // Perform logout
                  },
                  child: Container(
                    width: double.infinity,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: AppColors.logout,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        'Logout',
                        style: AppFonts.poppinsMedium(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
