import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_route/app_path.dart';
import '../../utils/nav_bar/nav_bar.dart';
import '../../utils/nav_bar/nav_bar_controller.dart';
import '../ai_talk/ai_talk_controller.dart';
import '../home/home.dart';
import '../history/history.dart';
import '../ai_talk/ai_talk.dart';
import '../profile/profile.dart';
import '../profile/profile_controller.dart';

/// Main Navigation Container - Uses IndexedStack to prevent white screen flicker
class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with AutomaticKeepAliveClientMixin {
  NavBarController? _controller;
  
  // Keep this widget alive to prevent rebuilds
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    // Initialize controllers once
    _controller = Get.put(NavBarController(), permanent: true);
    
    // Pre-initialize AI Talk and Profile controllers for instant animation start
    Get.lazyPut(() => AiTalkController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Set the correct tab based on current route (only on first load or route change)
    if (_controller != null) {
      final location = GoRouterState.of(context).uri.path;
      
      int tabIndex = 0;
      switch (location) {
        case AppPath.home:
          tabIndex = 0;
          break;
        case AppPath.history:
          tabIndex = 1;
          break;
        case AppPath.aitalk:
          tabIndex = 2;
          break;
        case AppPath.profile:
          tabIndex = 3;
          break;
      }
      
      // Only update if different to avoid unnecessary rebuilds
      if (_controller!.selectedIndex.value != tabIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _controller!.selectedIndex.value = tabIndex;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      extendBody: true,
      body: Obx(
        () => IndexedStack(
          index: _controller?.selectedIndex.value ?? 0,
          children: const [
            HomeScreen(),
            HistoryScreen(),
            AiTalkScreen(),
            ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _controller != null 
          ? CustomNavBar(controller: _controller!) 
          : const SizedBox.shrink(),
    );
  }
}
