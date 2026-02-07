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
  bool _isInitialized = false;

  // Keep this widget alive to prevent rebuilds
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Get controller from dependency injection
    if (!Get.isRegistered<NavBarController>()) {
      _controller = Get.put(NavBarController(), permanent: true);
    } else {
      _controller = Get.find<NavBarController>();
    }

    // Pre-initialize AI Talk and Profile controllers
    if (!Get.isRegistered<AiTalkController>()) {
      Get.lazyPut(() => AiTalkController(), fenix: true);
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut(() => ProfileController(), fenix: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      extendBody: true,
      body: Obx(
            () {
          final index = _controller?.selectedIndex.value ?? 0;
          return IndexedStack(
            index: index,
            children: const [
              HomeScreen(),
              HistoryScreen(),
              AiTalkScreen(),
              ProfileScreen(),
            ],
          );
        },
      ),
      bottomNavigationBar: _controller != null
          ? CustomNavBar(controller: _controller!)
          : const SizedBox.shrink(),
    );
  }
}
