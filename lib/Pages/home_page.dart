import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

// ─────────────────────────────────────────────
//  Video data model
// ─────────────────────────────────────────────
class VideoData {
  final String url;
  final String username;
  final String caption;
  final String sound;
  final int likes;
  final int comments;

  const VideoData({
    required this.url,
    required this.username,
    required this.caption,
    required this.sound,
    required this.likes,
    required this.comments,
  });
}

// ─────────────────────────────────────────────
//  12 videos dataset
// ─────────────────────────────────────────────
const List<VideoData> kVideoList = [
  VideoData(
    url: "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
    username: "@nature_vibes",
    caption: "Butterfly in slow motion 🦋 Nature is magical! #nature #butterfly",
    sound: "Nature Sounds - Chill Mix 🎵",
    likes: 128400,
    comments: 3200,
  ),
  VideoData(
    url: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
    username: "@wild_lens",
    caption: "Busy bee doing its thing 🐝 Save the bees! #wildlife #bee",
    sound: "Buzzing Beats - DJ Honey 🎵",
    likes: 87600,
    comments: 1540,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    username: "@animation_hub",
    caption: "Big Buck Bunny is iconic 🐰 Open source legend! #animation #3d",
    sound: "Big Buck Bunny OST 🎵",
    likes: 245000,
    comments: 9800,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    username: "@blender_art",
    caption: "Elephants Dream — a timeless classic 🌀 #blender #art",
    sound: "Elephants Dream OST 🎵",
    likes: 196000,
    comments: 7600,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
    username: "@adrenaline_rush",
    caption: "When life is a joyride 🚀 Feel the speed! #joyride #fun",
    sound: "Speed Demon - Turbo Mix 🎵",
    likes: 312000,
    comments: 11200,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
    username: "@fire_starter",
    caption: "Bigger blazes = bigger dreams 🔥 Stay lit! #fire #energy",
    sound: "Blaze It Up - LoFi 🎵",
    likes: 98700,
    comments: 4300,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
    username: "@scifi_world",
    caption: "Tears of Steel — future is now 🤖 #scifi #blender #vfx",
    sound: "Steel Tears - Cinematic 🎵",
    likes: 430000,
    comments: 18700,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
    username: "@fun_factory",
    caption: "For bigger fun, always choose more 🎉 #fun #vibes",
    sound: "Fun Mode - Party Mix 🎵",
    likes: 76500,
    comments: 2900,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
    username: "@escape_artist",
    caption: "Escape the ordinary 🌊 Life is too short! #escape #travel",
    sound: "Ocean Escape - Chill 🎵",
    likes: 154000,
    comments: 6100,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
    username: "@road_warrior",
    caption: "Street & dirt — no road too tough 🚗💨 #offroad #car",
    sound: "Dirt Road Anthem 🎵",
    likes: 221000,
    comments: 8400,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
    username: "@bull_run_crew",
    caption: "We are going on a bull run 🐂 Hold tight! #bullrun #adventure",
    sound: "Bull Run Hype - Beats 🎵",
    likes: 189000,
    comments: 5500,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4",
    username: "@car_review_bd",
    caption: "VW GTI Review — smooth like butter 🏎️ #car #review #gti",
    sound: "GTI Vibes - Engine Roar 🎵",
    likes: 267000,
    comments: 12300,
  ),
];

// ─────────────────────────────────────────────
//  Pre-load window: keep N controllers alive
// ─────────────────────────────────────────────
const int kPreloadWindow = 3; // load current + 3 ahead + 1 behind

// ─────────────────────────────────────────────
//  HomeFeedPage
// ─────────────────────────────────────────────
class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    // Full-screen immersive for TikTok feel
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Feed
          TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _VideoFeedList(
                videos: kVideoList.reversed.toList(), // different order for Following
                feedKey: 'following',
              ),
              _VideoFeedList(
                videos: kVideoList,
                feedKey: 'foryou',
              ),
            ],
          ),

          // Top navigation
          _TopBar(tabController: _tabController),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Top Bar
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final TabController tabController;
  const _TopBar({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.live_tv_rounded, color: Colors.white, size: 26),

            SizedBox(
              width: 220,
              child: TabBar(
                controller: tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 2.5,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.white54,
                ),
                tabs: const [
                  Tab(text: "Following"),
                  Tab(text: "For You"),
                ],
              ),
            ),

            GestureDetector(
              onTap: () {},
              child: const Icon(Icons.search_rounded, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Video Feed List — manages controller pool
// ─────────────────────────────────────────────
class _VideoFeedList extends StatefulWidget {
  final List<VideoData> videos;
  final String feedKey;

  const _VideoFeedList({required this.videos, required this.feedKey});

  @override
  State<_VideoFeedList> createState() => _VideoFeedListState();
}

class _VideoFeedListState extends State<_VideoFeedList> {
  final PageController _pageController = PageController();

  // Map of index → controller (only kPreloadWindow+2 alive at once)
  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, bool> _initialized = {};

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAround(0);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  // ── Load / unload controllers around the current page ──
  Future<void> _loadAround(int index) async {
    final toKeep = <int>{};
    for (int i = index - 1; i <= index + kPreloadWindow; i++) {
      if (i >= 0 && i < widget.videos.length) toKeep.add(i);
    }

    // Dispose controllers that are no longer needed
    final toRemove = _controllers.keys.where((k) => !toKeep.contains(k)).toList();
    for (final k in toRemove) {
      _controllers[k]?.dispose();
      _controllers.remove(k);
      _initialized.remove(k);
    }

    // Initialize new controllers
    for (final i in toKeep) {
      if (!_controllers.containsKey(i)) {
        final url = widget.videos[i].url;
        final ctrl = VideoPlayerController.networkUrl(
          Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
        );
        _controllers[i] = ctrl;
        _initialized[i] = false;

        ctrl.initialize().then((_) {
          if (!mounted) return;
          setState(() => _initialized[i] = true);
          if (i == _currentIndex) {
            ctrl.setLooping(true);
            ctrl.play();
          } else {
            // pre-buffer but don't play
            ctrl.setLooping(true);
          }
        }).catchError((_) {});
      }
    }
  }

  void _onPageChanged(int index) {
    // Pause old
    _controllers[_currentIndex]?.pause();
    _controllers[_currentIndex]?.seekTo(Duration.zero);

    _currentIndex = index;

    // Play current if ready
    final ctrl = _controllers[index];
    if (ctrl != null && (_initialized[index] ?? false)) {
      ctrl.play();
    }

    // Load surroundings
    _loadAround(index);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: widget.videos.length,
      onPageChanged: _onPageChanged,
      physics: const _SmoothPageScrollPhysics(),
      itemBuilder: (context, index) {
        return FeedVideoItem(
          key: ValueKey('${widget.feedKey}_$index'),
          data: widget.videos[index],
          controller: _controllers[index],
          isInitialized: _initialized[index] ?? false,
          isCurrentPage: index == _currentIndex,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Custom smooth scroll physics
// ─────────────────────────────────────────────
class _SmoothPageScrollPhysics extends PageScrollPhysics {
  const _SmoothPageScrollPhysics() : super(parent: const BouncingScrollPhysics());

  @override
  _SmoothPageScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      const _SmoothPageScrollPhysics();

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1.0,
      );
}

// ─────────────────────────────────────────────
//  Single Video Item
// ─────────────────────────────────────────────
class FeedVideoItem extends StatefulWidget {
  final VideoData data;
  final VideoPlayerController? controller;
  final bool isInitialized;
  final bool isCurrentPage;

  const FeedVideoItem({
    super.key,
    required this.data,
    required this.controller,
    required this.isInitialized,
    required this.isCurrentPage,
  });

  @override
  State<FeedVideoItem> createState() => _FeedVideoItemState();
}

class _FeedVideoItemState extends State<FeedVideoItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartAnim;
  bool _isLiked = false;
  late int _likeCount;
  late int _commentCount;
  bool _isPlaying = true;
  bool _showHeart = false;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.data.likes;
    _commentCount = widget.data.comments;
    _heartAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(FeedVideoItem old) {
    super.didUpdateWidget(old);
    if (widget.isCurrentPage && !old.isCurrentPage) {
      setState(() => _isPlaying = true);
    }
  }

  @override
  void dispose() {
    _heartAnim.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final ctrl = widget.controller;
    if (ctrl == null || !widget.isInitialized) return;
    setState(() {
      _isPlaying = !_isPlaying;
      _isPlaying ? ctrl.play() : ctrl.pause();
    });
  }

  void _onLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    if (_isLiked) _playHeartAnim();
  }

  void _onDoubleTap() {
    if (!_isLiked) _onLike();
    _playHeartAnim();
  }

  void _playHeartAnim() async {
    setState(() => _showHeart = true);
    await _heartAnim.forward();
    await _heartAnim.reverse();
    if (mounted) setState(() => _showHeart = false);
  }

  void _onComment() {
    final textCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  "Comments (${_formatCount(_commentCount)})",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Write a comment...",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white10,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (textCtrl.text.trim().isEmpty) return;
                  setState(() => _commentCount += 1);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Comment added! 💬"),
                      duration: Duration(seconds: 1),
                      backgroundColor: Colors.pinkAccent,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Send",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Link copied! 🔗"),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF222222),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ctrl = widget.controller;
    final initialized = widget.isInitialized && ctrl != null;

    // Compute video display size based on aspect ratio
    Widget videoWidget;
    if (initialized) {
      final videoAspect = ctrl.value.aspectRatio;
      final screenAspect = size.width / size.height;

      // If video is taller than screen → fit width; if wider → fit height
      BoxFit fit = videoAspect < screenAspect ? BoxFit.fitWidth : BoxFit.contain;

      videoWidget = SizedBox.expand(
        child: FittedBox(
          fit: fit,
          child: SizedBox(
            width: ctrl.value.size.width,
            height: ctrl.value.size.height,
            child: VideoPlayer(ctrl),
          ),
        ),
      );
    } else {
      videoWidget = const Center(
        child: CircularProgressIndicator(
          color: Colors.pinkAccent,
          strokeWidth: 2.5,
        ),
      );
    }

    return GestureDetector(
      onTap: _togglePlay,
      onDoubleTap: _onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Container(color: Colors.black),

          // Video
          videoWidget,

          // Dark gradient bottom
          const _BottomGradient(),

          // Dark gradient top (for top bar readability)
          const _TopGradient(),

          // Pause icon overlay
          if (initialized && !_isPlaying)
            Center(
              child: AnimatedOpacity(
                opacity: _isPlaying ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.pause_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Double-tap heart
          if (_showHeart)
            Center(
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.0, end: 1.3).animate(
                  CurvedAnimation(parent: _heartAnim, curve: Curves.elasticOut),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 120,
                  color: Colors.pinkAccent,
                ),
              ),
            ),

          // Progress bar
          if (initialized)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoProgressIndicator(
                ctrl,
                allowScrubbing: false,
                colors: const VideoProgressColors(
                  playedColor: Colors.pinkAccent,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white12,
                ),
                padding: EdgeInsets.zero,
              ),
            ),

          // Right action buttons
          Positioned(
            right: 14,
            bottom: 110,
            child: Column(
              children: [
                // Avatar
                _Avatar(username: widget.data.username),
                const SizedBox(height: 20),
                _ActionBtn(
                  icon: _isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  label: _formatCount(_likeCount),
                  onTap: _onLike,
                  active: _isLiked,
                  activeColor: Colors.pinkAccent,
                ),
                const SizedBox(height: 20),
                _ActionBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: _formatCount(_commentCount),
                  onTap: _onComment,
                  active: false,
                  activeColor: Colors.white,
                ),
                const SizedBox(height: 20),
                _ActionBtn(
                  icon: Icons.reply_rounded,
                  label: "Share",
                  onTap: _onShare,
                  active: false,
                  activeColor: Colors.white,
                  flipHorizontal: true,
                ),
                const SizedBox(height: 20),
                _ActionBtn(
                  icon: Icons.more_horiz_rounded,
                  label: "",
                  onTap: () {},
                  active: false,
                  activeColor: Colors.white,
                ),
              ],
            ),
          ),

          // Left — user info + caption
          Positioned(
            left: 16,
            right: 80,
            bottom: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username + Follow
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.data.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => setState(() => _isFollowing = !_isFollowing),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _isFollowing ? Colors.transparent : Colors.pinkAccent,
                          border: Border.all(
                            color: _isFollowing ? Colors.white60 : Colors.pinkAccent,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _isFollowing ? "Following" : "Follow",
                          style: TextStyle(
                            color: _isFollowing ? Colors.white60 : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Caption
                Text(
                  widget.data.caption,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Sound
                Row(
                  children: [
                    const Icon(Icons.music_note_rounded, color: Colors.white70, size: 13),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.data.sound,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
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

  String _formatCount(int n) {
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)}M".replaceAll(".0M", "M");
    if (n >= 1000) return "${(n / 1000).toStringAsFixed(1)}K".replaceAll(".0K", "K");
    return n.toString();
  }
}

// ─────────────────────────────────────────────
//  Reusable widgets
// ─────────────────────────────────────────────

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: MediaQuery.of(context).size.height * 0.55,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xDD000000), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      ),
    );
  }
}

class _TopGradient extends StatelessWidget {
  const _TopGradient();
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: 120,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0x99000000), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String username;
  const _Avatar({required this.username});

  @override
  Widget build(BuildContext context) {
    final initial = username.length > 1 ? username[1].toUpperCase() : "U";
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Colors.pinkAccent, Colors.deepPurpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final Color activeColor;
  final bool flipHorizontal;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.active,
    required this.activeColor,
    this.flipHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          children: [
            Transform.scale(
              scaleX: flipHorizontal ? -1 : 1,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: child,
                ),
                child: Icon(
                  icon,
                  key: ValueKey(active),
                  color: active ? activeColor : Colors.white,
                  size: 34,
                ),
              ),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

