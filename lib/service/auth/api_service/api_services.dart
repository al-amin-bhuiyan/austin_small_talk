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
import '../models/forgot_password_request_model.dart';
import '../models/forgot_password_response_model.dart';
import '../models/reset_password_otp_request_model.dart';
import '../models/reset_password_otp_response_model.dart';
import '../models/set_new_password_request_model.dart';
import '../models/set_new_password_response_model.dart';
import '../models/change_password_request_model.dart';
import '../models/change_password_response_model.dart';

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

  /// Send reset password email (Forgot Password)
  Future<ForgotPasswordResponseModel> sendResetPasswordEmail(ForgotPasswordRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.forgotPassword),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('API Request: POST ${ApiConstant.forgotPassword}');
      print('Request Body: ${jsonEncode(request.toJson())}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return ForgotPasswordResponseModel.fromJson(jsonData);
      } else {
        // Try to parse error message from response
        try {
          final dynamic decodedResponse = jsonDecode(response.body);
          
          String errorMessage = 'Failed to send reset password email';
          
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
            if (errorMessage == 'Failed to send reset password email') {
              errorMessage = decodedResponse['message'] ?? 
                            decodedResponse['error'] ?? 
                            decodedResponse['msg'] ??
                            decodedResponse['detail'] ??
                            'Failed to send reset password email';
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
          throw Exception('Failed to send reset password email with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Verify OTP for password reset (Forgot Password Flow)
  Future<ResetPasswordOtpResponseModel> resetPasswordOtp(ResetPasswordOtpRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.resetPasswordOtp),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('API Request: POST ${ApiConstant.resetPasswordOtp}');
      print('Request Body: ${jsonEncode(request.toJson())}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return ResetPasswordOtpResponseModel.fromJson(jsonData);
      } else {
        // Try to parse error message from response
        try {
          final dynamic decodedResponse = jsonDecode(response.body);
          
          String errorMessage = 'Failed to verify OTP';
          
          if (decodedResponse is Map<String, dynamic>) {
            // Check for non_field_errors
            if (decodedResponse['non_field_errors'] != null) {
              if (decodedResponse['non_field_errors'] is List && 
                  (decodedResponse['non_field_errors'] as List).isNotEmpty) {
                errorMessage = decodedResponse['non_field_errors'][0].toString();
              }
            }
            
            // Check for errors object
            if (decodedResponse['errors'] != null && decodedResponse['errors'] is Map) {
              final errors = decodedResponse['errors'] as Map<String, dynamic>;
              
              // Check non_field_errors inside errors
              if (errors['non_field_errors'] != null) {
                if (errors['non_field_errors'] is List && 
                    (errors['non_field_errors'] as List).isNotEmpty) {
                  errorMessage = errors['non_field_errors'][0].toString();
                }
              }
              
              // Check otp errors
              if (errors['otp'] != null) {
                if (errors['otp'] is List && (errors['otp'] as List).isNotEmpty) {
                  errorMessage = errors['otp'][0].toString();
                } else if (errors['otp'] is String) {
                  errorMessage = errors['otp'];
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
            if (errorMessage == 'Failed to verify OTP') {
              errorMessage = decodedResponse['message'] ?? 
                            decodedResponse['error'] ?? 
                            decodedResponse['msg'] ??
                            decodedResponse['detail'] ??
                            'Failed to verify OTP';
            }
            
            // Check direct otp field
            if (decodedResponse['otp'] != null) {
              if (decodedResponse['otp'] is List && (decodedResponse['otp'] as List).isNotEmpty) {
                errorMessage = decodedResponse['otp'][0].toString();
              } else if (decodedResponse['otp'] is String) {
                errorMessage = decodedResponse['otp'];
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
          throw Exception('Failed to verify OTP with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Set new password (Forgot Password Flow - Final Step)
  Future<SetNewPasswordResponseModel> setNewPassword(SetNewPasswordRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.setNewPassword),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('API Request: POST ${ApiConstant.setNewPassword}');
      print('Request Body: ${jsonEncode(request.toJson())}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return SetNewPasswordResponseModel.fromJson(jsonData);
      } else {
        // Try to parse error message from response
        try {
          final dynamic decodedResponse = jsonDecode(response.body);
          
          String errorMessage = 'Failed to set new password';
          
          if (decodedResponse is Map<String, dynamic>) {
            // Check for non_field_errors
            if (decodedResponse['non_field_errors'] != null) {
              if (decodedResponse['non_field_errors'] is List && 
                  (decodedResponse['non_field_errors'] as List).isNotEmpty) {
                errorMessage = decodedResponse['non_field_errors'][0].toString();
              }
            }
            
            // Check for errors object
            if (decodedResponse['errors'] != null && decodedResponse['errors'] is Map) {
              final errors = decodedResponse['errors'] as Map<String, dynamic>;
              
              // Check non_field_errors inside errors
              if (errors['non_field_errors'] != null) {
                if (errors['non_field_errors'] is List && 
                    (errors['non_field_errors'] as List).isNotEmpty) {
                  errorMessage = errors['non_field_errors'][0].toString();
                }
              }
              
              // Check new_password errors
              if (errors['new_password'] != null) {
                if (errors['new_password'] is List && (errors['new_password'] as List).isNotEmpty) {
                  errorMessage = errors['new_password'][0].toString();
                } else if (errors['new_password'] is String) {
                  errorMessage = errors['new_password'];
                }
              }
              
              // Check new_password2 errors
              if (errors['new_password2'] != null) {
                if (errors['new_password2'] is List && (errors['new_password2'] as List).isNotEmpty) {
                  errorMessage = errors['new_password2'][0].toString();
                } else if (errors['new_password2'] is String) {
                  errorMessage = errors['new_password2'];
                }
              }
              
              // Check reset_token errors
              if (errors['reset_token'] != null) {
                if (errors['reset_token'] is List && (errors['reset_token'] as List).isNotEmpty) {
                  errorMessage = errors['reset_token'][0].toString();
                } else if (errors['reset_token'] is String) {
                  errorMessage = errors['reset_token'];
                }
              }
            }
            
            // Check for different error message formats
            if (errorMessage == 'Failed to set new password') {
              errorMessage = decodedResponse['message'] ?? 
                            decodedResponse['error'] ?? 
                            decodedResponse['msg'] ??
                            decodedResponse['detail'] ??
                            'Failed to set new password';
            }
            
            // Check direct password fields
            if (decodedResponse['new_password'] != null) {
              if (decodedResponse['new_password'] is List && (decodedResponse['new_password'] as List).isNotEmpty) {
                errorMessage = decodedResponse['new_password'][0].toString();
              } else if (decodedResponse['new_password'] is String) {
                errorMessage = decodedResponse['new_password'];
              }
            }
            
            if (decodedResponse['new_password2'] != null) {
              if (decodedResponse['new_password2'] is List && (decodedResponse['new_password2'] as List).isNotEmpty) {
                errorMessage = decodedResponse['new_password2'][0].toString();
              } else if (decodedResponse['new_password2'] is String) {
                errorMessage = decodedResponse['new_password2'];
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
          throw Exception('Failed to set new password with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Change password for logged-in user
  Future<ChangePasswordResponseModel> changePassword(
    ChangePasswordRequestModel request,
    String accessToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstant.changePassword),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(request.toJson()),
      );

      print('API Request: POST ${ApiConstant.changePassword}');
      print('Request Body: ${jsonEncode(request.toJson())}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return ChangePasswordResponseModel.fromJson(jsonData);
      } else {
        // Try to parse error message from response
        try {
          final dynamic decodedResponse = jsonDecode(response.body);
          
          String errorMessage = 'Failed to change password';
          
          if (decodedResponse is Map<String, dynamic>) {
            // Check for non_field_errors
            if (decodedResponse['non_field_errors'] != null) {
              if (decodedResponse['non_field_errors'] is List && 
                  (decodedResponse['non_field_errors'] as List).isNotEmpty) {
                errorMessage = decodedResponse['non_field_errors'][0].toString();
              }
            }
            
            // Check for errors object
            if (decodedResponse['errors'] != null && decodedResponse['errors'] is Map) {
              final errors = decodedResponse['errors'] as Map<String, dynamic>;
              
              // Check non_field_errors inside errors
              if (errors['non_field_errors'] != null) {
                if (errors['non_field_errors'] is List && 
                    (errors['non_field_errors'] as List).isNotEmpty) {
                  errorMessage = errors['non_field_errors'][0].toString();
                }
              }
              
              // Check current_password errors
              if (errors['current_password'] != null) {
                if (errors['current_password'] is List && (errors['current_password'] as List).isNotEmpty) {
                  errorMessage = errors['current_password'][0].toString();
                } else if (errors['current_password'] is String) {
                  errorMessage = errors['current_password'];
                }
              }
              
              // Check new_password errors
              if (errors['new_password'] != null) {
                if (errors['new_password'] is List && (errors['new_password'] as List).isNotEmpty) {
                  errorMessage = errors['new_password'][0].toString();
                } else if (errors['new_password'] is String) {
                  errorMessage = errors['new_password'];
                }
              }
              
              // Check confirm_new_password errors
              if (errors['confirm_new_password'] != null) {
                if (errors['confirm_new_password'] is List && (errors['confirm_new_password'] as List).isNotEmpty) {
                  errorMessage = errors['confirm_new_password'][0].toString();
                } else if (errors['confirm_new_password'] is String) {
                  errorMessage = errors['confirm_new_password'];
                }
              }
            }
            
            // Check for different error message formats
            if (errorMessage == 'Failed to change password') {
              errorMessage = decodedResponse['message'] ?? 
                            decodedResponse['error'] ?? 
                            decodedResponse['msg'] ??
                            decodedResponse['detail'] ??
                            'Failed to change password';
            }
            
            // Check direct password fields
            if (decodedResponse['current_password'] != null) {
              if (decodedResponse['current_password'] is List && (decodedResponse['current_password'] as List).isNotEmpty) {
                errorMessage = decodedResponse['current_password'][0].toString();
              } else if (decodedResponse['current_password'] is String) {
                errorMessage = decodedResponse['current_password'];
              }
            }
            
            if (decodedResponse['new_password'] != null) {
              if (decodedResponse['new_password'] is List && (decodedResponse['new_password'] as List).isNotEmpty) {
                errorMessage = decodedResponse['new_password'][0].toString();
              } else if (decodedResponse['new_password'] is String) {
                errorMessage = decodedResponse['new_password'];
              }
            }
            
            if (decodedResponse['confirm_new_password'] != null) {
              if (decodedResponse['confirm_new_password'] is List && (decodedResponse['confirm_new_password'] as List).isNotEmpty) {
                errorMessage = decodedResponse['confirm_new_password'][0].toString();
              } else if (decodedResponse['confirm_new_password'] is String) {
                errorMessage = decodedResponse['confirm_new_password'];
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
          throw Exception('Failed to change password with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }
}
