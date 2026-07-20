class CommentItem {
  final int id;
  final String username;
  final String text;
  final DateTime timestamp;
  int likes;
  bool liked;

  CommentItem({
    required this.id,
    required this.username,
    required this.text,
    required this.timestamp,
    this.likes = 0,
    this.liked = false,
  });

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    // The API returns a nested User object and uses 'created_at' instead of 'timestamp'
    final user = json['user'] as Map<String, dynamic>?;
    final username = user?['username'] ?? json['username'] ?? 'unknown';

    return CommentItem(
      id: json['id'] ?? 0,
      username: username,
      text: json['text'] ?? '',
      timestamp: DateTime.parse(json['created_at'] ?? json['timestamp'] ?? DateTime.now().toIso8601String()),
      likes: json['likes'] ?? 0,
      liked: json['liked'] ?? false,
    );
  }
}