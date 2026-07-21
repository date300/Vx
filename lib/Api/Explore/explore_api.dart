import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../Core/constants.dart' as constants;

class ExploreApi {
  static Future<http.Response> getSoundDetails(int soundId, {String? token}) async {
    final uri = Uri.parse('${constants.baseUrl}/explore/sound/$soundId');
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return await http.get(uri, headers: headers);
  }

  static Future<http.Response> searchSounds(String query, {int limit = 20, int offset = 0}) async {
    final uri = Uri.parse('${constants.baseUrl}/explore/sounds/search?q=$query&limit=$limit&offset=$offset');
    return await http.get(uri, headers: {
      'Content-Type': 'application/json',
    });
  }

  static Future<http.Response> searchUsers(String query, {int limit = 20, int offset = 0}) async {
    final uri = Uri.parse('${constants.baseUrl}/explore/users?q=$query&limit=$limit&offset=$offset');
    return await http.get(uri, headers: {
      'Content-Type': 'application/json',
    });
  }
}
