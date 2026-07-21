import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../Core/constants.dart' as constants;

class HomeApi {
  static Future<http.Response> getForYouVideos({int page = 1, int limit = 10, String? token}) async {
    final uri = Uri.parse('${constants.baseUrl}/home/foryou?page=$page&limit=$limit');
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return await http.get(uri, headers: headers);
  }

  static Future<http.Response> getFollowingVideos({int page = 1, int limit = 10, required String token}) async {
    final uri = Uri.parse('${constants.baseUrl}/home/following?page=$page&limit=$limit');
    return await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
  }

  static Future<http.Response> getFriendsVideos({int page = 1, int limit = 10, required String token}) async {
    final uri = Uri.parse('${constants.baseUrl}/home/friends?page=$page&limit=$limit');
    return await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
  }

  static Future<http.Response> getStories(String token) async {
    final uri = Uri.parse('${constants.baseUrl}/home/stories');
    return await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
  }

  static Future<http.Response> toggleLike(int videoId, String token) async {
    final uri = Uri.parse('${constants.baseUrl}/interaction/like');
    return await http.post(uri, 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'video_id': videoId}),
    );
  }

  static Future<http.Response> toggleFollow(int userId, String token) async {
    final uri = Uri.parse('${constants.baseUrl}/interaction/follow');
    return await http.post(uri, 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'user_id': userId}),
    );
  }

  static Future<http.Response> getComments(int videoId, {String? token}) async {
    final uri = Uri.parse('${constants.baseUrl}/video/$videoId/comments');
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return await http.get(uri, headers: headers);
  }

  static Future<http.Response> postComment(int videoId, String text, String token) async {
    final uri = Uri.parse('${constants.baseUrl}/video/$videoId/comment');
    return await http.post(uri, 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'text': text}),
    );
  }

  static Future<http.Response> incrementView(int videoId) async {
    final uri = Uri.parse('${constants.baseUrl}/video/$videoId/view');
    return await http.post(uri, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> deleteVideo(int videoId, String token) async {
    final uri = Uri.parse('${constants.baseUrl}/interaction/video/$videoId');
    return await http.delete(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
  }
}
