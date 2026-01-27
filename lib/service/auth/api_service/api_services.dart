import 'dart:convert';
import 'dart:math';
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
import '../models/create_scenario_request_model.dart';
import '../models/create_scenario_response_model.dart';
import '../models/scenario_model.dart';
import '../models/daily_scenario_model.dart';
import '../models/chat_history_model.dart';
import '../models/session_history_model.dart';
import '../models/delete_account_response_model.dart';
import '../models/user_profile_response_model.dart';
import '../models/chat_session_start_response_model.dart';
import '../models/chat_message_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Get User Profile
  Future<UserProfileResponseModel> getUserProfile({
    required String accessToken,
  }) async {
    try {
      print('═══════════════════════════════════════════');
      print('📡 GET USER PROFILE');
      print('═══════════════════════════════════════════');
      print('🌐 URL: ${ApiConstant.userProfile}');
      print('🔑 Access Token: ${accessToken.length > 20 ? accessToken.substring(0, 20) : accessToken}...');

      final response = await http.get(
        Uri.parse(ApiConstant.userProfile),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('═══════════════════════════════════════════');
      print('📥 RESPONSE');
      print('═══════════════════════════════════════════');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('═══════════════════════════════════════════');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        print('✅ Profile loaded successfully');
        return UserProfileResponseModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        // Unauthorized - token is invalid or expired
        print('❌ 401 UNAUTHORIZED');
        print('💡 Session expired or invalid token');
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 404) {
        // Not Found - endpoint doesn't exist
        print('❌ 404 NOT FOUND');
        print('💡 Endpoint does not exist: ${ApiConstant.userProfile}');
        print('💡 Please check the API endpoint path');
        throw Exception('Profile endpoint not found. Please check API configuration.');
      } else {
        // Handle other error responses
        try {
          final dynamic decodedResponse = jsonDecode(response.body);
          String errorMessage = 'Failed to get user profile';

          if (decodedResponse is Map<String, dynamic>) {
            errorMessage = decodedResponse['message'] ?? 
                          decodedResponse['error'] ?? 
                          decodedResponse['detail'] ??
                          decodedResponse['msg'] ??
                          'Failed to get user profile';
          } else if (decodedResponse is String) {
            errorMessage = decodedResponse;
          }

          print('❌ Error: $errorMessage');
          throw Exception(errorMessage);
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('Failed to get user profile with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('❌ Exception in getUserProfile: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Update User Profile (PATCH)
  Future<UserProfileResponseModel> updateUserProfile({
    required String accessToken,
    String? name,
    String? dateOfBirth,
    String? voice,
    String? image,
  }) async {
    try {
      print('═══════════════════════════════════════════');
      print('📡 UPDATE USER PROFILE (PATCH)');
      print('═══════════════════════════════════════════');
      print('🌐 URL: ${ApiConstant.userProfile}');
      print('🔑 Access Token: ${accessToken.length > 20 ? accessToken.substring(0, 20) : accessToken}...');

      // Build request body with only provided fields
      final Map<String, dynamic> requestBody = {};
      if (name != null) requestBody['name'] = name;
      if (dateOfBirth != null) requestBody['date_of_birth'] = dateOfBirth;
      if (voice != null) requestBody['voice'] = voice;
      if (image != null) requestBody['image'] = image;

      print('📦 Request Body: ${jsonEncode(requestBody)}');

      final response = await http.patch(
        Uri.parse(ApiConstant.userProfile),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      print('═══════════════════════════════════════════');
      print('📥 RESPONSE');
      print('═══════════════════════════════════════════');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('═══════════════════════════════════════════');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        print('✅ Profile updated successfully');
        return UserProfileResponseModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        print('❌ 401 UNAUTHORIZED');
        print('💡 Session expired or invalid token');
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 404) {
        print('❌ 404 NOT FOUND');
        print('💡 Endpoint does not exist: ${ApiConstant.userProfile}');
        throw Exception('Profile endpoint not found.');
      } else {
        // Handle other error responses
        try {
          final dynamic decodedResponse = jsonDecode(response.body);
          String errorMessage = 'Failed to update profile';

          if (decodedResponse is Map<String, dynamic>) {
            errorMessage = decodedResponse['message'] ?? 
                          decodedResponse['error'] ?? 
                          decodedResponse['detail'] ??
                          decodedResponse['msg'] ??
                          'Failed to update profile';
          } else if (decodedResponse is String) {
            errorMessage = decodedResponse;
          }

          print('❌ Error: $errorMessage');
          throw Exception(errorMessage);
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('Failed to update profile with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('❌ Exception in updateUserProfile: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Update User Profile with Image (PATCH - Multipart)
  Future<UserProfileResponseModel> updateUserProfileWithImage({
    required String accessToken,
    String? name,
    String? dateOfBirth,
    String? voice,
    String? imagePath,
  }) async {
    try {
      print('═══════════════════════════════════════════');
      print('📡 UPDATE USER PROFILE WITH IMAGE (PATCH)');
      print('═══════════════════════════════════════════');
      print('🌐 URL: ${ApiConstant.userProfile}');
      print('🔑 Access Token: ${accessToken.length > 20 ? accessToken.substring(0, 20) : accessToken}...');

      // Create multipart request
      var request = http.MultipartRequest('PATCH', Uri.parse(ApiConstant.userProfile));
      
      // Add headers
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.headers['Accept'] = 'application/json';

      // Add text fields
      if (name != null) {
        request.fields['name'] = name;
        print('📝 Name: $name');
      }
      if (dateOfBirth != null) {
        request.fields['date_of_birth'] = dateOfBirth;
        print('📝 Date of Birth: $dateOfBirth');
      }
      if (voice != null) {
        request.fields['voice'] = voice;
        print('📝 Voice: $voice');
      }

      // Add image file if provided
      if (imagePath != null && imagePath.isNotEmpty) {
        var file = await http.MultipartFile.fromPath(
          'image',
          imagePath,
          filename: imagePath.split('/').last,
        );
        request.files.add(file);
        print('📸 Image: ${imagePath.split('/').last}');
      }

      print('═══════════════════════════════════════════');

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('═══════════════════════════════════════════');
      print('📥 RESPONSE');
      print('══════════════════════════════════════════');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('═══════════════════════════════════════════');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        print('✅ Profile updated successfully with image');
        return UserProfileResponseModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        print('❌ 401 UNAUTHORIZED');
        print('💡 Session expired or invalid token');
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 404) {
        print('❌ 404 NOT FOUND');
        print('💡 Endpoint does not exist: ${ApiConstant.userProfile}');
        throw Exception('Profile endpoint not found.');
      } else {
        // Handle other error responses
        try {
          final dynamic decodedResponse = jsonDecode(response.body);
          String errorMessage = 'Failed to update profile';

          if (decodedResponse is Map<String, dynamic>) {
            errorMessage = decodedResponse['message'] ?? 
                          decodedResponse['error'] ?? 
                          decodedResponse['detail'] ??
                          decodedResponse['msg'] ??
                          'Failed to update profile';
          } else if (decodedResponse is String) {
            errorMessage = decodedResponse;
          }

          print('❌ Error: $errorMessage');
          throw Exception(errorMessage);
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('Failed to update profile with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('❌ Exception in updateUserProfileWithImage: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Create Scenario API
  Future<CreateScenarioResponseModel> createScenario({
    required CreateScenarioRequestModel request,
    required String accessToken,
  }) async {
    try {
      print('📡 Creating scenario...');
      print('📝 Request: ${jsonEncode(request.toJson())}');
      print('📝 Access Token: ${accessToken.substring(0, 20)}...');

      final response = await http.post(
        Uri.parse(ApiConstant.createScenario),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(request.toJson()),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        return CreateScenarioResponseModel.fromJson(decodedResponse);
      } else {
        // Handle error response
        try {
          final decodedResponse = jsonDecode(response.body);
          String errorMessage = 'Failed to create scenario';

          if (decodedResponse is Map<String, dynamic>) {
            // Check for specific error fields
            if (decodedResponse['scenario_title'] != null) {
              if (decodedResponse['scenario_title'] is List && (decodedResponse['scenario_title'] as List).isNotEmpty) {
                errorMessage = decodedResponse['scenario_title'][0].toString();
              } else if (decodedResponse['scenario_title'] is String) {
                errorMessage = decodedResponse['scenario_title'];
              }
            } else if (decodedResponse['description'] != null) {
              if (decodedResponse['description'] is List && (decodedResponse['description'] as List).isNotEmpty) {
                errorMessage = decodedResponse['description'][0].toString();
              } else if (decodedResponse['description'] is String) {
                errorMessage = decodedResponse['description'];
              }
            } else if (decodedResponse['difficulty_level'] != null) {
              if (decodedResponse['difficulty_level'] is List && (decodedResponse['difficulty_level'] as List).isNotEmpty) {
                errorMessage = decodedResponse['difficulty_level'][0].toString();
              } else if (decodedResponse['difficulty_level'] is String) {
                errorMessage = decodedResponse['difficulty_level'];
              }
            } else if (decodedResponse['conversation_length'] != null) {
              if (decodedResponse['conversation_length'] is List && (decodedResponse['conversation_length'] as List).isNotEmpty) {
                errorMessage = decodedResponse['conversation_length'][0].toString();
              } else if (decodedResponse['conversation_length'] is String) {
                errorMessage = decodedResponse['conversation_length'];
              }
            } else if (decodedResponse['error'] != null) {
              errorMessage = decodedResponse['error'].toString();
            } else if (decodedResponse['detail'] != null) {
              errorMessage = decodedResponse['detail'].toString();
            } else if (decodedResponse['message'] != null) {
              errorMessage = decodedResponse['message'].toString();
            }
          } else if (decodedResponse is String) {
            errorMessage = decodedResponse;
          }

          throw Exception(errorMessage);
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('Failed to create scenario with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Get User Scenarios API
  Future<List<ScenarioModel>> getScenarios({
    required String accessToken,
  }) async {
    try {
      print('📡 Fetching user scenarios...');
      print('📝 Access Token: ${accessToken.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse(ApiConstant.createScenario),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> decodedResponse = jsonDecode(response.body);
        return decodedResponse.map((json) => ScenarioModel.fromJson(json)).toList();
      } else {
        // Handle error response
        try {
          final decodedResponse = jsonDecode(response.body);
          String errorMessage = 'Failed to fetch scenarios';
          
          if (decodedResponse is Map<String, dynamic>) {
            errorMessage = decodedResponse['detail'] ?? 
                          decodedResponse['error'] ?? 
                          decodedResponse['message'] ?? 
                          'Failed to fetch scenarios';
          }
          
          throw Exception(errorMessage);
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('Failed to fetch scenarios with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Get Daily Scenarios API
  Future<DailyScenariosResponseModel> getDailyScenarios({
    required String accessToken,
  }) async {
    try {
      print('📡 Fetching daily scenarios...');
      print('📝 Access Token: ${accessToken.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse(ApiConstant.dailyScenarios),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        return DailyScenariosResponseModel.fromJson(decodedResponse);
      } else {
        // Handle error response
        try {
          final decodedResponse = jsonDecode(response.body);
          String errorMessage = 'Failed to fetch daily scenarios';
          
          if (decodedResponse is Map<String, dynamic>) {
            errorMessage = decodedResponse['detail'] ?? 
                          decodedResponse['error'] ?? 
                          decodedResponse['message'] ?? 
                          'Failed to fetch daily scenarios';
          }
          
          throw Exception(errorMessage);
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('Failed to fetch daily scenarios with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Get Chat History API - Fetch all chat sessions history
  Future<ChatHistoryResponseModel> getChatHistory({
    required String accessToken,
  }) async {
    try {
      print('📡 Fetching chat history...');
      print('📝 Access Token: ${accessToken.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse(ApiConstant.chatHistory),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        return ChatHistoryResponseModel.fromJson(decodedResponse);
      } else {
        // Handle error response
        try {
          final decodedResponse = jsonDecode(response.body);
          String errorMessage = 'Failed to fetch chat history';
          
          if (decodedResponse is Map<String, dynamic>) {
            errorMessage = decodedResponse['detail'] ?? 
                          decodedResponse['error'] ?? 
                          decodedResponse['message'] ?? 
                          'Failed to fetch chat history';
          }
          
          throw Exception(errorMessage);
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('Failed to fetch chat history with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Delete Account API
  Future<DeleteAccountResponseModel> deleteAccount({
    required String accessToken,
  }) async {
    try {
      print('📡 Deleting account...');
      print('📝 Access Token: ${accessToken.substring(0, 20)}...');

      final response = await http.delete(
        Uri.parse(ApiConstant.deleteAccount),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Handle empty response for 204 No Content
        if (response.statusCode == 204 || response.body.isEmpty) {
          return DeleteAccountResponseModel(
            message: 'Account deleted successfully',
          );
        }
        
        final decodedResponse = jsonDecode(response.body);
        return DeleteAccountResponseModel.fromJson(decodedResponse);
      } else {
        // Handle error response
        try {
          final decodedResponse = jsonDecode(response.body);
          String errorMessage = 'Failed to delete account';

          if (decodedResponse is Map<String, dynamic>) {
            // Check for specific error codes first
            final code = decodedResponse['code'];
            
            if (code == 'user_not_found') {
              errorMessage = 'User not found. Please try logging in again.';
            } else if (code == 'token_not_valid') {
              errorMessage = 'Token is invalid or expired. Please login again.';
            } else if (decodedResponse['detail'] != null) {
              // Use detail message if no specific code matched
              errorMessage = decodedResponse['detail'].toString();
            } else if (decodedResponse['error'] != null) {
              errorMessage = decodedResponse['error'].toString();
            } else if (decodedResponse['message'] != null) {
              errorMessage = decodedResponse['message'].toString();
            } else if (decodedResponse['messages'] != null && decodedResponse['messages'] is List) {
              final messages = decodedResponse['messages'] as List;
              if (messages.isNotEmpty && messages[0] is Map) {
                errorMessage = messages[0]['message'] ?? 'Token is invalid';
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
          throw Exception('Failed to delete account with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Start a new chat session with a scenario
  Future<ChatSessionStartResponse> startChatSession(String scenarioId) async {
    try {
      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access');  // Token key matches API response format

      // Check if token exists
      if (token == null || token.isEmpty) {
        print('❌ No access token found in SharedPreferences');
        print('💡 Available keys: ${prefs.getKeys()}');
        print('💡 User needs to log in first');
        throw Exception('Authentication required. Please log in first.');
      }

      final url = ApiConstant.chatMessage;
      
      final requestBody = {
        'scenario_id': scenarioId,
        'mode': 'text',  // Mode: "text" for text chat, "voice" for voice chat
      };
      
      print('═══════════════════════════════════════════');
      print('🚀 STARTING CHAT SESSION');
      print('═══════════════════════════════════════════');
      print('URL: $url');
      print('Scenario ID: $scenarioId');
      print('Request Body: ${jsonEncode(requestBody)}');
      print('Auth Token: Present (${token.length > 20 ? token.substring(0, 20) : token}...)');
      print('Token Length: ${token.length} characters');
      print('═══════════════════════════════════════════');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print('═══════════════════════════════════════════');
      print('📥 START CHAT RESPONSE');
      print('═══════════════════════════════════════════');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('═══════════════════════════════════════════');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return ChatSessionStartResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        // Unauthorized - token is invalid or expired
        print('❌ 401 UNAUTHORIZED');
        print('💡 Token used: ${token.substring(0, min(50, token.length))}...');
        print('💡 Token may be expired or invalid');
        print('💡 User should log in again');
        throw Exception('Session expired. Please log in again.');
      } else {
        print('❌ Start Chat Error - Status: ${response.statusCode}');
        
        try {
          final dynamic decodedResponse = jsonDecode(response.body);
          String errorMessage = 'Failed to start chat session';
          
          if (decodedResponse is Map<String, dynamic>) {
            errorMessage = decodedResponse['message'] ?? 
                          decodedResponse['error'] ?? 
                          decodedResponse['detail'] ??
                          decodedResponse.toString();
          } else {
            errorMessage = decodedResponse.toString();
          }
          
          print('❌ Error Message: $errorMessage');
          throw Exception(errorMessage);
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('Failed to start chat session with status: ${response.statusCode}. Response: ${response.body}');
        }
      }
    } catch (e) {
      print('❌ Exception in startChatSession: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Send a message in an existing chat session
  Future<ChatMessageResponse> sendChatMessage(
    String sessionId,
    String textContent,
  ) async {
    try {
      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access');  // Token key matches API response format

      // Check if token exists
      if (token == null || token.isEmpty) {
        print('❌ No access token found in SharedPreferences');
        print('💡 User needs to log in first');
        throw Exception('Authentication required. Please log in first.');
      }

      // Use session-specific endpoint
      final url = ApiConstant.getSessionMessageUrl(sessionId);
      
      // Only send text_content in body (session_id is in URL)
      final requestBody = {
        'text_input': textContent,
      };
      
      print('═══════════════════════════════════════════');
      print('📤 SENDING MESSAGE TO API');
      print('═══════════════════════════════════════════');
      print('URL: $url');
      print('Session ID: $sessionId (in URL)');
      print('Request Body: ${jsonEncode(requestBody)}');
      print('Auth Token: Present (${token.length > 20 ? token.substring(0, 20) : token}...)');
      print('═══════════════════════════════════════════');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print('═══════════════════════════════════════════');
      print('📥 RESPONSE FROM API');
      print('═══════════════════════════════════════════');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('═══════════════════════════════════════════');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return ChatMessageResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        // Unauthorized - token is invalid or expired
        print('❌ 401 UNAUTHORIZED');
        print('💡 Session expired or invalid token');
        print('💡 User should log in again');
        throw Exception('Session expired. Please log in again.');
      } else {
        // Log detailed error
        print('❌ API Error - Status: ${response.statusCode}');
        
        try {
          final dynamic decodedResponse = jsonDecode(response.body);
          String errorMessage = 'Failed to send message';
          
          if (decodedResponse is Map<String, dynamic>) {
            errorMessage = decodedResponse['message'] ?? 
                          decodedResponse['error'] ?? 
                          decodedResponse['detail'] ??
                          decodedResponse.toString();
          } else {
            errorMessage = decodedResponse.toString();
          }
          
          print('❌ Error Message: $errorMessage');
          throw Exception(errorMessage);
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('Failed to send message with status: ${response.statusCode}. Response: ${response.body}');
        }
      }
    } catch (e) {
      print('❌ Exception in sendChatMessage: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Get session history with messages
  /// 
  /// API: GET {{small_talk}}core/chat/sessions/{session_id}/history/
  /// 
  /// Returns: SessionHistoryModel containing session details and all messages
  Future<SessionHistoryModel> getSessionHistory({
    required String accessToken,
    required String sessionId,
  }) async {
    try {
      print('═══════════════════════════════════════════════════════════');
      print('📡 GET SESSION HISTORY REQUEST');
      print('═══════════════════════════════════════════════════════════');
      print('URL: ${ApiConstant.getSessionHistoryUrl(sessionId)}');
      print('Session ID: $sessionId');

      final response = await http.get(
        Uri.parse(ApiConstant.getSessionHistoryUrl(sessionId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('═══════════════════════════════════════════════════════════');
      print('📥 SESSION HISTORY RESPONSE');
      print('═══════════════════════════════════════════════════════════');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('═══════════════════════════════════════════════════════════');

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        print('✅ Session history fetched successfully');
        
        final sessionHistory = SessionHistoryModel.fromJson(decodedResponse);
        print('✅ Parsed ${sessionHistory.session.messages.length} messages');
        
        return sessionHistory;
      } else if (response.statusCode == 401) {
        print('❌ 401 UNAUTHORIZED - Session expired');
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 404) {
        print('❌ 404 NOT FOUND - Session not found');
        throw Exception('Session not found');
      } else {
        print('❌ API Error - Status: ${response.statusCode}');
        
        try {
          final dynamic decodedResponse = jsonDecode(response.body);
          String errorMessage = 'Failed to fetch session history';
          
          if (decodedResponse is Map<String, dynamic>) {
            errorMessage = decodedResponse['message'] ?? 
                          decodedResponse['error'] ?? 
                          decodedResponse['detail'] ??
                          decodedResponse.toString();
          } else {
            errorMessage = decodedResponse.toString();
          }
          
          print('❌ Error Message: $errorMessage');
          throw Exception(errorMessage);
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('Failed to fetch session history with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('❌ Exception in getSessionHistory: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }
}
