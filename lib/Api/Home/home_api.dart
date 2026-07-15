import '../Core/api_client.dart';

class HomeApi {
  static Future<dynamic> getFeed() async {
    return await ApiClient.get('/video/foryou'); // Adjust endpoint as per backend
  }

  static Future<dynamic> likeVideo(String videoId) async {
    return await ApiClient.post('/interaction/like', {'video_id': videoId});
  }
}
