import '../../../Core/config.dart';

class VideoData {
  final int id;
  final int uploaderId;
  final String url;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String thumbnailUrl;
  final String caption;
  final String sound;
  int likes;
  int comments;
  int views;
  final int shares;
  final bool isImage;
  final List<String>? images;
  final bool isAd;
  final String? adCta;
  final String? adLink;
  bool isLiked;
  bool isFollowing;
  bool isFollowBack;

  VideoData({
    required this.id,
    required this.uploaderId,
    required this.url,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.thumbnailUrl,
    required this.caption,
    required this.sound,
    required this.likes,
    required this.comments,
    required this.views,
    required this.shares,
    this.isImage = false,
    this.images,
    this.isAd = false,
    this.adCta,
    this.adLink,
    this.isLiked = false,
    this.isFollowing = false,
    this.isFollowBack = false,
  });

  static String _resolveMediaUrl(String path) {
    if (path.startsWith('/uploads')) {
      return '${ApiConfig.rootUrl}$path';
    }
    return path;
  }

  factory VideoData.fromJson(Map<String, dynamic> json) {
    // backend-এর enrichVideos() ফুল User অবজেক্ট নেস্টেড আকারে পাঠায় ("user" key-তে)।
    // Cache থেকে এলে ডাটা ফ্ল্যাট থাকে।
    final user = json['user'] as Map<String, dynamic>?;

    return VideoData(
      id: json['id'] ?? 0,
      uploaderId: json['user_id'] ?? 0,
      url: _resolveMediaUrl(json['url'] ?? ''),
      username: user != null ? (user['username'] ?? '') : (json['username'] ?? ''),
      displayName: user != null ? (user['nickname'] ?? '') : (json['nickname'] ?? ''),
      avatarUrl: _resolveMediaUrl(user != null ? (user['avatar_url'] ?? '') : (json['avatar_url'] ?? '')),
      thumbnailUrl: _resolveMediaUrl(json['thumbnail_url'] ?? ''),
      caption: json['caption'] ?? '',
      sound: json['sound'] ?? 'Original Sound',
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      views: json['views'] ?? 0,
      shares: json['shares'] ?? 0,
      isImage: json['is_image'] ?? false,
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : null,
      isAd: json['is_ad'] ?? false,
      adCta: json['ad_cta'],
      adLink: json['ad_link'],
      isLiked: json['is_liked'] ?? false,
      isFollowing: json['is_following'] ?? false,
      isFollowBack: json['is_follow_back'] ?? false,
    );
  }

  // ── Optimistic UI আপডেটের জন্য হেল্পার ──
  // ToggleLike API কল করার আগেই লোকাল স্টেট বদলে UI তাৎক্ষণিক রেসপন্সিভ রাখা যায়,
  // API রেসপন্স এলে backend-এর আসল likes count/is_liked দিয়ে confirm করে নেওয়া উচিত।
  void applyLikeToggle() {
    if (isLiked) {
      likes = likes > 0 ? likes - 1 : 0;
      isLiked = false;
    } else {
      likes += 1;
      isLiked = true;
    }
  }

  void applyFollowToggle() {
    isFollowing = !isFollowing;
  }
}