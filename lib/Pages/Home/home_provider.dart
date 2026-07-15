import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Api/Home/home_api.dart';
import 'models/video_data.dart';

class HomeProvider with ChangeNotifier {
  List<VideoData> _videos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<VideoData> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchHomeFeed() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await HomeApi.getForYouVideos();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          final List<dynamic> videoList = data['data'];
          _videos = videoList.map((v) => _mapToVideoData(v)).toList();
        } else {
          _errorMessage = data['message'] ?? 'Failed to load feed';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  VideoData _mapToVideoData(Map<String, dynamic> v) {
    // Map backend response to Flutter VideoData model
    final user = v['User'] ?? {};
    return VideoData(
      url: v['URL'] ?? '',
      username: user['Username'] != null ? '@${user['Username']}' : '@unknown',
      displayName: user['Nickname'] ?? 'Unknown User',
      caption: v['Caption'] ?? '',
      sound: v['Sound'] ?? 'Original Sound',
      likes: v['Likes'] ?? 0,
      comments: v['Comments'] ?? 0,
      shares: v['Shares'] ?? 0,
      isImage: v['IsImage'] ?? false,
      images: v['Images'] != null ? List<String>.from(v['Images']) : null,
      isAd: v['IsAd'] ?? false,
      adCta: v['AdCta'],
      adLink: v['AdLink'],
    );
  }
}
