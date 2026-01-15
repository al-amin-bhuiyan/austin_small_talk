import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Your API Constants
  static const String baseUrl = 'http://10.10.7.74:8001/';
  // Assuming 'smallTalk' was a prefix you defined elsewhere, 
  // adjusted here to match the structure you likely intended.
  static const String googleAuthEndpoint = '${baseUrl}accounts/user/google-auth/';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // scopes: ['email', 'profile'], // Usually not needed for basic auth
  );

  Future<void> signUpWithGoogle() async {
    try {
      // 1. Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }

      // 2. Obtain the auth details (idToken is crucial here)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken; // Sometimes backend needs this too

      if (idToken == null) {
        throw Exception('Failed to retrieve Google ID Token');
      }

      // 3. Send the token to your Backend
      await _authenticateWithBackend(idToken, accessToken);
     
    } catch (error) {
      if (kDebugMode) {
        print('Google Sign-In Error: $error');
      }
      rethrow;
    }
  }

  Future<void> _authenticateWithBackend(String idToken, String? accessToken) async {
    try {
      final response = await http.post(
        Uri.parse(googleAuthEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          // Adjust these keys based on what your Django/Backend expects
          'access_token': accessToken, 
          'id_token': idToken,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // 4. Handle Success: Save your backend's JWT/Token
        String backendToken = data['token'] ?? data['access'];
        print('Backend Login Success: $backendToken');
        
        // TODO: Save 'backendToken' to secure storage (flutter_secure_storage)
        // TODO: Navigate to Home Screen
      } else {
        print('Backend Error: ${response.body}');
        throw Exception('Failed to authenticate with backend: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    // TODO: Clear stored backend tokens
  }
}
