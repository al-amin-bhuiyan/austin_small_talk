import '../../service/auth/api_service/api_services.dart';
import '../../service/auth/models/refresh_token_request_model.dart';
import '../../service/auth/models/verify_token_request_model.dart';
import 'shared_preference.dart';

/// Token Manager for handling token refresh and validation
class TokenManager {
  static final ApiServices _apiServices = ApiServices();

  /// Check if access token is valid, refresh if needed
  static Future<bool> ensureValidToken() async {
    try {
      final accessToken = SharedPreferencesUtil.getAccessToken();
      
      if (accessToken == null || accessToken.isEmpty) {
        return false;
      }

      // Verify current access token
      final verifyRequest = VerifyTokenRequestModel(token: accessToken);
      final verifyResponse = await _apiServices.verifyAccessToken(verifyRequest);

      if (verifyResponse.isValid) {
        // Token is still valid
        return true;
      }

      // Token is invalid, try to refresh
      return await refreshToken();
    } catch (e) {
      print('Token validation error: $e');
      return await refreshToken();
    }
  }

  /// Refresh access token using refresh token
  static Future<bool> refreshToken() async {
    try {
      final refreshToken = SharedPreferencesUtil.getRefreshToken();
      
      if (refreshToken == null || refreshToken.isEmpty) {
        print('No refresh token available');
        return false;
      }

      // Call refresh token API
      final request = RefreshTokenRequestModel(refresh: refreshToken);
      final response = await _apiServices.refreshAccessToken(request);

      // Save new access token
      await SharedPreferencesUtil.instance.setString('access_token', response.accessToken);
      
      // Update refresh token if provided
      if (response.refreshToken != null && response.refreshToken!.isNotEmpty) {
        await SharedPreferencesUtil.instance.setString('refresh_token', response.refreshToken!);
      }

      print('Token refreshed successfully');
      return true;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  /// Get valid access token (refresh if needed)
  static Future<String?> getValidAccessToken() async {
    final isValid = await ensureValidToken();
    
    if (isValid) {
      return SharedPreferencesUtil.getAccessToken();
    }
    
    return null;
  }

  /// Check if user has valid session
  static Future<bool> hasValidSession() async {
    if (!SharedPreferencesUtil.isLoggedIn()) {
      return false;
    }

    return await ensureValidToken();
  }

  /// Handle unauthorized response (401)
  static Future<bool> handleUnauthorized() async {
    // Try to refresh token
    final refreshed = await refreshToken();
    
    if (!refreshed) {
      // Refresh failed, logout user
      await SharedPreferencesUtil.logout(keepRememberMe: true);
      return false;
    }
    
    return true;
  }
}
