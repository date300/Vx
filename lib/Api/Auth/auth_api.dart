import '../Core/api_client.dart';

class AuthApi {
  static Future<dynamic> requestOTP(String email) async {
    return await ApiClient.post('/auth/email-request', {'email': email});
  }

  static Future<dynamic> verifyOTP(String email, String otp) async {
    return await ApiClient.post('/auth/email-verify', {'email': email, 'otp': otp});
  }

  static Future<dynamic> socialAuth(String provider, String token, String email) async {
    return await ApiClient.post('/auth/social', {
      'provider': provider,
      'social_token': token,
      'email': email,
    });
  }
}
