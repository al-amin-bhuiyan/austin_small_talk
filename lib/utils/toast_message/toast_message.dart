import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Toast message utility class for handling all kinds of snackbar messages
/// 
/// Usage examples:
/// - ToastMessage.success('Success message')
/// - ToastMessage.error('Error message')
/// - ToastMessage.info('Info message')
/// - ToastMessage.warning('Warning message')
/// - ToastMessage.show(title: 'Title', message: 'Message', type: ToastType.success)
class ToastMessage {
  ToastMessage._();

  /// Show a success toast message
  static void success(String message, {String? title, Duration? duration}) {
    show(
      title: title ?? 'Success',
      message: message,
      type: ToastType.success,
      duration: duration,
    );
  }

  /// Show an error toast message
  static void error(String message, {String? title, Duration? duration}) {
    show(
      title: title ?? 'Error',
      message: message,
      type: ToastType.error,
      duration: duration,
    );
  }

  /// Show an info toast message
  static void info(String message, {String? title, Duration? duration}) {
    show(
      title: title ?? 'Info',
      message: message,
      type: ToastType.info,
      duration: duration,
    );
  }

  /// Show a warning toast message
  static void warning(String message, {String? title, Duration? duration}) {
    show(
      title: title ?? 'Warning',
      message: message,
      type: ToastType.warning,
      duration: duration,
    );
  }

  /// Show a custom toast message
  static void show({
    required String title,
    required String message,
    ToastType type = ToastType.info,
    Duration? duration,
    SnackPosition position = SnackPosition.BOTTOM,
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? borderRadius,
    bool isDismissible = true,
    DismissDirection? dismissDirection,
    Widget? icon,
    bool showProgressIndicator = false,
    Color? backgroundColor,
    Color? textColor,
  }) {
    // Get colors based on toast type
    final colors = _getColors(type);

    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: backgroundColor ?? colors.backgroundColor,
      colorText: textColor ?? colors.textColor,
      duration: duration ?? const Duration(seconds: 3),
      margin: margin ?? const EdgeInsets.all(10),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      borderRadius: borderRadius ?? 8,
      isDismissible: isDismissible,
      dismissDirection: dismissDirection ?? DismissDirection.horizontal,
      icon: icon ?? _getIcon(type),
      showProgressIndicator: showProgressIndicator,
      snackStyle: SnackStyle.FLOATING,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  /// Get icon based on toast type
  static Widget? _getIcon(ToastType type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case ToastType.success:
        iconData = Icons.check_circle;
        iconColor = Colors.white;
        break;
      case ToastType.error:
        iconData = Icons.error;
        iconColor = Colors.white;
        break;
      case ToastType.warning:
        iconData = Icons.warning;
        iconColor = Colors.white;
        break;
      case ToastType.info:
        iconData = Icons.info;
        iconColor = Colors.white;
        break;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 28,
    );
  }

  /// Get colors based on toast type
  static _ToastColors _getColors(ToastType type) {
    switch (type) {
      case ToastType.success:
        return _ToastColors(
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      case ToastType.error:
        return _ToastColors(
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      case ToastType.warning:
        return _ToastColors(
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
      case ToastType.info:
        return _ToastColors(
          backgroundColor: Colors.blue,
          textColor: Colors.white,
        );
    }
  }
}

/// Toast type enum
enum ToastType {
  success,
  error,
  warning,
  info,
}

/// Internal class to hold toast colors
class _ToastColors {
  final Color backgroundColor;
  final Color textColor;

  _ToastColors({
    required this.backgroundColor,
    required this.textColor,
  });
}
