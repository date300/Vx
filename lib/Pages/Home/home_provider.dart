import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Api/Home/home_api.dart';
import 'models/video_data.dart';
import 'models/comment_item.dart';
import '../../Services/auth_service.dart';
import '../../Services/websocket_service.dart';

class HomeProvider with ChangeNotifier {
  List<VideoData> _videos = [];
  List<VideoData> _followingVideos = [];
  List<VideoData> _friendsVideos = [];
  List<VideoData> _stories = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  int _refreshCounter = 0;
  StreamSubscription? _wsSub;

  final Map<int, List<CommentItem>> _videoComments = {};

  HomeProvider() {
    _listenToWS();
  }

  void _listenToWS() {
    _wsSub = webSocketService.eventStream.listen((event) {
      final type = event['type'];
      final payload = event['payload'];
      if (payload == null) return;

      if (type == 'like_update') {
        final videoId = payload['video_id'];
        final likesCount = payload['likes_count'];
        _updateLikeLocally(videoId, likesCount);
      } else if (type == 'comment_update') {
        final videoId = payload['video_id'];
        final commentCount = payload['comment_count'];
        final newComment = payload['new_comment'];
        
        _updateCommentLocally(videoId, commentCount, newComment);
      } else if (type == 'follow_update') {
        final userId = payload['user_id'];
        final isFollowing = payload['is_following'];
        _updateFollowStatus(userId, isFollowing);
      }
    });
  }

  void _updateLikeLocally(int videoId, int likesCount) {
    for (var v in _videos) if (v.id == videoId) v.likes = likesCount;
    for (var v in _followingVideos) if (v.id == videoId) v.likes = likesCount;
    for (var v in _friendsVideos) if (v.id == videoId) v.likes = likesCount;
    notifyListeners();
  }

  void _updateCommentLocally(int videoId, int commentCount, Map<String, dynamic>? newCommentJson) {
    for (var v in _videos) if (v.id == videoId) v.comments = commentCount;
    for (var v in _followingVideos) if (v.id == videoId) v.comments = commentCount;
    for (var v in _friendsVideos) if (v.id == videoId) v.comments = commentCount;

    if (newCommentJson != null) {
      final newComment = CommentItem.fromJson(newCommentJson);
      if (_videoComments[videoId] != null) {
        _videoComments[videoId]!.insert(0, newComment);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }

  List<VideoData> get videos => _videos;
  List<VideoData> get followingVideos => _followingVideos;
  List<VideoData> get friendsVideos => _friendsVideos;
  List<VideoData> get stories => _stories;
  
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

        final storiesResponse = await HomeApi.getStories(token);
        if (storiesResponse.statusCode == 200) {
          final storiesData = jsonDecode(storiesResponse.body);
          if (storiesData['status'] == true) {
            final List<dynamic> storiesList = storiesData['data'];
            _stories = storiesList.map((v) => VideoData.fromJson(v)).toList();
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

  Future<bool> toggleLike(int videoId) async {
    final token = await AuthService.getToken();
    if (token == null) return false;

    try {
      final response = await HomeApi.toggleLike(videoId, token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          final isLiked = data['is_liked'];
          final likesCount = data['likes_count'];
          _updateLikeStatus(videoId, isLiked, likesCount);
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
    return false;
  }

  void _updateLikeStatus(int videoId, bool isLiked, int likesCount) {
    for (var v in _videos) {
      if (v.id == videoId) {
        v.isLiked = isLiked;
        v.likes = likesCount;
      }
    }
    for (var v in _followingVideos) {
      if (v.id == videoId) {
        v.isLiked = isLiked;
        v.likes = likesCount;
      }
    }
    for (var v in _friendsVideos) {
      if (v.id == videoId) {
        v.isLiked = isLiked;
        v.likes = likesCount;
      }
    }
    notifyListeners();
  }

  VideoData _mapToVideoData(Map<String, dynamic> v) {
    return VideoData.fromJson(v);
  }
}
