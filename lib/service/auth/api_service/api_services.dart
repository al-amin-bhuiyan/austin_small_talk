import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_constant/api_constant.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';
import '../models/verify_otp_request_model.dart';
import '../models/verify_otp_response_model.dart';
import '../models/resend_otp_request_model.dart';
import '../models/resend_otp_response_model.dart';
import '../models/refresh_token_request_model.dart';
import '../models/refresh_token_response_model.dart';
import '../models/verify_token_request_model.dart';
import '../models/verify_token_response_model.dart';

/// API Services for Authentication
class ApiServices {
  /// Register new user
  Future<RegisterResponseModel> registerUser(RegisterRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.register),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('API Request: POST ${ApiConstant.register}');
      print('Request Body: ${jsonEncode(request.toJson())}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return RegisterResponseModel.fromJson(jsonData);
      } else {
        // Try to parse error message from response
        try {
          final dynamic decodedResponse = jsonDecode(response.body);
          
          String errorMessage = 'Registration failed';
          
          if (decodedResponse is Map<String, dynamic>) {
            // Check for different error message formats
            errorMessage = decodedResponse['message'] ?? 
                          decodedResponse['error'] ?? 
                          decodedResponse['msg'] ??
                          decodedResponse['detail'] ??
                          'Registration failed';
            
            // Check if error is in email field (common Django format)
            if (decodedResponse['email'] != null) {
              if (decodedResponse['email'] is List && (decodedResponse['email'] as List).isNotEmpty) {
                errorMessage = decodedResponse['email'][0].toString();
              } else if (decodedResponse['email'] is String) {
                errorMessage = decodedResponse['email'];
              }
            }
          } else if (decodedResponse is String) {
            errorMessage = decodedResponse;
          }
          
          throw Exception(errorMessage);
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('Registration failed with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Verify OTP
  Future<VerifyOtpResponseModel> verifyOtp(VerifyOtpRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.verifyOtp),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('API Request: POST ${ApiConstant.verifyOtp}');
      print('Request Body: ${jsonEncode(request.toJson())}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return VerifyOtpResponseModel.fromJson(jsonData);
      } else {
        // Try to parse error message from response
        try {
          final dynamic decodedResponse = jsonDecode(response.body);
          
          String errorMessage = 'OTP verification failed';
          
          if (decodedResponse is Map<String, dynamic>) {
            // Check for errors object with non_field_errors (common Django REST format)
            if (decodedResponse['errors'] != null && decodedResponse['errors'] is Map) {
              final errors = decodedResponse['errors'] as Map<String, dynamic>;
              
              // Check non_field_errors
              if (errors['non_field_errors'] != null) {
                if (errors['non_field_errors'] is List && (errors['non_field_errors'] as List).isNotEmpty) {
                  errorMessage = errors['non_field_errors'][0].toString();
                } else if (errors['non_field_errors'] is String) {
                  errorMessage = errors['non_field_errors'];
                }
              }
            }
            
            // Check for different error message formats
            if (errorMessage == 'OTP verification failed') {
              errorMessage = decodedResponse['message'] ?? 
                            decodedResponse['error'] ?? 
                            decodedResponse['msg'] ??
                            decodedResponse['detail'] ??
                            'OTP verification failed';
            }
            
            // Check if error is in otp field
            if (decodedResponse['otp'] != null) {
              if (decodedResponse['otp'] is List && (decodedResponse['otp'] as List).isNotEmpty) {
                errorMessage = decodedResponse['otp'][0].toString();
              } else if (decodedResponse['otp'] is String) {
                errorMessage = decodedResponse['otp'];
              }
            }
            
            // Check if error is in email field
            if (decodedResponse['email'] != null) {
              if (decodedResponse['email'] is List && (decodedResponse['email'] as List).isNotEmpty) {
                errorMessage = decodedResponse['email'][0].toString();
              } else if (decodedResponse['email'] is String) {
                errorMessage = decodedResponse['email'];
              }
            }
          } else if (decodedResponse is String) {
            errorMessage = decodedResponse;
          }
          
          throw Exception(errorMessage);
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('OTP verification failed with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Resend OTP
  Future<ResendOtpResponseModel> resendOtp(ResendOtpRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.resendOtp),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('API Request: POST ${ApiConstant.resendOtp}');
      print('Request Body: ${jsonEncode(request.toJson())}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return ResendOtpResponseModel.fromJson(jsonData);
      } else {
        // Try to parse error message from response
        try {
          final dynamic decodedResponse = jsonDecode(response.body);
          
          String errorMessage = 'Failed to resend OTP';
          
          if (decodedResponse is Map<String, dynamic>) {
            // Check for errors object with email field
            if (decodedResponse['errors'] != null && decodedResponse['errors'] is Map) {
              final errors = decodedResponse['errors'] as Map<String, dynamic>;
              
              // Check email errors
              if (errors['email'] != null) {
                if (errors['email'] is List && (errors['email'] as List).isNotEmpty) {
                  errorMessage = errors['email'][0].toString();
                } else if (errors['email'] is String) {
                  errorMessage = errors['email'];
                }
              }
              
              // Check non_field_errors
              if (errors['non_field_errors'] != null) {
                if (errors['non_field_errors'] is List && (errors['non_field_errors'] as List).isNotEmpty) {
                  errorMessage = errors['non_field_errors'][0].toString();
                } else if (errors['non_field_errors'] is String) {
                  errorMessage = errors['non_field_errors'];
                }
              }
            }
            
            // Check for different error message formats
            if (errorMessage == 'Failed to resend OTP') {
              errorMessage = decodedResponse['message'] ?? 
                            decodedResponse['error'] ?? 
                            decodedResponse['msg'] ??
                            decodedResponse['detail'] ??
                            'Failed to resend OTP';
            }
            
            // Check if error is directly in email field
            if (decodedResponse['email'] != null) {
              if (decodedResponse['email'] is List && (decodedResponse['email'] as List).isNotEmpty) {
                errorMessage = decodedResponse['email'][0].toString();
              } else if (decodedResponse['email'] is String) {
                errorMessage = decodedResponse['email'];
              }
            }
          } else if (decodedResponse is String) {
            errorMessage = decodedResponse;
          }
          
          throw Exception(errorMessage);
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('Failed to resend OTP with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Login user
  Future<LoginResponseModel> loginUser(LoginRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('API Request: POST ${ApiConstant.login}');
      print('Request Body: ${jsonEncode(request.toJson())}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return LoginResponseModel.fromJson(jsonData);
      } else {
        // Try to parse error message from response
        try {
          final dynamic decodedResponse = jsonDecode(response.body);
          
          String errorMessage = 'Login failed';
          
          if (decodedResponse is Map<String, dynamic>) {
            // Check for errors object
            if (decodedResponse['errors'] != null && decodedResponse['errors'] is Map) {
              final errors = decodedResponse['errors'] as Map<String, dynamic>;
              
              // Check non_field_errors
              if (errors['non_field_errors'] != null) {
                if (errors['non_field_errors'] is List && (errors['non_field_errors'] as List).isNotEmpty) {
                  errorMessage = errors['non_field_errors'][0].toString();
                } else if (errors['non_field_errors'] is String) {
                  errorMessage = errors['non_field_errors'];
                }
              }
              
              // Check email errors
              if (errors['email'] != null) {
                if (errors['email'] is List && (errors['email'] as List).isNotEmpty) {
                  errorMessage = errors['email'][0].toString();
                } else if (errors['email'] is String) {
                  errorMessage = errors['email'];
                }
              }
            }
            
            // Check for different error message formats
            if (errorMessage == 'Login failed') {
              errorMessage = decodedResponse['message'] ?? 
                            decodedResponse['error'] ?? 
                            decodedResponse['msg'] ??
                            decodedResponse['detail'] ??
                            'Login failed';
            }
            
            // Check if error is directly in email or password field
            if (decodedResponse['email'] != null) {
              if (decodedResponse['email'] is List && (decodedResponse['email'] as List).isNotEmpty) {
                errorMessage = decodedResponse['email'][0].toString();
              } else if (decodedResponse['email'] is String) {
                errorMessage = decodedResponse['email'];
              }
            }
            
            if (decodedResponse['password'] != null) {
              if (decodedResponse['password'] is List && (decodedResponse['password'] as List).isNotEmpty) {
                errorMessage = decodedResponse['password'][0].toString();
              } else if (decodedResponse['password'] is String) {
                errorMessage = decodedResponse['password'];
              }
            }
          } else if (decodedResponse is String) {
            errorMessage = decodedResponse;
          }
          
          throw Exception(errorMessage);
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('Login failed with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Refresh access token using refresh token
  Future<RefreshTokenResponseModel> refreshAccessToken(RefreshTokenRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.refreshToken),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('API Request: POST ${ApiConstant.refreshToken}');
      print('Request Body: ${jsonEncode(request.toJson())}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return RefreshTokenResponseModel.fromJson(jsonData);
      } else {
        // Try to parse error message from response
        try {
          final dynamic decodedResponse = jsonDecode(response.body);
          
          String errorMessage = 'Token refresh failed';
          
          if (decodedResponse is Map<String, dynamic>) {
            errorMessage = decodedResponse['detail'] ?? 
                          decodedResponse['message'] ?? 
                          decodedResponse['error'] ?? 
                          decodedResponse['msg'] ??
                          'Token refresh failed';
          } else if (decodedResponse is String) {
            errorMessage = decodedResponse;
          }
          
          throw Exception(errorMessage);
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('Token refresh failed with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Verify if access token is valid
  Future<VerifyTokenResponseModel> verifyAccessToken(VerifyTokenRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.verifyToken),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('API Request: POST ${ApiConstant.verifyToken}');
      print('Request Body: ${jsonEncode(request.toJson())}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return VerifyTokenResponseModel.fromJson(jsonData);
      } else {
        // Token is invalid
        try {
          final dynamic decodedResponse = jsonDecode(response.body);
          
          String errorMessage = 'Token is invalid or expired';
          
          if (decodedResponse is Map<String, dynamic>) {
            errorMessage = decodedResponse['detail'] ?? 
                          decodedResponse['message'] ?? 
                          decodedResponse['error'] ?? 
                          decodedResponse['msg'] ??
                          'Token is invalid or expired';
          } else if (decodedResponse is String) {
            errorMessage = decodedResponse;
          }
          
          return VerifyTokenResponseModel.invalid(errorMessage);
        } catch (e) {
          return VerifyTokenResponseModel.invalid('Token is invalid or expired');
        }
      }
    } catch (e) {
      return VerifyTokenResponseModel.invalid('Network error: $e');
    }
  }
}
