import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Api/Home/home_api.dart';
import 'models/video_data.dart';
import 'models/comment_item.dart';
import '../../Services/auth_service.dart';

class HomeProvider with ChangeNotifier {
  List<VideoData> _videos = [];
  List<VideoData> _followingVideos = [];
  List<VideoData> _friendsVideos = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  int _refreshCounter = 0;

  final Map<int, List<CommentItem>> _videoComments = {};

  List<VideoData> get videos => _videos;
  List<VideoData> get followingVideos => _followingVideos;
  List<VideoData> get friendsVideos => _friendsVideos;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get refreshCounter => _refreshCounter;

  Future<void> fetchHomeFeed({bool refresh = false, BuildContext? context}) async {
    if (refresh) {
      _refreshCounter++;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      
      // Fetch For You videos
      final response = await HomeApi.getForYouVideos(token: token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          final List<dynamic> videoList = data['data'];
          _videos = videoList.map((v) => VideoData.fromJson(v)).toList();
        } else {
          _errorMessage = data['message'] ?? 'Failed to load feed';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }

      // Fetch Following videos if logged in
      if (token != null) {
        final followingResponse = await HomeApi.getFollowingVideos(token: token);
        if (followingResponse.statusCode == 200) {
          final followingData = jsonDecode(followingResponse.body);
          if (followingData['status'] == true) {
            final List<dynamic> followingList = followingData['data'];
            _followingVideos = followingList.map((v) => VideoData.fromJson(v)).toList();
          }
        }

        final friendsResponse = await HomeApi.getFriendsVideos(token: token);
        if (friendsResponse.statusCode == 200) {
          final friendsData = jsonDecode(friendsResponse.body);
          if (friendsData['status'] == true) {
            final List<dynamic> friendsList = friendsData['data'];
            _friendsVideos = friendsList.map((v) => VideoData.fromJson(v)).toList();
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> incrementView(int videoId) async {
    try {
      await HomeApi.incrementView(videoId);
    } catch (e) {
      debugPrint('Error incrementing view: $e');
    }
  }

  Future<void> toggleFollowByUsername(String username) async {
    final video = _findVideoByUsername(username);
    if (video != null) {
      final token = await AuthService.getToken();
      if (token == null) return;
      
      try {
        final response = await HomeApi.toggleFollow(video.uploaderId, token);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == true) {
            final isFollowing = data['is_following'];
            _updateFollowStatus(video.uploaderId, isFollowing);
          }
        }
      } catch (e) {
        debugPrint('Error toggling follow: $e');
      }
    }
  }

  VideoData? _findVideoByUsername(String username) {
    for (var v in _videos) if (v.username == username) return v;
    for (var v in _followingVideos) if (v.username == username) return v;
    for (var v in _friendsVideos) if (v.username == username) return v;
    return null;
  }

  void _updateFollowStatus(int userId, bool isFollowing) {
    for (var v in _videos) if (v.uploaderId == userId) v.isFollowing = isFollowing;
    for (var v in _followingVideos) if (v.uploaderId == userId) v.isFollowing = isFollowing;
    for (var v in _friendsVideos) if (v.uploaderId == userId) v.isFollowing = isFollowing;
    notifyListeners();
  }

  Future<void> fetchComments(int videoId) async {
    try {
      final token = await AuthService.getToken();
      final response = await HomeApi.getComments(videoId, token: token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          final List<dynamic> commentList = data['comments'];
          _videoComments[videoId] = commentList.map((c) => CommentItem.fromJson(c)).toList();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetching comments: $e');
    }
  }

  List<CommentItem>? getCommentsForVideo(int videoId) {
    return _videoComments[videoId];
  }

  Future<void> addComment(int videoId, String text, String username) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      final response = await HomeApi.postComment(videoId, text, token);
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          final newComment = CommentItem.fromJson(data['comment']);
          if (_videoComments[videoId] == null) {
            _videoComments[videoId] = [];
          }
          _videoComments[videoId]!.insert(0, newComment);
          
          _updateCommentCount(videoId, 1);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
  }

  void _updateCommentCount(int videoId, int delta) {
    for (var v in _videos) if (v.id == videoId) v.comments += delta;
    for (var v in _followingVideos) if (v.id == videoId) v.comments += delta;
    for (var v in _friendsVideos) if (v.id == videoId) v.comments += delta;
  }

  VideoData _mapToVideoData(Map<String, dynamic> v) {
    return VideoData.fromJson(v);
  }
}
