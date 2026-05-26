import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ════════════════════════════════════════════════════════════════
//  CONSTANTS
// ════════════════════════════════════════════════════════════════
const int kPreloadAhead  = 3;
const int kPreloadBehind = 1;

// ════════════════════════════════════════════════════════════════
//  MODEL
// ════════════════════════════════════════════════════════════════
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

// ════════════════════════════════════════════════════════════════
//  DATASET
// ════════════════════════════════════════════════════════════════
const List<VideoData> kVideoList = [
  VideoData(
    url: "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
    username: "@nature_vibes", displayName: "Nature Vibes",
    caption: "Butterfly in slow motion 🦋 Nature never stops amazing me! #nature #butterfly #wildlife",
    sound: "Nature Sounds - Chill Mix", likes: 128400, comments: 3200, shares: 940,
  ),
  VideoData(
    url: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
    username: "@wild_lens", displayName: "Wild Lens",
    caption: "Busy bee doing its thing 🐝 Save the bees, save the world! #wildlife #bee #nature",
    sound: "Buzzing Beats - DJ Honey", likes: 87600, comments: 1540, shares: 620,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    username: "@animation_hub", displayName: "Animation Hub",
    caption: "Big Buck Bunny is an absolute legend 🐰 Open source cinema at its finest! #animation #3d #blender",
    sound: "Big Buck Bunny OST", likes: 245000, comments: 9800, shares: 4200,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    username: "@blender_art", displayName: "Blender Art",
    caption: "Elephants Dream — a timeless open-source classic 🎬 #blender #art #animation",
    sound: "Elephants Dream OST", likes: 196000, comments: 7600, shares: 3100,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
    username: "@adrenaline_rush", displayName: "Adrenaline Rush",
    caption: "When life gives you roads, take the joyride 🚗 Feel the speed! #joyride #fun #thrill",
    sound: "Speed Demon - Turbo Mix", likes: 312000, comments: 11200, shares: 7800,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
    username: "@fire_starter", displayName: "Fire Starter",
    caption: "Bigger blazes = bigger dreams 🔥 Stay lit every single day! #fire #energy #motivation",
    sound: "Blaze It Up - LoFi", likes: 98700, comments: 4300, shares: 2100,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
    username: "@scifi_world", displayName: "SciFi World",
    caption: "Tears of Steel — the future is already here 🤖 #scifi #blender #vfx #film",
    sound: "Steel Tears - Cinematic", likes: 430000, comments: 18700, shares: 12400,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
    username: "@fun_factory", displayName: "Fun Factory",
    caption: "More fun, more life! Choose bigger, always 🎉 #fun #vibes #goodtimes",
    sound: "Fun Mode - Party Mix", likes: 76500, comments: 2900, shares: 1300,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
    username: "@road_warrior", displayName: "Road Warrior",
    caption: "Street & dirt — no road is too tough 🚙 Built for anything! #offroad #car #adventure",
    sound: "Dirt Road Anthem", likes: 221000, comments: 8400, shares: 5100,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
    username: "@bull_run_crew", displayName: "Bull Run Crew",
    caption: "We are going on a bull run 🐂 Buckle up and hold tight! #bullrun #adventure #extreme",
    sound: "Bull Run Hype - Beats", likes: 189000, comments: 5500, shares: 4400,
  ),
  VideoData(
    url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4",
    username: "@car_review_bd", displayName: "Car Review BD",
    caption: "VW GTI Review 🔥 smooth like butter — This car is a beast! #car #review #gti #volkswagen",
    sound: "GTI Vibes - Engine Roar", likes: 267000, comments: 12300, shares: 6700,
  ),
];

// ════════════════════════════════════════════════════════════════
//  HOME FEED PAGE
// ════════════════════════════════════════════════════════════════
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _VideoFeedList(videos: List.from(kVideoList.reversed), feedKey: 'following'),
              _VideoFeedList(videos: kVideoList, feedKey: 'new'),
            ],
          ),
          _TopBar(tabController: _tabController),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  TOP BAR
// ════════════════════════════════════════════════════════════════
class _TopBar extends StatefulWidget {
  final TabController tabController;
  const _TopBar({required this.tabController});

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  bool _hasUnread = true;

  void _showNotifications(BuildContext context) {
    if (_hasUnread) setState(() => _hasUnread = false);
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
      top: 0, left: 0, right: 0,
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
                            color: Colors.pinkAccent, shape: BoxShape.circle,
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

// ════════════════════════════════════════════════════════════════
//  VIDEO FEED LIST
// ════════════════════════════════════════════════════════════════
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
  final Map<int, VideoPlayerController> _pool  = {};
  final Map<int, bool>                 _ready = {};
  int  _current    = 0;
  bool _flashing   = false;   // ← flash transition flag

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

  void _initAround(int index) {
    final keep = <int>{};
    for (int i = index - kPreloadBehind; i <= index + kPreloadAhead; i++) {
      if (i >= 0 && i < widget.videos.length) keep.add(i);
    }
    final toRemove = _pool.keys.where((k) => !keep.contains(k)).toList();
    for (final k in toRemove) {
      _pool[k]?.pause();
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
      _pool[i]  = ctrl;
      _ready[i] = false;
      ctrl.initialize().then((_) {
        if (!mounted) return;
        ctrl.setLooping(true);
        ctrl.setVolume(1.0);
        if (i == _current) ctrl.play();
        setState(() => _ready[i] = true);
      }).catchError((_) {});
    }
  }

  void _onPageChanged(int index) {
    _pool[_current]?.pause();
    _current = index;
    if (_ready[index] == true) _pool[index]?.play();
    _initAround(index);
    // চোখের পলকের মতো flash transition
    if (mounted) {
      setState(() => _flashing = true);
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) setState(() => _flashing = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageCtrl,
          scrollDirection: Axis.vertical,
          itemCount: widget.videos.length,
          onPageChanged: _onPageChanged,
          physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
          itemBuilder: (context, index) {
            return RepaintBoundary(
              child: FeedVideoItem(
                key: ValueKey('${widget.feedKey}_$index'),
                data: widget.videos[index],
                controller: _pool[index],
                isReady: _ready[index] ?? false,
                isCurrent: index == _current,
              ),
            );
          },
        ),
        // চোখের পলকের flash overlay
        AnimatedOpacity(
          opacity: _flashing ? 1.0 : 0.0,
          duration: Duration(milliseconds: _flashing ? 0 : 150),
          child: const ColoredBox(color: Colors.black),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  SINGLE VIDEO ITEM
// ════════════════════════════════════════════════════════════════
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
  late final ValueNotifier<bool> _likedNotifier;
  late final ValueNotifier<int>  _likeCountNotifier;
  late final ValueNotifier<bool> _savedNotifier;

  late final AnimationController _heartCtrl;
  late final Animation<double>   _heartScale;
  late final Animation<double>   _heartOpacity;

  Offset _tapPosition     = Offset.zero;
  bool   _isPlaying       = true;
  bool   _showHeart       = false;
  bool   _isFollowing     = false;
  bool   _captionExpanded = false;
  bool   _isHolding       = false;
  late int _commentCount;
  late int _shareCount;

  // TikTok-style horizontal drag to seek
  bool   _isSeeking       = false;
  double _seekProgress    = 0.0;
  double _dragStartX      = 0.0;
  double _seekStartProgress = 0.0;

  final List<_CommentItem> _comments = [];

  @override
  void initState() {
    super.initState();
    _likedNotifier     = ValueNotifier(false);
    _likeCountNotifier = ValueNotifier(widget.data.likes);
    _savedNotifier     = ValueNotifier(false);
    _commentCount      = widget.data.comments;
    _shareCount        = widget.data.shares;

    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _heartScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),  weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),  weight: 20),
    ]).animate(_heartCtrl);
    _heartOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_heartCtrl);

    _comments.addAll([
      _CommentItem("@user_1",        "This is amazing! 🔥", 342),
      _CommentItem("@flutter_dev",   "Smooth af bro 👌",    120),
      _CommentItem("@creative_soul", "Love this content 💖",  87),
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
    _likedNotifier.dispose();
    _likeCountNotifier.dispose();
    _savedNotifier.dispose();
    super.dispose();
  }

  // ── Toggle play/pause (NO haptic — কাঁপা বন্ধ) ──────────────
  void _togglePlay() {
    final ctrl = widget.controller;
    if (ctrl == null || !widget.isReady) return;
    // HapticFeedback removed — ভাইব্রেশন বন্ধ
    setState(() => _isPlaying = !_isPlaying);
    _isPlaying ? ctrl.play() : ctrl.pause();
  }

  void _onLongPressStart(LongPressStartDetails d) {
    final ctrl = widget.controller;
    if (ctrl == null || !widget.isReady) return;
    HapticFeedback.mediumImpact();
    setState(() => _isHolding = true);
    ctrl.pause();
  }

  void _onLongPressEnd(LongPressEndDetails d) {
    final ctrl = widget.controller;
    if (ctrl == null || !widget.isReady) return;
    setState(() => _isHolding = false);
    if (_isPlaying) ctrl.play();
  }

  void _onDoubleTapDown(TapDownDetails d) => _tapPosition = d.localPosition;

  void _onDoubleTap() {
    HapticFeedback.mediumImpact();
    if (!_likedNotifier.value) {
      _likedNotifier.value     = true;
      _likeCountNotifier.value = _likeCountNotifier.value + 1;
    }
    _popHeart();
  }

  void _onLike() {
    HapticFeedback.lightImpact();
    final wasLiked           = _likedNotifier.value;
    _likedNotifier.value     = !wasLiked;
    _likeCountNotifier.value = _likeCountNotifier.value + (wasLiked ? -1 : 1);
    if (!wasLiked) {
      _tapPosition = Offset(
        MediaQuery.of(context).size.width  / 2,
        MediaQuery.of(context).size.height / 2,
      );
      _popHeart();
    }
  }

  void _popHeart() {
    setState(() => _showHeart = true);
    _heartCtrl.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  void _onComment() {
    final wasPlaying = _isPlaying;
    widget.controller?.pause();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentSheet(
        comments: _comments,
        commentCount: _commentCount,
        onPost: (text) => setState(() {
          _comments.insert(0, _CommentItem("@you", text, 0));
          _commentCount += 1;
        }),
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
    HapticFeedback.lightImpact();
    _savedNotifier.value = !_savedNotifier.value;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_savedNotifier.value ? "Saved to collection 🔖" : "Removed from collection"),
      duration: const Duration(milliseconds: 900),
      backgroundColor: _savedNotifier.value ? Colors.pinkAccent : Colors.grey[800],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
    ));
  }

  void _onFollow() {
    HapticFeedback.selectionClick();
    setState(() => _isFollowing = !_isFollowing);
  }

  // ── TikTok-style horizontal drag seek ────────────────────────
  void _onSeekDragStart(DragStartDetails d) {
    final ctrl = widget.controller;
    if (ctrl == null || !widget.isReady) return;
    final dur = ctrl.value.duration.inMilliseconds;
    if (dur == 0) return;
    _dragStartX = d.localPosition.dx;
    _seekStartProgress = ctrl.value.position.inMilliseconds / dur;
    setState(() {
      _isSeeking = true;
      _seekProgress = _seekStartProgress;
    });
    ctrl.pause();
  }

  void _onSeekDragUpdate(DragUpdateDetails d) {
    final ctrl = widget.controller;
    if (ctrl == null || !_isSeeking) return;
    final screenW = MediaQuery.of(context).size.width;
    final delta   = (d.localPosition.dx - _dragStartX) / screenW;
    // sensitivity: full screen swipe = 100% video
    final newProg = (_seekStartProgress + delta * 1.5).clamp(0.0, 1.0);
    setState(() => _seekProgress = newProg);
  }

  void _onSeekDragEnd(DragEndDetails d) {
    final ctrl = widget.controller;
    if (ctrl == null || !_isSeeking) return;
    ctrl.seekTo(ctrl.value.duration * _seekProgress);
    setState(() => _isSeeking = false);
    if (_isPlaying) ctrl.play();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ctrl  = widget.controller;
    final ready = widget.isReady && ctrl != null;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      onTap: _togglePlay,
      onDoubleTapDown: _onDoubleTapDown,
      onDoubleTap: _onDoubleTap,
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      // TikTok drag-to-seek (horizontal)
      onHorizontalDragStart: _onSeekDragStart,
      onHorizontalDragUpdate: _onSeekDragUpdate,
      onHorizontalDragEnd: _onSeekDragEnd,
      child: Stack(
        fit: StackFit.expand,
        children: [

          // ── Video (smart ratio-aware rendering) ───────────────
          const ColoredBox(color: Colors.black),
          if (ready)
            RepaintBoundary(
              child: _SmartVideoPlayer(
                key: ValueKey(widget.data.url),
                controller: ctrl,
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: Colors.pinkAccent, strokeWidth: 2.5,
              ),
            ),

          // ── Bottom gradient ────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: size.height * 0.60,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xE6000000), Color(0x80000000), Colors.transparent],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // ── Top gradient ───────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: size.height * 0.25,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x80000000), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── TikTok seek overlay ────────────────────────────────
          if (_isSeeking)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withOpacity(0.35),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatDuration(
                          ready
                              ? ctrl.value.duration * _seekProgress
                              : Duration.zero,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 12)],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: size.width * 0.7,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _seekProgress,
                            backgroundColor: Colors.white30,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _seekProgress > _seekStartProgress
                                ? Icons.fast_forward_rounded
                                : Icons.fast_rewind_rounded,
                            color: Colors.white70,
                            size: 22,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "Slide to seek",
                            style: TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Hold overlay ───────────────────────────────────────
          if (_isHolding)
            ColoredBox(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // কালো ব্যাকগ্রাউন্ড ছাড়া শুধু আইকন
                    const Icon(
                      Icons.pause_rounded,
                      size: 72,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 20)],
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

          // ── Paused icon (কালো ব্যাকগ্রাউন্ড ছাড়া শুধু আইকন) ──
          if (!_isPlaying && !_isHolding && !_isSeeking)
            const Center(
              child: Icon(
                Icons.play_arrow_rounded,
                size: 72,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black54, blurRadius: 20)],
              ),
            ),

          // ── Double-tap heart ───────────────────────────────────
          if (_showHeart)
            Positioned(
              left: _tapPosition.dx - 55,
              top:  _tapPosition.dy - 55,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _heartCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _heartOpacity.value,
                    child: Transform.scale(
                      scale: _heartScale.value,
                      child: const Icon(
                        Icons.favorite_rounded, size: 110,
                        color: Colors.pinkAccent,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 20)],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Progress bar ───────────────────────────────────────
          if (ready)
            Positioned(
              left: 0, right: 0,
              bottom: bottomPad,
              child: RepaintBoundary(
                child: _isSeeking
                    ? _SeekProgressBar(progress: _seekProgress)
                    : _VideoProgressBar(controller: ctrl),
              ),
            ),

          // ── Right actions ──────────────────────────────────────
          Positioned(
            right: 8,
            bottom: bottomPad + 16,
            child: RepaintBoundary(
              child: _RightActions(
                username:          widget.data.username,
                likedNotifier:     _likedNotifier,
                likeCountNotifier: _likeCountNotifier,
                savedNotifier:     _savedNotifier,
                commentCount:      _commentCount,
                shareCount:        _shareCount,
                isFollowing:       _isFollowing,
                onLike:    _onLike,
                onComment: _onComment,
                onShare:   _onShare,
                onSave:    _onSave,
                onFollow:  _onFollow,
              ),
            ),
          ),

          // ── Bottom info ────────────────────────────────────────
          Positioned(
            left: 14, right: 80,
            bottom: bottomPad + 12,
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

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}

// ════════════════════════════════════════════════════════════════
//  SMART VIDEO PLAYER — ratio অনুযায়ী best fit
//
//  Portrait  9:16  → full screen cover  (TikTok standard)
//  Near-portrait   → full screen cover
//  Square    1:1   → center crop with slight zoom
//  Landscape 16:9  → contain with blurred bg (cinematic)
// ════════════════════════════════════════════════════════════════
class _SmartVideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;
  const _SmartVideoPlayer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final vSize = controller.value.size;

    // size শূন্য হলে black দেখাও
    if (vSize.width == 0 || vSize.height == 0) {
      return const ColoredBox(color: Colors.black);
    }

    // rotation correction (90/270 হলে width-height উল্টে যায়)
    final int rotation   = controller.value.rotationCorrection;
    final bool isRotated = rotation == 90 || rotation == 270;
    final double vW      = isRotated ? vSize.height : vSize.width;
    final double vH      = isRotated ? vSize.width  : vSize.height;
    final double videoRatio = vW / vH;

    // Truly landscape (16:9=1.78, 4:3=1.33): ratio > 1.3
    // Portrait / Square / Near-portrait: ratio <= 1.3
    if (videoRatio > 1.3) {
      // ── Landscape: blurred bg + contained video (cinematic) ──
      return Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Transform.scale(
              scale: 1.5,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: vW, height: vH,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
          ),
          ColoredBox(color: Colors.black.withOpacity(0.4)),
          Center(
            child: AspectRatio(
              aspectRatio: videoRatio,
              child: VideoPlayer(controller),
            ),
          ),
        ],
      );
    } else {
      // ── Portrait/Square: pure black bg + full cover ───────────
      return Stack(
        fit: StackFit.expand,
        children: [
          // Pure black background — nav bar color এর সাথে match করে
          const ColoredBox(color: Colors.black),
          // Video full cover
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: vW, height: vH,
              child: VideoPlayer(controller),
            ),
          ),
        ],
      );
    }
  }
}

// ════════════════════════════════════════════════════════════════
//  SEEK PROGRESS BAR (drag করার সময় দেখায়)
// ════════════════════════════════════════════════════════════════
class _SeekProgressBar extends StatelessWidget {
  final double progress;
  const _SeekProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: 4,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  PROGRESS BAR (normal playback)
// ════════════════════════════════════════════════════════════════
class _VideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;
  const _VideoProgressBar({required this.controller});

  @override
  State<_VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<_VideoProgressBar> {
  bool   _dragging  = false;
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

  void _rebuild() { if (mounted && !_dragging) setState(() {}); }

  double get _progress {
    if (_dragging) return _dragValue;
    final dur = widget.controller.value.duration.inMilliseconds;
    if (dur == 0) return 0;
    return widget.controller.value.position.inMilliseconds / dur;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (_) => setState(() => _dragging = true),
      onHorizontalDragUpdate: (d) {
        final w = context.size?.width ?? 1;
        setState(() => _dragValue = (_dragValue + d.delta.dx / w).clamp(0.0, 1.0));
      },
      onHorizontalDragEnd: (_) {
        widget.controller.seekTo(widget.controller.value.duration * _dragValue);
        setState(() => _dragging = false);
      },
      child: SizedBox(
        height: 28,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
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

// ════════════════════════════════════════════════════════════════
//  RIGHT ACTIONS
// ════════════════════════════════════════════════════════════════
class _RightActions extends StatelessWidget {
  final String              username;
  final ValueNotifier<bool> likedNotifier;
  final ValueNotifier<int>  likeCountNotifier;
  final ValueNotifier<bool> savedNotifier;
  final int                 commentCount;
  final int                 shareCount;
  final bool                isFollowing;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onFollow;

  const _RightActions({
    required this.username,
    required this.likedNotifier,
    required this.likeCountNotifier,
    required this.savedNotifier,
    required this.commentCount,
    required this.shareCount,
    required this.isFollowing,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
    required this.onFollow,
  });

  String _fmt(int n) {
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)}M".replaceAll('.0M', 'M');
    if (n >= 1000)    return "${(n / 1000).toStringAsFixed(1)}K".replaceAll('.0K', 'K');
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final initial = username.length > 1 ? username[1].toUpperCase() : "U";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(color: Colors.pinkAccent.withOpacity(0.4), blurRadius: 10, spreadRadius: 1),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(initial,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
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
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        ValueListenableBuilder<bool>(
          valueListenable: likedNotifier,
          builder: (_, liked, __) => ValueListenableBuilder<int>(
            valueListenable: likeCountNotifier,
            builder: (_, count, __) => _AnimatedActionBtn(
              icon:  liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              label: _fmt(count),
              color: liked ? Colors.pinkAccent : Colors.white,
              onTap: onLike,
              glowColor: liked ? Colors.pinkAccent : null,
            ),
          ),
        ),

        const SizedBox(height: 20),

        _ActionBtn(
          icon: Icons.chat_bubble_outline_rounded,
          label: _fmt(commentCount),
          onTap: onComment,
        ),

        const SizedBox(height: 20),

        ValueListenableBuilder<bool>(
          valueListenable: savedNotifier,
          builder: (_, saved, __) => _AnimatedActionBtn(
            icon:  saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            label: "Save",
            color: saved ? Colors.yellowAccent : Colors.white,
            onTap: onSave,
            glowColor: saved ? Colors.yellow : null,
          ),
        ),

        const SizedBox(height: 20),

        _ActionBtn(
          icon: Icons.reply_rounded,
          label: _fmt(shareCount),
          onTap: onShare,
          flip: true,
        ),

        const SizedBox(height: 20),

        const _SpinningDisc(),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  ANIMATED ACTION BUTTON
// ════════════════════════════════════════════════════════════════
class _AnimatedActionBtn extends StatefulWidget {
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;
  final Color?       glowColor;

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

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.82,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

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
          scale: _ctrl,
          child: Column(
            children: [
              Icon(
                widget.icon, color: widget.color, size: 36,
                shadows: widget.glowColor != null
                    ? [Shadow(color: widget.glowColor!.withOpacity(0.8), blurRadius: 12)]
                    : const [Shadow(color: Colors.black54, blurRadius: 4)],
              ),
              if (widget.label.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(widget.label, style: TextStyle(
                  color: widget.color, fontSize: 12, fontWeight: FontWeight.w700,
                  shadows: const [Shadow(color: Colors.black87, blurRadius: 6)],
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;
  final bool         flip;

  const _ActionBtn({
    required this.icon, required this.label,
    required this.onTap, this.flip = false,
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
              Text(label, style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700,
                shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
              )),
            ],
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  SPINNING DISC
// ════════════════════════════════════════════════════════════════
class _SpinningDisc extends StatefulWidget {
  const _SpinningDisc();

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
      vsync: this, duration: const Duration(seconds: 5))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

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
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white24, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.3), blurRadius: 8)],
        ),
        child: const Center(
          child: SizedBox(
            width: 14, height: 14,
            child: DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white24),
              child: Center(
                child: Icon(Icons.music_note_rounded, color: Colors.white70, size: 9)),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  BOTTOM INFO
// ════════════════════════════════════════════════════════════════
class _BottomInfo extends StatelessWidget {
  final VideoData    data;
  final bool         isFollowing;
  final bool         expanded;
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
        Row(
          children: [
            Flexible(
              child: Text(data.username, style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
              ), overflow: TextOverflow.ellipsis),
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
                  child: const Text("Follow", style: TextStyle(
                    color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onToggleCaption,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: RichText(
              maxLines: expanded ? null : 2,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.white, fontSize: 13.5, height: 1.45,
                  shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                ),
                children: [
                  TextSpan(text: data.caption),
                  if (!expanded)
                    const TextSpan(
                      text: " ...more",
                      style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _SoundTicker(sound: data.sound),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  SMOOTH MARQUEE TICKER
// ════════════════════════════════════════════════════════════════
class _SoundTicker extends StatefulWidget {
  final String sound;
  const _SoundTicker({required this.sound});

  @override
  State<_SoundTicker> createState() => _SoundTickerState();
}

class _SoundTickerState extends State<_SoundTicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 8))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final text = "${widget.sound}          ${widget.sound}";
    return Row(
      children: [
        const Icon(Icons.music_note_rounded, color: Colors.white70, size: 13),
        const SizedBox(width: 5),
        Expanded(
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (ctx, _) {
                final w      = ctx.size?.width ?? 200;
                final offset = -_ctrl.value * w;
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                    maxLines: 1, softWrap: false,
                    overflow: TextOverflow.visible,
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

// ════════════════════════════════════════════════════════════════
//  COMMENT MODEL
// ════════════════════════════════════════════════════════════════
class _CommentItem {
  final String username;
  final String text;
  int  likes;
  bool liked;
  _CommentItem(this.username, this.text, this.likes, {this.liked = false});
}

// ════════════════════════════════════════════════════════════════
//  COMMENT SHEET
// ════════════════════════════════════════════════════════════════
class _CommentSheet extends StatefulWidget {
  final List<_CommentItem>    comments;
  final int                   commentCount;
  final void Function(String) onPost;

  const _CommentSheet({
    required this.comments, required this.commentCount, required this.onPost,
  });

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final TextEditingController _ctrl   = TextEditingController();
  final FocusNode             _focus  = FocusNode();
  final ScrollController      _scroll = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose(); _focus.dispose(); _scroll.dispose();
    super.dispose();
  }

  void _post() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.selectionClick();
    widget.onPost(text);
    setState(() {});
    _ctrl.clear();
    _focus.unfocus();
    if (_scroll.hasClients) {
      _scroll.animateTo(0,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
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
          Container(
            width: 38, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text("${widget.commentCount} comments",
                  style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
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
                    c.liked  = !c.liked;
                    c.likes += c.liked ? 1 : -1;
                  }),
                );
              },
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
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
                      colors: [Colors.pinkAccent, Colors.deepPurpleAccent]),
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
              shape: BoxShape.circle, color: Colors.white12,
              border: Border.all(color: Colors.white.withOpacity(0.16)),
            ),
            child: const Icon(Icons.person, color: Colors.white54, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.username, style: const TextStyle(
                  color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(item.text, style: const TextStyle(
                  color: Colors.white, fontSize: 14, height: 1.4)),
                const SizedBox(height: 5),
                const Text("Reply",
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
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
                    duration: const Duration(milliseconds: 150),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      item.liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
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

// ════════════════════════════════════════════════════════════════
//  SHARE SHEET
// ════════════════════════════════════════════════════════════════
class _ShareOption {
  final dynamic icon;
  final String  label;
  final Color   bgColor;
  final bool    isFa;
  const _ShareOption({
    required this.icon, required this.label,
    required this.bgColor, this.isFa = true,
  });
}

class _ShareSheet extends StatelessWidget {
  const _ShareSheet();

  static const _options = [
    _ShareOption(icon: Icons.link_rounded,         label: "Copy Link",   bgColor: Color(0xFF333333), isFa: false),
    _ShareOption(icon: FontAwesomeIcons.whatsapp,  label: "WhatsApp",    bgColor: Color(0xFF25D366)),
    _ShareOption(icon: FontAwesomeIcons.telegram,  label: "Telegram",    bgColor: Color(0xFF0088CC)),
    _ShareOption(icon: FontAwesomeIcons.facebook,  label: "Facebook",    bgColor: Color(0xFF1877F2)),
    _ShareOption(icon: FontAwesomeIcons.instagram, label: "Instagram",   bgColor: Color(0xFFE1306C)),
    _ShareOption(icon: FontAwesomeIcons.xTwitter,  label: "X (Twitter)", bgColor: Color(0xFF000000)),
    _ShareOption(icon: Icons.more_horiz_rounded,   label: "More",        bgColor: Color(0xFF444444), isFa: false),
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
            decoration: BoxDecoration(
              color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Share to", style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
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
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Shared via ${opt.label} ✓"),
                      duration: const Duration(milliseconds: 900),
                      backgroundColor: opt.bgColor == const Color(0xFF333333)
                          ? Colors.pinkAccent : opt.bgColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    ));
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 58, height: 58,
                        decoration: BoxDecoration(
                          color: opt.bgColor, shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: opt.bgColor.withOpacity(0.4), blurRadius: 10),
                          ],
                        ),
                        child: Center(
                          child: opt.isFa
                              ? FaIcon(opt.icon as IconData, color: Colors.white, size: 24)
                              : Icon(opt.icon  as IconData, color: Colors.white, size: 26),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(opt.label, style: const TextStyle(
                        color: Colors.white70, fontSize: 11)),
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

// ════════════════════════════════════════════════════════════════
//  NOTIFICATION SHEET
// ════════════════════════════════════════════════════════════════
enum _NotifType { like, follow, comment, mention, duet }

class _NotifData {
  final String     username;
  final _NotifType type;
  final String?    extra;
  final String     time;
  final Color      avatarColor;
  bool             isRead;

  _NotifData({
    required this.username, required this.type, this.extra,
    required this.time, required this.avatarColor, this.isRead = false,
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

class _NotificationSheet extends StatefulWidget {
  const _NotificationSheet();

  @override
  State<_NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<_NotificationSheet> {
  final List<_NotifData> _newNotifs = [
    _NotifData(username: "@nature_vibes",  type: _NotifType.like,    extra: "Butterfly in slow motion 🦋", time: "2m ago",  avatarColor: Colors.pinkAccent,       isRead: false),
    _NotifData(username: "@wild_lens",     type: _NotifType.follow,                                          time: "10m ago", avatarColor: Colors.deepPurpleAccent, isRead: false),
    _NotifData(username: "@animation_hub", type: _NotifType.comment,  extra: "This is insane quality 🔥",  time: "25m ago", avatarColor: Colors.orangeAccent,     isRead: false),
    _NotifData(username: "@scifi_world",   type: _NotifType.mention,  extra: "@you check this out!",         time: "1h ago",  avatarColor: Colors.cyanAccent,       isRead: false),
  ];

  final List<_NotifData> _weekNotifs = [
    _NotifData(username: "@blender_art",   type: _NotifType.duet,                                            time: "2d ago", avatarColor: Colors.tealAccent,      isRead: true),
    _NotifData(username: "@road_warrior",  type: _NotifType.like,    extra: "Street & dirt 🚙",             time: "3d ago", avatarColor: Colors.redAccent,       isRead: true),
    _NotifData(username: "@fun_factory",   type: _NotifType.follow,                                          time: "4d ago", avatarColor: Colors.amberAccent,     isRead: true),
    _NotifData(username: "@bull_run_crew", type: _NotifType.comment,  extra: "Bro this slaps 🔥",           time: "5d ago", avatarColor: Colors.lightBlueAccent, isRead: true),
    _NotifData(username: "@car_review_bd", type: _NotifType.like,    extra: "VW GTI Review 🚗",             time: "6d ago", avatarColor: Colors.greenAccent,     isRead: true),
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
            decoration: BoxDecoration(
              color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Text("Activity", style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800,
                  fontSize: 20, letterSpacing: 0.2)),
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

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
    child: Text(title, style: const TextStyle(
      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
  );
}

class _NotifTile extends StatelessWidget {
  final _NotifData    item;
  final bool          isFollowing;
  final VoidCallback? onFollowBack;

  const _NotifTile({
    required this.item, required this.isFollowing, this.onFollowBack,
  });

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
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              Positioned(
                bottom: -2, right: -2,
                child: Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: _typeColor, shape: BoxShape.circle,
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
                  TextSpan(text: item.username,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const TextSpan(text: " "),
                  TextSpan(text: item.message),
                  const TextSpan(text: "  "),
                  TextSpan(text: item.time,
                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (onFollowBack != null)
            GestureDetector(
              onTap: onFollowBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isFollowing ? Colors.transparent : Colors.pinkAccent,
                  border: Border.all(
                    color: isFollowing ? Colors.white30 : Colors.pinkAccent),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isFollowing ? "Following" : "Follow",
                  style: TextStyle(
                    color: isFollowing ? Colors.white54 : Colors.white,
                    fontSize: 12, fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else if (!item.isRead)
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                color: Colors.pinkAccent, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
