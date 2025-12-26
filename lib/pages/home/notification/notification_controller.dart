import 'package:get/get.dart';
import '../../../core/custom_assets/custom_assets.dart';

/// Controller for Notification Screen
class NotificationController extends GetxController {
  // Observable for loading state
  final RxBool isLoading = false.obs;
  
  // Observable list of notifications
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  /// Load notifications
  void loadNotifications() {
    // Sample notifications
    notifications.value = [
      NotificationItem(
        icon: CustomAssets.daily_topic_ready,
        title: 'Daily Topic Ready',
        description: 'Your new scenario "Social Event" is available',
        time: '9:40 AM',
        isRead: false,
      ),
      NotificationItem(
        icon: CustomAssets.practice_reminder,
        title: 'Practice Reminder',
        description: 'Improve fluency with a 5 minute conversation',
        time: '1 days ago',
        isRead: false,
      ),
    ];
  }

  /// Mark notification as read
  void markAsRead(int index) {
    if (index < notifications.length) {
      notifications[index].isRead = true;
      notifications.refresh();
    }
  }

  /// Clear all notifications
  void clearAll() {
    notifications.clear();
  }
}

/// Notification Item Model
class NotificationItem {
  final String icon;
  final String title;
  final String description;
  final String time;
  bool isRead;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
  });
}
