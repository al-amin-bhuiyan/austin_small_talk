import 'package:http/http.dart' as http;
import '../global/shared_preference.dart';
import '../global/token_manager.dart';

/// HTTP Client with automatic token refresh
class AuthenticatedHttpClient {
  /// Make an authenticated GET request
  static Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final token = await TokenManager.getValidAccessToken();
    
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    final response = await http.get(
      Uri.parse(url),
      headers: requestHeaders,
    );

    // Handle 401 Unauthorized
    if (response.statusCode == 401) {
      final refreshed = await TokenManager.handleUnauthorized();
      
      if (refreshed) {
        // Retry the request with new token
        final newToken = SharedPreferencesUtil.getAccessToken();
        requestHeaders['Authorization'] = 'Bearer $newToken';
        
        return await http.get(
          Uri.parse(url),
          headers: requestHeaders,
        );
      }
    }

    return response;
  }

  /// Make an authenticated POST request
  static Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await TokenManager.getValidAccessToken();
    
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: requestHeaders,
      body: body,
    );

    // Handle 401 Unauthorized
    if (response.statusCode == 401) {
      final refreshed = await TokenManager.handleUnauthorized();
      
      if (refreshed) {
        // Retry the request with new token
        final newToken = SharedPreferencesUtil.getAccessToken();
        requestHeaders['Authorization'] = 'Bearer $newToken';
        
        return await http.post(
          Uri.parse(url),
          headers: requestHeaders,
          body: body,
        );
      }
    }

    return response;
  }

  /// Make an authenticated PUT request
  static Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await TokenManager.getValidAccessToken();
    
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    final response = await http.put(
      Uri.parse(url),
      headers: requestHeaders,
      body: body,
    );

    // Handle 401 Unauthorized
    if (response.statusCode == 401) {
      final refreshed = await TokenManager.handleUnauthorized();
      
      if (refreshed) {
        // Retry the request with new token
        final newToken = SharedPreferencesUtil.getAccessToken();
        requestHeaders['Authorization'] = 'Bearer $newToken';
        
        return await http.put(
          Uri.parse(url),
          headers: requestHeaders,
          body: body,
        );
      }
    }

    return response;
  }

  /// Make an authenticated DELETE request
  static Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    final token = await TokenManager.getValidAccessToken();
    
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    final response = await http.delete(
      Uri.parse(url),
      headers: requestHeaders,
    );

    // Handle 401 Unauthorized
    if (response.statusCode == 401) {
      final refreshed = await TokenManager.handleUnauthorized();
      
      if (refreshed) {
        // Retry the request with new token
        final newToken = SharedPreferencesUtil.getAccessToken();
        requestHeaders['Authorization'] = 'Bearer $newToken';
        
        return await http.delete(
          Uri.parse(url),
          headers: requestHeaders,
        );
      }
    }

    return response;
  }

  /// Make an authenticated PATCH request
  static Future<http.Response> patch(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await TokenManager.getValidAccessToken();
    
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    final response = await http.patch(
      Uri.parse(url),
      headers: requestHeaders,
      body: body,
    );

    // Handle 401 Unauthorized
    if (response.statusCode == 401) {
      final refreshed = await TokenManager.handleUnauthorized();
      
      if (refreshed) {
        // Retry the request with new token
        final newToken = SharedPreferencesUtil.getAccessToken();
        requestHeaders['Authorization'] = 'Bearer $newToken';
        
        return await http.patch(
          Uri.parse(url),
          headers: requestHeaders,
          body: body,
        );
      }
    }

    return response;
  }
}
