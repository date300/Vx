import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ══════════════════════════════════════════════════════════
//  MODEL
// ══════════════════════════════════════════════════════════
class VideoData {
  final String url;
  final String username;
  final String displayName;
  final String caption;
  final String sound;
  final int likes;
  final int comments;
  final int shares;

  const VideoData({
    required this.url,
    required this.username,
    required this.displayName,
    required this.caption,
    required this.sound,
    required this.likes,
    required this.comments,
    required this.shares,
  });
}

// ══════════════════════════════════════════════════════════
//  12 VIDEO DATASET
// ══════════════════════════════════════════════════════════
const List<VideoData> kVideoList = [
  VideoData(
    url: "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
    username: "@nature_vibes",
    displayName: "Nature Vibes",
    caption: "Butterfly in slow motion 🦋 Nature never stops amazing me! #nature #butterfly #wildlife",
    sound: "Nature Sounds - Chill Mix",
    likes: 128400, comments: 3200, shares: 940,
  ),
  VideoData(
    url: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
    username: "@wild_lens",
    displayName: "Wild Lens",
    caption: "Busy bee doing its thing 🐝 Save the bees, save the world! #wildlife #bee #nature",
    sound: "Buzzing Beats - DJ Honey",
    likes: 87600, comments: 1540, shares: 620,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    username: "@animation_hub",
    displayName: "Animation Hub",
    caption: "Big Buck Bunny is an absolute legend 🐰 Open source cinema at its finest! #animation #3d #blender",
    sound: "Big Buck Bunny OST",
    likes: 245000, comments: 9800, shares: 4200,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    username: "@blender_art",
    displayName: "Blender Art",
    caption: "Elephants Dream — a timeless open-source classic 🌀 #blender #art #animation",
    sound: "Elephants Dream OST",
    likes: 196000, comments: 7600, shares: 3100,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
    username: "@adrenaline_rush",
    displayName: "Adrenaline Rush",
    caption: "When life gives you roads, take the joyride 🚀 Feel the speed! #joyride #fun #thrill",
    sound: "Speed Demon - Turbo Mix",
    likes: 312000, comments: 11200, shares: 7800,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
    username: "@fire_starter",
    displayName: "Fire Starter",
    caption: "Bigger blazes = bigger dreams 🔥 Stay lit every single day! #fire #energy #motivation",
    sound: "Blaze It Up - LoFi",
    likes: 98700, comments: 4300, shares: 2100,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
    username: "@scifi_world",
    displayName: "SciFi World",
    caption: "Tears of Steel — the future is already here 🤖 #scifi #blender #vfx #film",
    sound: "Steel Tears - Cinematic",
    likes: 430000, comments: 18700, shares: 12400,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
    username: "@fun_factory",
    displayName: "Fun Factory",
    caption: "More fun, more life! Choose bigger, always 🎉 #fun #vibes #goodtimes",
    sound: "Fun Mode - Party Mix",
    likes: 76500, comments: 2900, shares: 1300,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
    username: "@escape_artist",
    displayName: "Escape Artist",
    caption: "Escape the ordinary 🌊 Life is too short for boring! #escape #travel #adventure",
    sound: "Ocean Escape - Chill",
    likes: 154000, comments: 6100, shares: 3800,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
    username: "@road_warrior",
    displayName: "Road Warrior",
    caption: "Street & dirt — no road is too tough 🚗💨 Built for anything! #offroad #car #adventure",
    sound: "Dirt Road Anthem",
    likes: 221000, comments: 8400, shares: 5100,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
    username: "@bull_run_crew",
    displayName: "Bull Run Crew",
    caption: "We are going on a bull run 🐂 Buckle up and hold tight! #bullrun #adventure #extreme",
    sound: "Bull Run Hype - Beats",
    likes: 189000, comments: 5500, shares: 4400,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4",
    username: "@car_review_bd",
    displayName: "Car Review BD",
    caption: "VW GTI Review — smooth like butter 🏎️ This car is a beast! #car #review #gti #volkswagen",
    sound: "GTI Vibes - Engine Roar",
    likes: 267000, comments: 12300, shares: 6700,
  ),
];

// ══════════════════════════════════════════════════════════
//  PRELOAD CONSTANT
// ══════════════════════════════════════════════════════════
const int kPreloadAhead = 2;  // load 2 ahead
const int kPreloadBehind = 1; // keep 1 behind

// ══════════════════════════════════════════════════════════
//  HOME FEED PAGE
// ══════════════════════════════════════════════════════════
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
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
          TabBarView(
            controller: _tabController,
            // disable horizontal swipe — tabs switch only by tapping
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _VideoFeedList(
                videos: List.from(kVideoList.reversed),
                feedKey: 'following',
              ),
              _VideoFeedList(
                videos: kVideoList,
                feedKey: 'foryou',
              ),
            ],
          ),
          _TopBar(tabController: _tabController),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  TOP BAR
// ══════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final TabController tabController;
  const _TopBar({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Live icon
              const Icon(Icons.live_tv_rounded, color: Colors.white, size: 24),
              const Spacer(),
              // Tab bar center
              SizedBox(
                width: 200,
                child: TabBar(
                  controller: tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 2,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  tabs: const [
                    Tab(text: "Following"),
                    Tab(text: "For You"),
                  ],
                ),
              ),
              const Spacer(),
              // Search icon
              GestureDetector(
                onTap: () {},
                child: const Icon(Icons.search_rounded, color: Colors.white, size: 26),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  VIDEO FEED LIST  — controller pool manager
// ══════════════════════════════════════════════════════════
class _VideoFeedList extends StatefulWidget {
  final List<VideoData> videos;
  final String feedKey;
  const _VideoFeedList({required this.videos, required this.feedKey});

  @override
  State<_VideoFeedList> createState() => _VideoFeedListState();
}

class _VideoFeedListState extends State<_VideoFeedList> {
  final PageController _pageCtrl = PageController();
  final Map<int, VideoPlayerController> _pool = {};
  final Map<int, bool> _ready = {};
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _initAround(0);
  }

  @override
  void dispose() {
    for (final c in _pool.values) c.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  // ── keep a sliding window of controllers ──────────────
  Future<void> _initAround(int index) async {
    final keep = <int>{};
    for (int i = index - kPreloadBehind; i <= index + kPreloadAhead; i++) {
      if (i >= 0 && i < widget.videos.length) keep.add(i);
    }

    // dispose out-of-window controllers
    final toRemove = _pool.keys.where((k) => !keep.contains(k)).toList();
    for (final k in toRemove) {
      await _pool[k]?.pause();
      _pool[k]?.dispose();
      _pool.remove(k);
      _ready.remove(k);
    }

    // initialize new ones
    for (final i in keep) {
      if (_pool.containsKey(i)) continue;
      final ctrl = VideoPlayerController.networkUrl(
        Uri.parse(widget.videos[i].url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
      );
      _pool[i] = ctrl;
      _ready[i] = false;

      ctrl.initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready[i] = true);
        ctrl.setLooping(true);
        if (i == _current) ctrl.play();
      }).catchError((_) {});
    }
  }

  void _onPageChanged(int index) {
    // pause previous, seek to start
    _pool[_current]?.pause();
    _pool[_current]?.seekTo(Duration.zero);

    _current = index;

    // play current if ready
    if (_ready[index] == true) _pool[index]?.play();

    _initAround(index);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageCtrl,
      scrollDirection: Axis.vertical,
      itemCount: widget.videos.length,
      onPageChanged: _onPageChanged,
      // ★ TikTok-style: snappy, no bounce, no over-scroll
      physics: const _TikTokScrollPhysics(),
      itemBuilder: (context, index) {
        return FeedVideoItem(
          key: ValueKey('${widget.feedKey}_$index'),
          data: widget.videos[index],
          controller: _pool[index],
          isReady: _ready[index] ?? false,
          isCurrent: index == _current,
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════
//  TIKTOK SCROLL PHYSICS — snappy, no bounce
// ══════════════════════════════════════════════════════════
class _TikTokScrollPhysics extends PageScrollPhysics {
  const _TikTokScrollPhysics() : super(parent: const ClampingScrollPhysics());

  @override
  _TikTokScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      const _TikTokScrollPhysics();

  // Tight spring = snappy snap like TikTok
  @override
  SpringDescription get spring => const SpringDescription(
        mass: 50,
        stiffness: 600,
        damping: 1.0,
      );
}

// ══════════════════════════════════════════════════════════
//  SINGLE VIDEO ITEM
// ══════════════════════════════════════════════════════════
class FeedVideoItem extends StatefulWidget {
  final VideoData data;
  final VideoPlayerController? controller;
  final bool isReady;
  final bool isCurrent;

  const FeedVideoItem({
    super.key,
    required this.data,
    required this.controller,
    required this.isReady,
    required this.isCurrent,
  });

  @override
  State<FeedVideoItem> createState() => _FeedVideoItemState();
}

class _FeedVideoItemState extends State<FeedVideoItem>
    with SingleTickerProviderStateMixin {
  // ── animation ─────────────────────────────────────────
  late final AnimationController _heartCtrl;
  late final Animation<double> _heartScale;

  // ── state ─────────────────────────────────────────────
  bool _isLiked = false;
  late int _likeCount;
  late int _commentCount;
  late int _shareCount;
  bool _isPlaying = true;
  bool _showHeart = false;
  bool _isFollowing = false;
  bool _captionExpanded = false;

  // fake comment list for the sheet
  final List<_CommentItem> _comments = [];

  @override
  void initState() {
    super.initState();
    _likeCount = widget.data.likes;
    _commentCount = widget.data.comments;
    _shareCount = widget.data.shares;

    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heartScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heartCtrl, curve: Curves.elasticOut),
    );

    // seed a few fake comments
    _comments.addAll([
      _CommentItem("@user_1", "This is amazing! 🔥", 342),
      _CommentItem("@flutter_dev", "Smooth af bro 💯", 120),
      _CommentItem("@creative_soul", "Love this content 😍", 87),
    ]);
  }

  @override
  void didUpdateWidget(FeedVideoItem old) {
    super.didUpdateWidget(old);
    if (widget.isCurrent && !old.isCurrent) {
      setState(() => _isPlaying = true);
    }
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  // ── actions ───────────────────────────────────────────

  void _togglePlay() {
    final ctrl = widget.controller;
    if (ctrl == null || !widget.isReady) return;
    setState(() => _isPlaying = !_isPlaying);
    _isPlaying ? ctrl.play() : ctrl.pause();
  }

  void _onLike() {
    final wasLiked = _isLiked;
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    if (!wasLiked) _popHeart();
    HapticFeedback.lightImpact();
  }

  void _onDoubleTap() {
    if (!_isLiked) {
      setState(() {
        _isLiked = true;
        _likeCount += 1;
      });
    }
    _popHeart();
    HapticFeedback.mediumImpact();
  }

  Future<void> _popHeart() async {
    setState(() => _showHeart = true);
    _heartCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _showHeart = false);
    _heartCtrl.reset();
  }

  void _onComment() {
    // pause video while commenting
    if (_isPlaying) widget.controller?.pause();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentSheet(
        comments: _comments,
        commentCount: _commentCount,
        onPost: (text) {
          setState(() {
            _comments.insert(0, _CommentItem("@you", text, 0));
            _commentCount += 1;
          });
        },
      ),
    ).whenComplete(() {
      // resume video after sheet closes
      if (_isPlaying && mounted) widget.controller?.play();
    });
  }

  void _onShare() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ShareSheet(),
    );
  }

  void _onFollow() {
    setState(() => _isFollowing = !_isFollowing);
    HapticFeedback.selectionClick();
  }

  // ── build ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ctrl = widget.controller;
    final ready = widget.isReady && ctrl != null;

    return GestureDetector(
      onTap: _togglePlay,
      onDoubleTap: _onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── video / loading ──────────────────────────
          Container(color: Colors.black),
          if (ready)
            SizedBox.expand(
              child: FittedBox(
                // cover fills screen; contain keeps aspect ratio with black bars
                fit: _isTallVideo(ctrl) ? BoxFit.cover : BoxFit.contain,
                child: SizedBox(
                  width: ctrl.value.size.width,
                  height: ctrl.value.size.height,
                  child: VideoPlayer(ctrl),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: Colors.pinkAccent,
                strokeWidth: 2,
              ),
            ),

          // ── gradients ───────────────────────────────
          _buildGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            color: const Color(0x66000000),
          ),
          _buildGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.center,
            color: const Color(0xCC000000),
            height: size.height * 0.52,
          ),

          // ── pause icon ──────────────────────────────
          if (ready && !_isPlaying)
            Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pause_rounded,
                  size: 52,
                  color: Colors.white,
                ),
              ),
            ),

          // ── double-tap heart ────────────────────────
          if (_showHeart)
            IgnorePointer(
              child: Center(
                child: ScaleTransition(
                  scale: _heartScale,
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 110,
                    color: Colors.pinkAccent,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 20)],
                  ),
                ),
              ),
            ),

          // ── video progress bar ───────────────────────
          if (ready)
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
                  backgroundColor: Colors.transparent,
                ),
                padding: EdgeInsets.zero,
              ),
            ),

          // ── right action buttons ─────────────────────
          Positioned(
            right: 10,
            bottom: 100,
            child: _RightActions(
              username: widget.data.username,
              isLiked: _isLiked,
              likeCount: _likeCount,
              commentCount: _commentCount,
              shareCount: _shareCount,
              isFollowing: _isFollowing,
              onLike: _onLike,
              onComment: _onComment,
              onShare: _onShare,
              onFollow: _onFollow,
            ),
          ),

          // ── bottom user info + caption ───────────────
          Positioned(
            left: 14,
            right: 80,
            bottom: 90,
            child: _BottomInfo(
              data: widget.data,
              isFollowing: _isFollowing,
              expanded: _captionExpanded,
              onToggleCaption: () =>
                  setState(() => _captionExpanded = !_captionExpanded),
              onFollow: _onFollow,
            ),
          ),
        ],
      ),
    );
  }

  bool _isTallVideo(VideoPlayerController c) {
    final vAspect = c.value.aspectRatio; // w/h
    return vAspect <= 1.0; // portrait or square → cover
  }

  Widget _buildGradient({
    required AlignmentGeometry begin,
    required AlignmentGeometry end,
    required Color color,
    double? height,
  }) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: end == Alignment.center ? null : 0,
      top: begin == Alignment.topCenter ? 0 : null,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, Colors.transparent],
            begin: begin,
            end: end,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  RIGHT ACTION BUTTONS COLUMN
// ══════════════════════════════════════════════════════════
class _RightActions extends StatelessWidget {
  final String username;
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isFollowing;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFollow;

  const _RightActions({
    required this.username,
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.isFollowing,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    final initial =
        username.length > 1 ? username[1].toUpperCase() : "U";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── avatar + follow ──
        GestureDetector(
          onTap: onFollow,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
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
              ),
              // follow + badge
              if (!isFollowing)
                Positioned(
                  bottom: -8,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Colors.pinkAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // ── like ──
        _Btn(
          icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          label: _fmt(likeCount),
          color: isLiked ? Colors.pinkAccent : Colors.white,
          onTap: onLike,
        ),

        const SizedBox(height: 18),

        // ── comment ──
        _Btn(
          icon: Icons.chat_bubble_outline_rounded,
          label: _fmt(commentCount),
          color: Colors.white,
          onTap: onComment,
        ),

        const SizedBox(height: 18),

        // ── share ──
        _Btn(
          icon: Icons.reply_rounded,
          label: _fmt(shareCount),
          color: Colors.white,
          onTap: onShare,
          flip: true,
        ),

        const SizedBox(height: 18),

        // ── more ──
        _Btn(
          icon: Icons.more_horiz_rounded,
          label: "",
          color: Colors.white,
          onTap: () {},
        ),
      ],
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) {
      return "${(n / 1000000).toStringAsFixed(1)}M"
          .replaceAll('.0M', 'M');
    }
    if (n >= 1000) {
      return "${(n / 1000).toStringAsFixed(1)}K"
          .replaceAll('.0K', 'K');
    }
    return n.toString();
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool flip;

  const _Btn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.flip = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Transform.scale(
              scaleX: flip ? -1 : 1,
              child: Icon(icon, color: color, size: 34),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: color == Colors.white ? Colors.white : color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  BOTTOM INFO (username + caption + sound)
// ══════════════════════════════════════════════════════════
class _BottomInfo extends StatelessWidget {
  final VideoData data;
  final bool isFollowing;
  final bool expanded;
  final VoidCallback onToggleCaption;
  final VoidCallback onFollow;

  const _BottomInfo({
    required this.data,
    required this.isFollowing,
    required this.expanded,
    required this.onToggleCaption,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // username row
        Row(
          children: [
            Text(
              data.username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(color: Colors.black, blurRadius: 6)],
              ),
            ),
            const SizedBox(width: 10),
            if (!isFollowing)
              GestureDetector(
                onTap: onFollow,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white70),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Follow",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 7),

        // caption — expandable
        GestureDetector(
          onTap: onToggleCaption,
          child: RichText(
            maxLines: expanded ? null : 2,
            overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            text: TextSpan(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                height: 1.4,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
              children: [
                TextSpan(text: data.caption),
                if (!expanded)
                  const TextSpan(
                    text: " more",
                    style: TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // sound
        Row(
          children: [
            const Icon(Icons.music_note_rounded, color: Colors.white70, size: 13),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                data.sound,
                style: const TextStyle(
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
    );
  }
}

// ══════════════════════════════════════════════════════════
//  COMMENT DATA
// ══════════════════════════════════════════════════════════
class _CommentItem {
  final String username;
  final String text;
  int likes;
  bool liked;

  _CommentItem(this.username, this.text, this.likes, {this.liked = false});
}

// ══════════════════════════════════════════════════════════
//  COMMENT SHEET
// ══════════════════════════════════════════════════════════
class _CommentSheet extends StatefulWidget {
  final List<_CommentItem> comments;
  final int commentCount;
  final void Function(String) onPost;

  const _CommentSheet({
    required this.comments,
    required this.commentCount,
    required this.onPost,
  });

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _post() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onPost(text);
    setState(() {});
    _ctrl.clear();
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        children: [
          // handle
          const SizedBox(height: 10),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),

          // header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  "${widget.commentCount + widget.comments.where((c) => c.username == "@you").length} comments",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded, color: Colors.white54, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white12, height: 1),

          // comment list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.comments.length,
              itemBuilder: (_, i) {
                final c = widget.comments[i];
                return _CommentTile(
                  item: c,
                  onLike: () => setState(() {
                    c.liked = !c.liked;
                    c.likes += c.liked ? 1 : -1;
                  }),
                );
              },
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // input bar
          Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.pinkAccent, Colors.deepPurpleAccent],
                    ),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focus,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _post(),
                      decoration: const InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _post,
                  child: const Icon(Icons.send_rounded, color: Colors.pinkAccent, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single comment tile ───────────────────────────────────
class _CommentTile extends StatelessWidget {
  final _CommentItem item;
  final VoidCallback onLike;

  const _CommentTile({required this.item, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white12,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.person, color: Colors.white54, size: 20),
          ),
          const SizedBox(width: 10),

          // text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.username,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.text,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Reply",
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),

          // like
          GestureDetector(
            onTap: onLike,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Column(
                children: [
                  Icon(
                    item.liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: item.liked ? Colors.pinkAccent : Colors.white54,
                    size: 18,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.likes > 0 ? item.likes.toString() : "",
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  SHARE SHEET  (font_awesome_flutter icons)
// ══════════════════════════════════════════════════════════
class _ShareOption {
  final dynamic icon; // IconData works for both
  final String label;
  final Color bgColor;
  final bool isFa;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.bgColor,
    this.isFa = true,
  });
}

class _ShareSheet extends StatelessWidget {
  const _ShareSheet();

  static final _options = [
    _ShareOption(
      icon: Icons.link_rounded,
      label: "Copy Link",
      bgColor: const Color(0xFF333333),
      isFa: false,
    ),
    _ShareOption(
      icon: FontAwesomeIcons.whatsapp,
      label: "WhatsApp",
      bgColor: const Color(0xFF25D366),
    ),
    _ShareOption(
      icon: FontAwesomeIcons.telegram,
      label: "Telegram",
      bgColor: const Color(0xFF0088CC),
    ),
    _ShareOption(
      icon: FontAwesomeIcons.facebook,
      label: "Facebook",
      bgColor: const Color(0xFF1877F2),
    ),
    _ShareOption(
      icon: FontAwesomeIcons.instagram,
      label: "Instagram",
      bgColor: const Color(0xFFE1306C),
    ),
    _ShareOption(
      icon: FontAwesomeIcons.xTwitter,
      label: "X (Twitter)",
      bgColor: const Color(0xFF000000),
    ),
    _ShareOption(
      icon: Icons.more_horiz_rounded,
      label: "More",
      bgColor: const Color(0xFF444444),
      isFa: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Share to",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _options.length,
              separatorBuilder: (_, __) => const SizedBox(width: 18),
              itemBuilder: (_, i) {
                final opt = _options[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Shared via ${opt.label} 🔗"),
                        duration: const Duration(seconds: 1),
                        backgroundColor: opt.bgColor == const Color(0xFF333333)
                            ? Colors.pinkAccent
                            : opt.bgColor,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: opt.bgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: opt.isFa
                              ? FaIcon(opt.icon as IconData, color: Colors.white, size: 24)
                              : Icon(opt.icon as IconData, color: Colors.white, size: 26),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        opt.label,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

