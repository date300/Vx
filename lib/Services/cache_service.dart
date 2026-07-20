import 'package:hive_flutter/hive_flutter.dart';
import '../Pages/Home/models/video_data.dart';

class CacheService {
  static const String _videoBoxName = 'videos_cache';
  static const String _profileBoxName = 'profile_cache';
  static const String _draftBoxName = 'drafts_cache';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_videoBoxName);
    await Hive.openBox(_profileBoxName);
    await Hive.openBox(_draftBoxName);
  }

  // ---------- Video Caching ----------
  static Future<void> cacheVideos(List<VideoData> videos) async {
    final box = Hive.box(_videoBoxName);
    final data = videos.map((v) => {
      'id': v.id,
      'url': v.url,
      'username': v.username,
      'nickname': v.displayName,
      'avatar_url': v.avatarUrl,
      'caption': v.caption,
      'sound': v.sound,
      'likes': v.likes,
      'comments': v.comments,
      'shares': v.shares,
      'is_image': v.isImage,
      'images': v.images,
      'is_liked': v.isLiked,
      'is_following': v.isFollowing,
    }).toList();
    await box.put('home_feed', data);
  }

  static List<VideoData> getCachedVideos() {
    final box = Hive.box(_videoBoxName);
    final List<dynamic>? cachedData = box.get('home_feed');
    if (cachedData == null) return [];

    return cachedData.map((v) => VideoData.fromJson(Map<String, dynamic>.from(v))).toList();
  }

  // ---------- Profile Caching ----------
  static Future<void> cacheProfile(Map<String, dynamic> profile) async {
    final box = Hive.box(_profileBoxName);
    await box.put('user_profile', profile);
  }

  static Map<String, dynamic>? getCachedProfile() {
    final box = Hive.box(_profileBoxName);
    final data = box.get('user_profile');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  static Future<void> clearAll() async {
    await Hive.box(_videoBoxName).clear();
    await Hive.box(_profileBoxName).clear();
  }
}
