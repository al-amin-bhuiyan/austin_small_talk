import 'package:get/get.dart';
import '../../core/app_route/app_path.dart';

/// Controller for Navigation Bar - handles bottom navigation with IndexedStack
class NavBarController extends GetxController {
  // Observable for the current selected index
  var selectedIndex = 0.obs;

  /// Method to change the selected index
  /// No navigation needed - IndexedStack handles page switching
  void changeIndex(int index) {
    selectedIndex.value = index;
    print('🔄 Switched to tab $index');
  }

  /// Method to get the current route path based on index
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
  
  /// Set specific tab programmatically
  void setTab(int index) {
    if (index >= 0 && index <= 3) {
      selectedIndex.value = index;
    }
  }
}
