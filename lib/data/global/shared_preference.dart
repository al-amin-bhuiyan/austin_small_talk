import 'package:shared_preferences/shared_preferences.dart';

/// Shared Preferences Utility for storing and retrieving data
class SharedPreferencesUtil {
  static SharedPreferences? _preferences;

  // Keys
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyEmail = 'user_email';
  static const String _keyPassword = 'user_password';
  static const String _keyAccessToken = 'access';
  static const String _keyRefreshToken = 'refresh';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';

  /// Initialize shared preferences
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static SharedPreferences get instance {
    if (_preferences == null) {
      throw Exception('SharedPreferences not initialized. Call init() first.');
    }
    return _preferences!;
  }

  // ==================== Login Related ====================

  /// Save login credentials (when Remember Me is checked)
  static Future<bool> saveLoginCredentials({
    required String email,
    required String password,
  }) async {
    try {
      await instance.setString(_keyEmail, email);
      await instance.setString(_keyPassword, password);
      await instance.setBool(_keyRememberMe, true);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get saved email
  static String? getSavedEmail() {
    return instance.getString(_keyEmail);
  }

  /// Get saved password
  static String? getSavedPassword() {
    return instance.getString(_keyPassword);
  }

  /// Check if Remember Me is enabled
  static bool isRememberMeEnabled() {
    return instance.getBool(_keyRememberMe) ?? false;
  }

  /// Clear login credentials
  static Future<bool> clearLoginCredentials() async {
    try {
      await instance.remove(_keyEmail);
      await instance.remove(_keyPassword);
      await instance.setBool(_keyRememberMe, false);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== Session Related ====================

  /// Save user session after successful login
  static Future<bool> saveUserSession({
    required String accessToken,
    String? refreshToken,
    int? userId,
    String? userName,
    String? email,
  }) async {
    try {
      await instance.setString(_keyAccessToken, accessToken);
      if (refreshToken != null) {
        await instance.setString(_keyRefreshToken, refreshToken);
      }
      if (userId != null) {
        await instance.setInt(_keyUserId, userId);
      }
      if (userName != null) {
        await instance.setString(_keyUserName, userName);
      }
      if (email != null) {
        await instance.setString(_keyEmail, email);
      }
      await instance.setBool(_keyIsLoggedIn, true);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get access token
  static String? getAccessToken() {
    return instance.getString(_keyAccessToken);
  }

  /// Get refresh token
  static String? getRefreshToken() {
    return instance.getString(_keyRefreshToken);
  }

  /// Get user ID
  static int? getUserId() {
    return instance.getInt(_keyUserId);
  }

  /// Get user name
  static String? getUserName() {
    return instance.getString(_keyUserName);
  }

  /// Get user email
  static String? getUserEmail() {
    return instance.getString(_keyEmail);
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    return instance.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Logout - clear all user data
  static Future<bool> logout({bool keepRememberMe = false}) async {
    try {
      final rememberMe = isRememberMeEnabled();
      final savedEmail = getSavedEmail();
      final savedPassword = getSavedPassword();

      // Clear all data
      await instance.clear();

      // Restore Remember Me data if needed
      if (keepRememberMe && rememberMe && savedEmail != null && savedPassword != null) {
        await saveLoginCredentials(
          email: savedEmail,
          password: savedPassword,
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== General Utility ====================

  /// Save string value
  static Future<bool> setString(String key, String value) async {
    return await instance.setString(key, value);
  }

  /// Get string value
  static String? getString(String key) {
    return instance.getString(key);
  }

  /// Save int value
  static Future<bool> setInt(String key, int value) async {
    return await instance.setInt(key, value);
  }

  /// Get int value
  static int? getInt(String key) {
    return instance.getInt(key);
  }

  /// Save bool value
  static Future<bool> setBool(String key, bool value) async {
    return await instance.setBool(key, value);
  }

  /// Get bool value
  static bool? getBool(String key) {
    return instance.getBool(key);
  }

  /// Remove a specific key
  static Future<bool> remove(String key) async {
    return await instance.remove(key);
  }

  /// Clear all data
  static Future<bool> clearAll() async {
    return await instance.clear();
  }
}