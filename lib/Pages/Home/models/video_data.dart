class VideoData {
  final String url;
  final String username;
  final String displayName;
  final String caption;
  final String sound;
  final int likes;
  final int comments;
  final int shares;
  final bool isImage;
  final List<String>? images;

  final bool isAd;
  final String? adCta;
  final String? adLink;

  const VideoData({
    required this.url,
    required this.username,
    required this.displayName,
    required this.caption,
    required this.sound,
    required this.likes,
    required this.comments,
    required this.shares,
    this.isImage = false,
    this.images,
    this.isAd = false,
    this.adCta,
    this.adLink,
  });
}
