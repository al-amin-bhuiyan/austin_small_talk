import 'package:get/get.dart';

class ProfileNotificationController extends GetxController {
  // Observable notification settings
  final RxBool receiveNewScenario = true.obs;
  final RxBool practiceReminder = true.obs;
  final RxBool securityAlerts = false.obs;
  final RxBool pushNotifications = true.obs;
  final RxBool emailNotifications = false.obs;

  /// Toggle receive new scenario notification
  void toggleReceiveNewScenario(bool value) {
    receiveNewScenario.value = value;
    _saveSettings();
  }

  /// Toggle practice reminder notification
  void togglePracticeReminder(bool value) {
    practiceReminder.value = value;
    _saveSettings();
  }

  /// Toggle security alerts notification
  void toggleSecurityAlerts(bool value) {
    securityAlerts.value = value;
    _saveSettings();
  }

  /// Toggle push notifications
  void togglePushNotifications(bool value) {
    pushNotifications.value = value;
    _saveSettings();
  }

  /// Toggle email notifications
  void toggleEmailNotifications(bool value) {
    emailNotifications.value = value;
    _saveSettings();
  }

  /// Save notification settings
  void _saveSettings() {
    // TODO: Save settings to local storage or API
    print('Notification settings saved');
  }

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  /// Load notification settings
  void _loadSettings() {
    // TODO: Load settings from local storage or API
  }
}
