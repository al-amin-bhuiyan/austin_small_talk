/// API Constants for Authentication endpoints
class ApiConstant {
  // Base URL
  static const String baseUrl = 'http://10.10.7.74:8001/';
  static const String smallTalk = '${baseUrl}';
  
  // Auth endpoints
  static const String register = '${smallTalk}accounts/user/register/';
  static const String verifyOtp = '${smallTalk}accounts/user/verify-otp/';
  static const String resendOtp = '${smallTalk}accounts/user/resend-otp/';
  static const String login = '${smallTalk}accounts/user/login/';
  static const String refreshToken = '${smallTalk}accounts/user/token/refresh/';
  static const String verifyToken = '${smallTalk}accounts/user/token/verify/';
}
