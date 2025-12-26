import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_route/app_path.dart';

/// Controller for Navigation Bar - handles bottom navigation
class NavBarController extends GetxController {
  // Observable for the current selected index
  var selectedIndex = 0.obs;

  /// Method to change the selected index and navigate
  void changeIndex(int index, BuildContext context) {
    selectedIndex.value = index;

    // Navigate based on index
    switch (index) {
      case 0:
        context.go(AppPath.home);
        break;
      case 1:
        context.go(AppPath.history);
        break;
      case 2:
        context.go(AppPath.aitalk);
        break;
      case 3:
        context.go(AppPath.profile);
        break;
    }
  }

  /// Method to get the current route based on index
  String getCurrentRoute() {
    switch (selectedIndex.value) {
      case 0:
        return AppPath.home;
      case 1:
        return AppPath.history;
      case 2:
        return AppPath.aitalk;
      case 3:
        return AppPath.profile;
      default:
        return AppPath.home;
    }
  }

  /// Check if a specific tab is selected
  bool isSelected(int index) => selectedIndex.value == index;
}