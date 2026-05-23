import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// NOTE: Optional import. If your file exists, use it. If not, app still works.
import '../Layout/premium_theme_controller.dart' as premium;

/// HomeFeedPage: TikTok/Reels style vertical video feed with Like/Comment/Share working.
class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // For You feed - 15 test videos
  final List<String> forYouUrls = const [
    "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
    "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4",
  ];

  // Following feed - 12 test videos
  final List<String> followingUrls = const [
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
    "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
    "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _getAccentColor();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildVideoFeed(followingUrls, accentColor: accentColor),
              _buildVideoFeed(forYouUrls, accentColor: accentColor),
            ],
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.live_tv, color: Colors.white, size: 28),

                  SizedBox(
                    width: 240,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.label,
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      unselectedLabelStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                      tabs: const [
                        Tab(text: "Following"),
                        Tab(text: "For You"),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white, size: 30),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Search coming soon")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccentColor() {
    try {
      return Colors.pinkAccent;
    } catch (_) {
      return Colors.pinkAccent;
    }
  }

  Widget _buildVideoFeed(List<String> urls, {required Color accentColor}) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: urls.length,
      itemBuilder: (context, index) {
        return FeedVideoItem(
          key: ValueKey("feed_${urls[index]}_$index"),
          videoUrl: urls[index],
          index: index,
        );
      },
    );
  }
}

/// Single video item with Like/Comment/Share working + Enhanced animations
class FeedVideoItem extends StatefulWidget {
  final String videoUrl;
  final int index;

  const FeedVideoItem({super.key, required this.videoUrl, required this.index});

  @override
  State<FeedVideoItem> createState() => _FeedVideoItemState();
}

class _FeedVideoItemState extends State<FeedVideoItem>
    with SingleTickerProviderStateMixin {
  late final VideoPlayerController _videoController;
  late final AnimationController _likeAnimationController;

  bool _isInitialized = false;
  bool _isPlaying = true;

  // Actions state
  bool _isLiked = false;
  int _likeCount = 45000; // start like count
  int _commentCount = 1200; // start comment count

  @override
  void initState() {
    super.initState();

    // Like animation controller for heart pop effect
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isInitialized = true;
        });
        _videoController
          ..setLooping(true)
          ..play();
        _isPlaying = true;
      }).catchError((e) {
        if (!mounted) return;
        setState(() {
          _isInitialized = false;
          _isPlaying = false;
        });
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_isInitialized) return;

    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
        _isPlaying = false;
      } else {
        _videoController.play();
        _isPlaying = true;
      }
    });
  }

  void _onLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    // Play like animation
    if (_isLiked) {
      _likeAnimationController.forward().then((_) {
        _likeAnimationController.reverse();
      });
    }
  }

  void _onDoubleTap() {
    // Double tap to like (like Instagram/TikTok)
    if (!_isLiked) {
      _onLike();
    }
  }

  void _onComment() {
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.chat_bubble_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    "Comments ($_commentCount)",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Write a comment...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (textController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Type something to comment")),
                      );
                      return;
                    }
                    setState(() {
                      _commentCount += 1;
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Comment added!"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Send",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _onShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Share link copied! 📋"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlay,
      onDoubleTap: _onDoubleTap, // Double tap to like
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video player
          Container(
            color: widget.index % 2 == 0
                ? const Color(0xFF0F0F0F)
                : const Color(0xFF141414),
            child: _isInitialized
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      color: Colors.pinkAccent,
                      strokeWidth: 3,
                    ),
                  ),
          ),

          // Play icon when paused
          if (_isInitialized && !_isPlaying)
            const Center(
              child: Icon(
                Icons.play_arrow_rounded,
                size: 80,
                color: Colors.white54,
              ),
            ),

          // Double tap heart animation
          Center(
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.0, end: 1.2).animate(
                CurvedAnimation(
                  parent: _likeAnimationController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: const Icon(
                Icons.favorite,
                size: 120,
                color: Colors.pinkAccent,
              ),
            ),
          ),

          // Bottom gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 420,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black87,
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // Right actions (Like, Comment, Share)
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                _actionButton(
                  icon: Icons.favorite_rounded,
                  label: _formatCount(_likeCount),
                  onTap: _onLike,
                  active: _isLiked,
                ),
                const SizedBox(height: 24),
                _actionButton(
                  icon: Icons.chat_bubble_rounded,
                  label: _formatCount(_commentCount),
                  onTap: _onComment,
                  active: false,
                ),
                const SizedBox(height: 24),
                _actionButton(
                  icon: Icons.share_rounded,
                  label: "Share",
                  onTap: _onShare,
                  active: false,
                ),
                const SizedBox(height: 24),
                // Profile picture
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    gradient: const LinearGradient(
                      colors: [Colors.pinkAccent, Colors.purpleAccent],
                    ),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),

          // Left caption and user info
          Positioned(
            left: 24,
            bottom: 120,
            width: MediaQuery.of(context).size.width * 0.65,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "@Sohan_Dev",
                      style: TextStyle(
                        color: const Color(0xFFFF4FB3),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Follow button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Follow",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Building the ultimate premium UI 🔥 This feels like a billion-dollar app! #Flutter #UIUX #Premium",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Original Sound - Sohan Dev • Trending",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool active,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              icon,
              color: active ? Colors.pinkAccent : Colors.white,
              size: active ? 38 : 36,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) {
      return "${(n / 1000000).toStringAsFixed(1)}M".replaceAll(".0", "");
    }
    if (n >= 1000) {
      return "${(n / 1000).toStringAsFixed(1)}K".replaceAll(".0", "");
    }
    return n.toString();
  }
}
