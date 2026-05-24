import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ══════════════════════════════════════════════════════════════════
//  MODEL
// ══════════════════════════════════════════════════════════════════
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

// ══════════════════════════════════════════════════════════════════
//  12 VIDEO DATASET
// ══════════════════════════════════════════════════════════════════
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
    caption: "Elephants Dream — a timeless open-source classic ✨ #blender #art #animation",
    sound: "Elephants Dream OST",
    likes: 196000, comments: 7600, shares: 3100,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
    username: "@adrenaline_rush",
    displayName: "Adrenaline Rush",
    caption: "When life gives you roads, take the joyride 🚗 Feel the speed! #joyride #fun #thrill",
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
    caption: "Street & dirt — no road is too tough 💪 Built for anything! #offroad #car #adventure",
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
    caption: "VW GTI Review 🚀 smooth like butter 🧈 This car is a beast! #car #review #gti #volkswagen",
    sound: "GTI Vibes - Engine Roar",
    likes: 267000, comments: 12300, shares: 6700,
  ),
];

// ══════════════════════════════════════════════════════════════════
//  PRELOAD CONSTANTS
// ══════════════════════════════════════════════════════════════════
const int kPreloadAhead = 2;
const int kPreloadBehind = 1;

// ══════════════════════════════════════════════════════════════════
//  HOME FEED PAGE
// ══════════════════════════════════════════════════════════════════
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
    // True edge-to-edge immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
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
      // No AppBar, no BottomNav — pure fullscreen
      body: Stack(
        fit: StackFit.expand,
        children: [
          TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _VideoFeedList(
                videos: List.from(kVideoList.reversed),
                feedKey: 'following',
              ),
              _VideoFeedList(
                videos: kVideoList,
                feedKey: 'new',
              ),
            ],
          ),
          _TopBar(tabController: _tabController),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  TOP BAR
// ══════════════════════════════════════════════════════════════════
class _TopBar extends StatefulWidget {
  final TabController tabController;
  const _TopBar({required this.tabController});

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  bool _hasUnread = true;

  void _showNotifications(BuildContext context) {
    setState(() => _hasUnread = false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NotificationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: top + 52,
        child: Padding(
          padding: EdgeInsets.only(top: top, left: 16, right: 16),
          child: Row(
            children: [
              const Icon(Icons.live_tv_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () => _showNotifications(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 26),
                    if (_hasUnread)
                      Positioned(
                        top: -2, right: -2,
                        child: Container(
                          width: 9, height: 9,
                          decoration: const BoxDecoration(
                            color: Colors.pinkAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 200,
                child: TabBar(
                  controller: widget.tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 2.5,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white38,
                  labelStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  tabs: const [Tab(text: "Following"), Tab(text: "For You")],
                ),
              ),
              const Spacer(),
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

// ══════════════════════════════════════════════════════════════════
//  VIDEO FEED LIST — controller pool manager
// ══════════════════════════════════════════════════════════════════
class _VideoFeedList extends StatefulWidget {
  final List<VideoData> videos;
  final String feedKey;
  const _VideoFeedList({required this.videos, required this.feedKey});

  @override
  State<_VideoFeedList> createState() => _VideoFeedListState();
}

class _VideoFeedListState extends State<_VideoFeedList>
    with WidgetsBindingObserver {
  final PageController _pageCtrl = PageController();
  final Map<int, VideoPlayerController> _pool = {};
  final Map<int, bool> _ready = {};
  int _current = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAround(0);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final c in _pool.values) c.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pool[_current]?.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (_ready[_current] == true) _pool[_current]?.play();
    }
  }

  Future<void> _initAround(int index) async {
    final keep = <int>{};
    for (int i = index - kPreloadBehind; i <= index + kPreloadAhead; i++) {
      if (i >= 0 && i < widget.videos.length) keep.add(i);
    }

    final toRemove = _pool.keys.where((k) => !keep.contains(k)).toList();
    for (final k in toRemove) {
      await _pool[k]?.pause();
      _pool[k]?.dispose();
      _pool.remove(k);
      _ready.remove(k);
    }

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
    _pool[_current]?.pause();
    _pool[_current]?.seekTo(Duration.zero);
    _current = index;
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
      // Smooth, snappy feel like TikTok
      physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
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

// ══════════════════════════════════════════════════════════════════
//  SINGLE VIDEO ITEM
// ══════════════════════════════════════════════════════════════════
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
  // Heart pop animation
  late final AnimationController _heartCtrl;
  late final Animation<double> _heartScale;
  late final Animation<double> _heartOpacity;

  // Like ripple
  Offset _tapPosition = Offset.zero;

  bool _isLiked = false;
  late int _likeCount;
  late int _commentCount;
  late int _shareCount;
  bool _isPlaying = true;
  bool _showHeart = false;
  bool _isFollowing = false;
  bool _captionExpanded = false;
  bool _isSaved = false;

  // Hold-to-pause
  bool _isHolding = false;

  final List<_CommentItem> _comments = [];

  @override
  void initState() {
    super.initState();
    _likeCount = widget.data.likes;
    _commentCount = widget.data.comments;
    _shareCount = widget.data.shares;

    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heartScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
    ]).animate(_heartCtrl);

    _heartOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_heartCtrl);

    _comments.addAll([
      _CommentItem("@user_1", "This is amazing! 🔥", 342),
      _CommentItem("@flutter_dev", "Smooth af bro 😍", 120),
      _CommentItem("@creative_soul", "Love this content 💯", 87),
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

  // ── Single tap → toggle play/pause
  void _togglePlay() {
    final ctrl = widget.controller;
    if (ctrl == null || !widget.isReady) return;
    setState(() => _isPlaying = !_isPlaying);
    _isPlaying ? ctrl.play() : ctrl.pause();
    HapticFeedback.selectionClick();
  }

  // ── Hold-to-pause
  void _onLongPressStart(LongPressStartDetails d) {
    final ctrl = widget.controller;
    if (ctrl == null || !widget.isReady) return;
    setState(() => _isHolding = true);
    ctrl.pause();
    HapticFeedback.mediumImpact();
  }

  void _onLongPressEnd(LongPressEndDetails d) {
    final ctrl = widget.controller;
    if (ctrl == null || !widget.isReady) return;
    setState(() => _isHolding = false);
    if (_isPlaying) ctrl.play();
  }

  // ── Double-tap → like with position
  void _onDoubleTapDown(TapDownDetails d) {
    _tapPosition = d.localPosition;
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

  void _onLike() {
    final wasLiked = _isLiked;
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    if (!wasLiked) {
      // Pop heart at center when using button
      _tapPosition = Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      );
      _popHeart();
    }
    HapticFeedback.lightImpact();
  }

  Future<void> _popHeart() async {
    _heartCtrl.forward(from: 0);
    setState(() => _showHeart = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _showHeart = false);
  }

  void _onComment() {
    final wasPlaying = _isPlaying;
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
      if (wasPlaying && mounted) {
        widget.controller?.play();
        setState(() => _isPlaying = true);
      }
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

  void _onSave() {
    setState(() => _isSaved = !_isSaved);
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSaved ? "Saved to collection ✨" : "Removed from collection"),
        duration: const Duration(seconds: 1),
        backgroundColor: _isSaved ? Colors.pinkAccent : Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      ),
    );
  }

  void _onFollow() {
    setState(() => _isFollowing = !_isFollowing);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ctrl = widget.controller;
    final ready = widget.isReady && ctrl != null;

    return GestureDetector(
      onTap: _togglePlay,
      onDoubleTapDown: _onDoubleTapDown,
      onDoubleTap: _onDoubleTap,
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background
          Container(color: Colors.black),

          // ── Video player — TRUE fullscreen cover
          if (ready)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
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
                strokeWidth: 2.5,
              ),
            ),

          // ── Bottom gradient (stronger, taller)
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: size.height * 0.55,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.85),
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // ── Top gradient
          Positioned(
            top: 0, left: 0, right: 0,
            height: size.height * 0.25,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Hold-to-pause overlay
          if (_isHolding)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pause_rounded, size: 52, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Hold to pause",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

          // ── Tap-to-play icon (brief flash, not holding)
          if (!_isPlaying && !_isHolding)
            Center(
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, size: 54, color: Colors.white),
                ),
              ),
            ),

          // ── Double-tap heart at tap position
          if (_showHeart)
            Positioned(
              left: _tapPosition.dx - 55,
              top: _tapPosition.dy - 55,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _heartCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _heartOpacity.value,
                    child: Transform.scale(
                      scale: _heartScale.value,
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 110,
                        color: Colors.pinkAccent,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 20)],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Thin progress bar at very bottom
          if (ready)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: _VideoProgressBar(controller: ctrl),
            ),

          // ── Right action buttons
          Positioned(
            right: 8,
            bottom: 90,
            child: _RightActions(
              username: widget.data.username,
              isLiked: _isLiked,
              likeCount: _likeCount,
              commentCount: _commentCount,
              shareCount: _shareCount,
              isFollowing: _isFollowing,
              isSaved: _isSaved,
              onLike: _onLike,
              onComment: _onComment,
              onShare: _onShare,
              onSave: _onSave,
              onFollow: _onFollow,
            ),
          ),

          // ── Bottom info (caption, username, sound)
          Positioned(
            left: 14,
            right: 80,
            bottom: 28,
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
}

// ══════════════════════════════════════════════════════════════════
//  CUSTOM PROGRESS BAR  (thin, scrubbable, pink)
// ══════════════════════════════════════════════════════════════════
class _VideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;
  const _VideoProgressBar({required this.controller});

  @override
  State<_VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<_VideoProgressBar> {
  bool _dragging = false;
  double _dragValue = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted && !_dragging) setState(() {});
  }

  double get _progress {
    if (_dragging) return _dragValue;
    final dur = widget.controller.value.duration.inMilliseconds;
    if (dur == 0) return 0;
    return widget.controller.value.position.inMilliseconds / dur;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (d) {
        setState(() => _dragging = true);
      },
      onHorizontalDragUpdate: (d) {
        final w = context.size?.width ?? 1;
        setState(() {
          _dragValue = (_dragValue + d.delta.dx / w).clamp(0.0, 1.0);
        });
      },
      onHorizontalDragEnd: (d) {
        final dur = widget.controller.value.duration;
        widget.controller.seekTo(dur * _dragValue);
        setState(() => _dragging = false);
      },
      child: SizedBox(
        height: 28, // tappable area
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: _dragging ? 4 : 2,
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  RIGHT ACTION BUTTONS
// ══════════════════════════════════════════════════════════════════
class _RightActions extends StatelessWidget {
  final String username;
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isFollowing;
  final bool isSaved;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onFollow;

  const _RightActions({
    required this.username,
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.isFollowing,
    required this.isSaved,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    final initial = username.length > 1 ? username[1].toUpperCase() : "U";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with follow indicator
        GestureDetector(
          onTap: onFollow,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.pinkAccent, Colors.deepPurpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              if (!isFollowing)
                Positioned(
                  bottom: -9,
                  child: Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Like button — animated
        _AnimatedActionBtn(
          icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          label: _fmt(likeCount),
          color: isLiked ? Colors.pinkAccent : Colors.white,
          onTap: onLike,
          glowColor: isLiked ? Colors.pinkAccent : null,
        ),

        const SizedBox(height: 20),

        // Comment
        _ActionBtn(
          icon: Icons.chat_bubble_outline_rounded,
          label: _fmt(commentCount),
          onTap: onComment,
        ),

        const SizedBox(height: 20),

        // Bookmark/Save
        _AnimatedActionBtn(
          icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          label: "Save",
          color: isSaved ? Colors.yellowAccent : Colors.white,
          onTap: onSave,
          glowColor: isSaved ? Colors.yellow : null,
        ),

        const SizedBox(height: 20),

        // Share
        _ActionBtn(
          icon: Icons.reply_rounded,
          label: _fmt(shareCount),
          onTap: onShare,
          flip: true,
        ),

        const SizedBox(height: 20),

        // Spinning music disc
        _SpinningDisc(),
      ],
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)}M".replaceAll('.0M', 'M');
    if (n >= 1000) return "${(n / 1000).toStringAsFixed(1)}K".replaceAll('.0K', 'K');
    return n.toString();
  }
}

// ── Animated action button (scale on press)
class _AnimatedActionBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Color? glowColor;

  const _AnimatedActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.glowColor,
  });

  @override
  State<_AnimatedActionBtn> createState() => _AnimatedActionBtnState();
}

class _AnimatedActionBtnState extends State<_AnimatedActionBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    _ctrl.reverse().then((_) => _ctrl.forward());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: ScaleTransition(
          scale: _scale,
          child: Column(
            children: [
              Icon(
                widget.icon,
                color: widget.color,
                size: 36,
                shadows: widget.glowColor != null
                    ? [Shadow(color: widget.glowColor!.withOpacity(0.8), blurRadius: 12)]
                    : const [Shadow(color: Colors.black54, blurRadius: 4)],
              ),
              if (widget.label.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.color == Colors.white ? Colors.white : widget.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    shadows: const [Shadow(color: Colors.black87, blurRadius: 6)],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Simple action button
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool flip;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.flip = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Transform.scale(
              scaleX: flip ? -1 : 1,
              child: Icon(icon, color: Colors.white, size: 36,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 4)]),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Spinning music disc (TikTok style)
class _SpinningDisc extends StatefulWidget {
  @override
  State<_SpinningDisc> createState() => _SpinningDiscState();
}

class _SpinningDiscState extends State<_SpinningDisc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF2A2A2A), Color(0xFF111111)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white24, width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.pinkAccent.withOpacity(0.3), blurRadius: 8),
          ],
        ),
        child: Center(
          child: Container(
            width: 14, height: 14,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
            ),
            child: const Center(
              child: Icon(Icons.music_note_rounded, color: Colors.white70, size: 9),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  BOTTOM INFO  (username + caption + sound)
// ══════════════════════════════════════════════════════════════════
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
        // Username + Follow
        Row(
          children: [
            Flexible(
              child: Text(
                data.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            if (!isFollowing)
              GestureDetector(
                onTap: onFollow,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    border: Border.all(color: Colors.white60),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    "Follow",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 6),

        // Caption — expandable with smooth animation
        GestureDetector(
          onTap: onToggleCaption,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: RichText(
              maxLines: expanded ? null : 2,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  height: 1.45,
                  shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                ),
                children: [
                  TextSpan(text: data.caption),
                  if (!expanded)
                    const TextSpan(
                      text: " ...more",
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Sound ticker
        _SoundTicker(sound: data.sound),
      ],
    );
  }
}

// ── Scrolling sound name (like TikTok)
class _SoundTicker extends StatefulWidget {
  final String sound;
  const _SoundTicker({required this.sound});

  @override
  State<_SoundTicker> createState() => _SoundTickerState();
}

class _SoundTickerState extends State<_SoundTicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _anim = Tween(begin: 0.0, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.music_note_rounded, color: Colors.white70, size: 13),
        const SizedBox(width: 5),
        Expanded(
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) {
                return Align(
                  alignment: Alignment(-1 + _anim.value * 2, 0),
                  child: Text(
                    "${widget.sound}     ${widget.sound}",
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  COMMENT DATA MODEL
// ══════════════════════════════════════════════════════════════════
class _CommentItem {
  final String username;
  final String text;
  int likes;
  bool liked;
  _CommentItem(this.username, this.text, this.likes, {this.liked = false});
}

// ══════════════════════════════════════════════════════════════════
//  COMMENT SHEET
// ══════════════════════════════════════════════════════════════════
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
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _post() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onPost(text);
    setState(() {});
    _ctrl.clear();
    _focus.unfocus();
    HapticFeedback.selectionClick();
    // Scroll to top to see new comment
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Drag handle
          Container(
            width: 38, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  "${widget.commentCount} comments",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
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
          const SizedBox(height: 10),
          const Divider(color: Colors.white10, height: 1),

          Expanded(
            child: ListView.builder(
              controller: _scroll,
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

          const Divider(color: Colors.white10, height: 1),

          // Comment input
          Padding(
            padding: EdgeInsets.only(
              left: 12, right: 12, top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
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
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        contentPadding: EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _post,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.pinkAccent.withOpacity(0.15),
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.pinkAccent, size: 26),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final _CommentItem item;
  final VoidCallback onLike;

  const _CommentTile({required this.item, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white12,
              border: Border.all(color: Colors.white.withOpacity(0.16)),
            ),
            child: const Icon(Icons.person, color: Colors.white54, size: 20),
          ),
          const SizedBox(width: 10),
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
                Text(item.text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
                const SizedBox(height: 5),
                const Text("Reply", style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onLike,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      item.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      key: ValueKey(item.liked),
                      color: item.liked ? Colors.pinkAccent : Colors.white54,
                      size: 18,
                    ),
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

// ══════════════════════════════════════════════════════════════════
//  SHARE SHEET
// ══════════════════════════════════════════════════════════════════
class _ShareOption {
  final dynamic icon;
  final String label;
  final Color bgColor;
  final bool isFa;
  const _ShareOption({required this.icon, required this.label, required this.bgColor, this.isFa = true});
}

class _ShareSheet extends StatelessWidget {
  const _ShareSheet();

  static final _options = [
    _ShareOption(icon: Icons.link_rounded,        label: "Copy Link",   bgColor: const Color(0xFF333333), isFa: false),
    _ShareOption(icon: FontAwesomeIcons.whatsapp,  label: "WhatsApp",   bgColor: const Color(0xFF25D366)),
    _ShareOption(icon: FontAwesomeIcons.telegram,  label: "Telegram",   bgColor: const Color(0xFF0088CC)),
    _ShareOption(icon: FontAwesomeIcons.facebook,  label: "Facebook",   bgColor: const Color(0xFF1877F2)),
    _ShareOption(icon: FontAwesomeIcons.instagram, label: "Instagram",  bgColor: const Color(0xFFE1306C)),
    _ShareOption(icon: FontAwesomeIcons.xTwitter,  label: "X (Twitter)",bgColor: const Color(0xFF000000)),
    _ShareOption(icon: Icons.more_horiz_rounded,   label: "More",       bgColor: const Color(0xFF444444), isFa: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38, height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Share to", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 94,
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
                        content: Text("Shared via ${opt.label} ✓"),
                        duration: const Duration(seconds: 1),
                        backgroundColor: opt.bgColor == const Color(0xFF333333) ? Colors.pinkAccent : opt.bgColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 58, height: 58,
                        decoration: BoxDecoration(
                          color: opt.bgColor,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: opt.bgColor.withOpacity(0.4), blurRadius: 10)],
                        ),
                        child: Center(
                          child: opt.isFa
                              ? FaIcon(opt.icon as IconData, color: Colors.white, size: 24)
                              : Icon(opt.icon as IconData, color: Colors.white, size: 26),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(opt.label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  NOTIFICATION MODEL
// ══════════════════════════════════════════════════════════════════
enum _NotifType { like, follow, comment, mention, duet }

class _NotifData {
  final String username;
  final _NotifType type;
  final String? extra;
  final String time;
  final Color avatarColor;
  bool isRead;

  _NotifData({
    required this.username,
    required this.type,
    this.extra,
    required this.time,
    required this.avatarColor,
    this.isRead = false,
  });

  String get message {
    switch (type) {
      case _NotifType.like:    return "liked your video. ${extra ?? ''}";
      case _NotifType.follow:  return "started following you.";
      case _NotifType.comment: return 'commented: "${extra ?? ''}"';
      case _NotifType.mention: return 'mentioned you: "${extra ?? ''}"';
      case _NotifType.duet:    return "dueted your video.";
    }
  }
}

// ══════════════════════════════════════════════════════════════════
//  NOTIFICATION SHEET
// ══════════════════════════════════════════════════════════════════
class _NotificationSheet extends StatefulWidget {
  const _NotificationSheet();
  @override
  State<_NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<_NotificationSheet> {
  final List<_NotifData> _newNotifs = [
    _NotifData(username: "@nature_vibes", type: _NotifType.like, extra: "Butterfly in slow motion 🦋", time: "2m ago", avatarColor: Colors.pinkAccent, isRead: false),
    _NotifData(username: "@wild_lens",    type: _NotifType.follow, time: "10m ago", avatarColor: Colors.deepPurpleAccent, isRead: false),
    _NotifData(username: "@animation_hub",type: _NotifType.comment, extra: "This is insane quality 🔥", time: "25m ago", avatarColor: Colors.orangeAccent, isRead: false),
    _NotifData(username: "@scifi_world",  type: _NotifType.mention, extra: "@you check this out!", time: "1h ago", avatarColor: Colors.cyanAccent, isRead: false),
  ];

  final List<_NotifData> _weekNotifs = [
    _NotifData(username: "@blender_art",  type: _NotifType.duet,    time: "2d ago", avatarColor: Colors.tealAccent,      isRead: true),
    _NotifData(username: "@road_warrior", type: _NotifType.like,    extra: "Street & dirt 💪", time: "3d ago", avatarColor: Colors.redAccent, isRead: true),
    _NotifData(username: "@fun_factory",  type: _NotifType.follow,  time: "4d ago", avatarColor: Colors.amberAccent,     isRead: true),
    _NotifData(username: "@bull_run_crew",type: _NotifType.comment, extra: "Bro this slaps 🔥", time: "5d ago", avatarColor: Colors.lightBlueAccent, isRead: true),
    _NotifData(username: "@car_review_bd",type: _NotifType.like,    extra: "VW GTI Review 🚀", time: "6d ago", avatarColor: Colors.greenAccent, isRead: true),
  ];

  final Set<String> _followingBack = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF0E0E0E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Text("Activity", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: 0.2)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded, color: Colors.white54, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white10, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _sectionHeader("New"),
                ..._newNotifs.map((e) => _NotifTile(
                  item: e,
                  isFollowing: _followingBack.contains(e.username),
                  onFollowBack: e.type == _NotifType.follow
                      ? () => setState(() {
                            _followingBack.contains(e.username)
                                ? _followingBack.remove(e.username)
                                : _followingBack.add(e.username);
                          })
                      : null,
                )),
                const SizedBox(height: 6),
                _sectionHeader("This Week"),
                ..._weekNotifs.map((e) => _NotifTile(
                  item: e,
                  isFollowing: _followingBack.contains(e.username),
                  onFollowBack: e.type == _NotifType.follow
                      ? () => setState(() {
                            _followingBack.contains(e.username)
                                ? _followingBack.remove(e.username)
                                : _followingBack.add(e.username);
                          })
                      : null,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
      child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final _NotifData item;
  final bool isFollowing;
  final VoidCallback? onFollowBack;

  const _NotifTile({required this.item, required this.isFollowing, this.onFollowBack});

  IconData get _typeIcon {
    switch (item.type) {
      case _NotifType.like:    return Icons.favorite_rounded;
      case _NotifType.follow:  return Icons.person_add_rounded;
      case _NotifType.comment: return Icons.chat_bubble_rounded;
      case _NotifType.mention: return Icons.alternate_email_rounded;
      case _NotifType.duet:    return Icons.queue_music_rounded;
    }
  }

  Color get _typeColor {
    switch (item.type) {
      case _NotifType.like:    return Colors.pinkAccent;
      case _NotifType.follow:  return Colors.purpleAccent;
      case _NotifType.comment: return Colors.blueAccent;
      case _NotifType.mention: return Colors.orangeAccent;
      case _NotifType.duet:    return Colors.tealAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: item.isRead ? Colors.transparent : Colors.white.withOpacity(0.035),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [item.avatarColor, item.avatarColor.withOpacity(0.5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              Positioned(
                bottom: -2, right: -2,
                child: Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: _typeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0E0E0E), width: 2),
                  ),
                  child: Icon(_typeIcon, color: Colors.white, size: 11),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.4),
                children: [
                  TextSpan(
                    text: item.username,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: " "),
                  TextSpan(text: item.message),
                  const TextSpan(text: "  "),
                  TextSpan(
                    text: item.time,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (onFollowBack != null)
            GestureDetector(
              onTap: onFollowBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isFollowing ? Colors.transparent : Colors.pinkAccent,
                  border: Border.all(color: isFollowing ? Colors.white30 : Colors.pinkAccent),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isFollowing ? "Following" : "Follow",
                  style: TextStyle(
                    color: isFollowing ? Colors.white54 : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else if (!item.isRead)
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(color: Colors.pinkAccent, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
