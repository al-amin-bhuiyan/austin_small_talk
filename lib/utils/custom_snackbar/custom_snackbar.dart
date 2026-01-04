import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// Custom Snackbar Utility using Toastification
class CustomSnackbar {
  /// Show success snackbar
  static void success({
    required BuildContext context,
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    toastification.show(
      context: context,
      title: Text(title),
      description: Text(message),
      autoCloseDuration: duration,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      showProgressBar: true,
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: false,
    );
  }

  /// Show error snackbar
  static void error({
    required BuildContext context,
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 5),
  }) {
    toastification.show(
      context: context,
      title: Text(title),
      description: Text(message),
      autoCloseDuration: duration,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.close, color: Colors.white),
      showProgressBar: true,
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: false,
    );
  }

  /// Show warning snackbar
  static void warning({
    required BuildContext context,
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 5),
  }) {
    toastification.show(
      context: context,
      title: Text(title),
      description: Text(message),
      autoCloseDuration: duration,
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      showProgressBar: true,
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: false,
    );
  }

  /// Show info snackbar
  static void info({
    required BuildContext context,
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 5),
  }) {
    toastification.show(
      context: context,
      title: Text(title),
      description: Text(message),
      autoCloseDuration: duration,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.info_outline, color: Colors.white),
      showProgressBar: true,
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: false,
    );
  }
}
