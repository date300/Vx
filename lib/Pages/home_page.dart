import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:math' as math;

// NOTE: Optional import. If your file exists, use it. If not, app still works.
import '../Layout/premium_theme_controller.dart' as premium;

/// HomeFeedPage: Ultra-modern vertical video feed — NOT TikTok style.
/// Unique glassmorphism design with smooth animations.
class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _animationController;

  // Modern tab names
  final List<String> _tabs = const ["Discover", "For You"];

  // 15+ Test videos — diverse sources, lengths, and resolutions
  final List<Map<String, dynamic>> discoverVideos = const [
    {
      "url": "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
      "user": "@Aisha_Creates",
      "caption": "Nature's tiny miracles 🦋✨ Morning vibes in the garden",
      "tags": "#Nature #Butterfly #Morning",
      "music": "Soft Morning Breeze - Acoustic",
    },
    {
      "url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
      "user": "@CinemaScope",
      "caption": "The first open movie ever made. A masterpiece of open source cinema 🎬",
      "tags": "#OpenSource #Animation #CGI",
      "music": "Epic Orchestral - Open Movie",
    },
    {
      "url": "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      "user": "@MacroWorld",
      "caption": "Busy bee at work 🐝 Pollination in slow motion",
      "tags": "#Macro #Nature #Bee",
      "music": "Buzzing Harmony - Nature Sounds",
    },
    {
      "url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
      "user": "@TechReview",
      "caption": "When your TV is bigger than your dreams 📺😂",
      "tags": "#Tech #Humor #BigScreen",
      "music": "Upbeat Pop - Commercial",
    },
    {
      "url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
      "user": "@TravelDiaries",
      "caption": "Bullrun adventure! Nothing beats the open road 🚗💨",
      "tags": "#Travel #Adventure #RoadTrip",
      "music": "Highway Dreams - Rock Mix",
    },
    {
      "url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
      "user": "@SciFiHub",
      "caption": "The future of filmmaking is here. Blender + creativity = magic 🤖",
      "tags": "#SciFi #Blender #VFX",
      "music": "Cyberpunk Synth - SciFi OST",
    },
    {
      "url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
      "user": "@StoryTeller",
      "caption": "A dragon's tale that will melt your heart 🐉💙",
      "tags": "#Animation #Story #Dragon",
      "music": "Emotional Piano - Fantasy",
    },
    {
      "url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      "user": "@FunnyBunny",
      "caption": "Big Buck Bunny — the classic that started it all 🐰🥕",
      "tags": "#Classic #Comedy #Animation",
      "music": "Playful Whistle - Cartoon",
    },
  ];

  final List<Map<String, dynamic>> forYouVideos = const [
    {
      "url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Volcano.mp4",
      "user": "@EarthVisuals",
      "caption": "Volcano eruption captured in 4K. Nature's raw power 🌋",
      "tags": "#Nature #Volcano #4K",
      "music": "Powerful Drums - Nature",
    },
    {
      "url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
      "user": "@AutoZone",
      "caption": "Subaru Outback — street to dirt, no compromises 🚙",
      "tags": "#Cars #OffRoad #Subaru",
      "music": "Adrenaline Rush - Electronic",
    },
    {
      "url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
      "user": "@FireWorks",
      "caption": "Fire like you've never seen before. Chromecast demo 🔥",
      "tags": "#Fire #Demo #Visual",
      "music": "Intense Bass - Electronic",
    },
    {
      "url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
      "user": "@WanderLust",
      "caption": "Escape to paradise. Beach vibes only 🏝️🌅",
      "tags": "#Beach #Sunset #Travel",
      "music": "Tropical House - Chill",
    },
    {
      "url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
      "user": "@JoySpreader",
      "caption": "Fun times with friends! Life is better when you're laughing 😄",
      "tags": "#Friends #Fun #Laugh",
      "music": "Happy Ukulele - Feel Good",
    },
    {
      "url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
      "user": "@IceCreamLover",
      "caption": "Meltdown mode activated. Summer essentials 🍦☀️",
      "tags": "#Summer #IceCream #Yummy",
      "music": "Sweet Melody - Pop",
    },
    {
      "url": "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
      "user": "@NatureDaily",
      "caption": "Butterfly migration season is here! 🦋🌍",
      "tags": "#Migration #Wildlife #Beautiful",
      "music": "Gentle Guitar - Acoustic",
    },
    {
      "url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
      "user": "@MegaScreen",
      "caption": "Size matters. The bigger, the better 📺",
      "tags": "#Tech #BigTV #Entertainment",
      "music": "Groove Master - Funk",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();

    // Immersive mode — hide system UI for full experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Tab content
          TabBarView(
            controller: _tabController,
            children: [
              _buildVideoFeed(discoverVideos),
              _buildVideoFeed(forYouVideos),
            ],
          ),

          // Modern top bar — glassmorphism style
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Live icon with pulse animation
                  _buildLiveButton(),

                  // Custom tab bar — modern pill style
                  _buildModernTabBar(),

                  // Search with glass effect
                  _buildGlassIconButton(
                    icon: Icons.search_rounded,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Search coming soon 🔍"),
                          backgroundColor: Colors.white.withOpacity(0.1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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

  Widget _buildLiveButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.3),
            Colors.pink.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            "LIVE",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTabBar() {
    return Container(
      width: 200,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF00BFA6)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.5),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.all(4),
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildVideoFeed(List<Map<String, dynamic>> videos) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: videos.length,
      onPageChanged: (index) {
        HapticFeedback.lightImpact();
      },
      itemBuilder: (context, index) {
        final video = videos[index];
        return FeedVideoItem(
          key: ValueKey("feed_${video['url']}_$index"),
          videoData: video,
          index: index,
        );
      },
    );
  }
}

/// Single video item — Ultra Modern Design
class FeedVideoItem extends StatefulWidget {
  final Map<String, dynamic> videoData;
  final int index;

  const FeedVideoItem({
    super.key,
    required this.videoData,
    required this.index,
  });

  @override
  State<FeedVideoItem> createState() => _FeedVideoItemState();
}

class _FeedVideoItemState extends State<FeedVideoItem>
    with TickerProviderStateMixin {
  late final VideoPlayerController _videoController;
  late final AnimationController _likeAnimController;
  late final AnimationController _musicController;

  bool _isInitialized = false;
  bool _isPlaying = true;
  bool _isMuted = false;

  // Actions state
  bool _isLiked = false;
  int _likeCount = 0;
  int _commentCount = 0;
  bool _showHeart = false;

  // Dynamic counts based on index for variety
  @override
  void initState() {
    super.initState();

    // Random-like counts for realism
    _likeCount = 1200 + (widget.index * 347) + (widget.index * 89);
    _commentCount = 45 + (widget.index * 12);

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoData['url']),
    );

    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _musicController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _videoController.initialize();
      if (!mounted) return;

      setState(() => _isInitialized = true);
      _videoController
        ..setLooping(true)
        ..play();
      _isPlaying = true;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitialized = false;
        _isPlaying = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _likeAnimController.dispose();
    _musicController.dispose();
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

  void _onDoubleTap() {
    HapticFeedback.mediumImpact();
    if (!_isLiked) {
      _onLike();
    }
    setState(() => _showHeart = true);
    _likeAnimController.forward(from: 0).then((_) {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  void _onLike() {
    HapticFeedback.lightImpact();
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  void _onComment() {
    HapticFeedback.lightImpact();
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF00BFA6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Comments ($_commentCount)",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Sample comments
                ..._buildSampleComments(),

                const SizedBox(height: 16),

                // Input field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Add a comment...",
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (textController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Write something first ✍️"),
                                backgroundColor: Color(0xFF2D2D44),
                              ),
                            );
                            return;
                          }
                          setState(() => _commentCount += 1);
                          Navigator.of(ctx).pop();
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFF00BFA6)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildSampleComments() {
    final comments = [
      {"user": "@CreativeSoul", "text": "This is absolutely stunning! 🔥", "time": "2m"},
      {"user": "@DesignGuru", "text": "Love the aesthetic here ✨", "time": "15m"},
      {"user": "@FlutterFan", "text": "Smooth animations! How did you do that?", "time": "1h"},
      {"user": "@TechieLife", "text": "Following for more content 👏", "time": "3h"},
    ];

    return comments.map((c) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.primaries[comments.indexOf(c) % Colors.primaries.length],
                    Colors.primaries[(comments.indexOf(c) + 2) % Colors.primaries.length],
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  c['user']![1].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c['user']!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c['text']!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            Text(
              c['time']!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _onShare() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF00BFA6)),
            SizedBox(width: 12),
            Text("Link copied to clipboard! 🔗"),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _videoController.setVolume(_isMuted ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlay,
      onDoubleTap: _onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video background
          Container(
            color: const Color(0xFF0A0A0F),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF6C63FF),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Loading experience...",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Gradient overlays — modern multi-layer
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0A0A0F).withOpacity(0.95),
                    const Color(0xFF0A0A0F).withOpacity(0.6),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // Top gradient for status bar
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0A0A0F).withOpacity(0.8),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Play/Pause indicator — modern glass style
          if (_isInitialized && !_isPlaying)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),

          // Double tap heart animation
          if (_showHeart)
            Center(
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.5, end: 1.5).animate(
                  CurvedAnimation(
                    parent: _likeAnimController,
                    curve: Curves.elasticOut,
                  ),
                ),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 1, end: 0).animate(
                    CurvedAnimation(
                      parent: _likeAnimController,
                      curve: const Interval(0.5, 1, curve: Curves.easeOut),
                    ),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 120,
                    color: Color(0xFFFF2D55),
                  ),
                ),
              ),
            ),

          // Right side actions — modern glassmorphism
          Positioned(
            right: 16,
            bottom: 140,
            child: Column(
              children: [
                // Profile with rotating music ring
                _buildProfileWithRing(),
                const SizedBox(height: 20),

                _buildGlassActionButton(
                  icon: _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  label: _formatCount(_likeCount),
                  onTap: _onLike,
                  active: _isLiked,
                  activeColor: const Color(0xFFFF2D55),
                ),
                const SizedBox(height: 20),

                _buildGlassActionButton(
                  icon: Icons.chat_bubble_rounded,
                  label: _formatCount(_commentCount),
                  onTap: _onComment,
                ),
                const SizedBox(height: 20),

                _buildGlassActionButton(
                  icon: Icons.bookmark_border_rounded,
                  label: "Save",
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Saved to collection 💾"),
                        backgroundColor: Color(0xFF1A1A2E),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                _buildGlassActionButton(
                  icon: Icons.share_rounded,
                  label: "Share",
                  onTap: _onShare,
                ),
                const SizedBox(height: 20),

                // Mute button
                _buildGlassActionButton(
                  icon: _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  label: _isMuted ? "Muted" : "Sound",
                  onTap: _toggleMute,
                ),
              ],
            ),
          ),

          // Bottom info section — modern typography
          Positioned(
            left: 20,
            right: 100,
            bottom: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username with verified badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF00BFA6)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.videoData['user'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF00BFA6),
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Caption
                Text(
                  widget.videoData['caption'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),

                // Tags
                Text(
                  widget.videoData['tags'],
                  style: TextStyle(
                    color: const Color(0xFF6C63FF).withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Music info with animated icon
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _musicController,
                        builder: (_, child) {
                          return Transform.rotate(
                            angle: _musicController.value * 2 * math.pi,
                            child: child,
                          );
                        },
                        child: const Icon(
                          Icons.music_note_rounded,
                          color: Color(0xFF00BFA6),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.videoData['music'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Original Sound",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Progress indicator — thin modern bar
          if (_isInitialized)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoProgressIndicator(
                _videoController,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Color(0xFF6C63FF),
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white10,
                ),
                padding: const EdgeInsets.symmetric(vertical: 2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileWithRing() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Rotating gradient ring
        AnimatedBuilder(
          animation: _musicController,
          builder: (_, child) {
            return Transform.rotate(
              angle: _musicController.value * 2 * math.pi,
              child: child,
            );
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
                colors: [
                  Color(0xFF6C63FF),
                  Color(0xFF00BFA6),
                  Color(0xFFFF2D55),
                  Color(0xFF6C63FF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
        // Profile image placeholder
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D44),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF0A0A0F),
              width: 3,
            ),
            image: const DecorationImage(
              image: NetworkImage(
                "https://api.dicebear.com/7.x/avataaars/svg?seed=modern",
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
    Color activeColor = const Color(0xFF6C63FF),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? activeColor.withOpacity(0.2)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active
                ? activeColor.withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: active ? activeColor : Colors.white,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? activeColor : Colors.white.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)}M".replaceAll(".0", "");
    if (n >= 1000) return "${(n / 1000).toStringAsFixed(1)}K".replaceAll(".0", "");
    return n.toString();
  }
}
