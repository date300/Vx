import 'package:http/http.dart' as http;
import '../../../Core/constants.dart' as constants;

class StudioApi {
  static Future<http.Response> getAnalytics(String token) async {
    final uri = Uri.parse('${constants.baseUrl}/studio/analytics');
    return await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
  }
}
