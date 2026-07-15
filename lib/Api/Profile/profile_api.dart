import '../Core/api_client.dart';

class ProfileApi {
  static Future<dynamic> getCategories() async {
    return await ApiClient.get('/user/categories');
  }

  static Future<dynamic> saveOnboarding(Map<String, dynamic> data) async {
    return await ApiClient.post('/user/onboard', data);
  }
}
