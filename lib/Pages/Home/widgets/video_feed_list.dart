import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../models/video_data.dart';
import '../home_provider.dart';
import '../../../Layout/responsive_layout.dart';
import '../../../Services/performance_service.dart';
import '../../../Services/native_service.dart';
import '../../../widgets/vx_premium_refresher.dart';
import 'feed_video_item.dart';
import 'feed_ad_item.dart';

// ─── Tunables ─────────────────────────────────────────
int kPreloadAhead = 5;
const int kPreloadBehind = 1;
const int _kFastScrollThreshold = 3;      // pages per 150ms = "fast"
const int _kPreloadDebounceMs = 150;      // ms to wait after scroll stops
const int _kEffectThrottleMs = 120;       // haptics / analytics throttle
const Duration _kSnapAnimSlow = Duration(milliseconds: 300);
const Duration _kSnapAnimFast = Duration(milliseconds: 120);
// ──────────────────────────────────────────────────────

class ZeroSlopVerticalDragGestureRecognizer extends VerticalDragGestureRecognizer {
  ZeroSlopVerticalDragGestureRecognizer({super.debugOwner});

  @override
  void handleEvent(PointerEvent event) {
    super.handleEvent(event);
    if (event is PointerMoveEvent) {
      // Logic: Only claim if movement is primarily vertical AND NOT primarily horizontal
      if (event.delta.dy.abs() > event.delta.dx.abs() && event.delta.dy.abs() > 0.1) {
        resolve(GestureDisposition.accepted);
      } else if (event.delta.dx.abs() > event.delta.dy.abs()) {
        // Explicitly reject if it looks horizontal, to let children (ImageSlideshow) have it
        resolve(GestureDisposition.rejected);
      }
    }
  }

  @override
  String get debugDescription => 'zero slop vertical drag';
}

class VideoFeedList extends StatefulWidget {
  final List<VideoData> videos;
  final String feedKey;
  final int initialIndex;
  final TabController? tabController;
  final int refreshCounter;

  const VideoFeedList({
    super.key,
    required this.videos,
    required this.feedKey,
    this.initialIndex = 0,
    this.tabController,
    this.refreshCounter = 0,
  });

  @override
  State<VideoFeedList> createState() => VideoFeedListState();
}

class VideoFeedListState extends State<VideoFeedList>
    with WidgetsBindingObserver {
  late final PageController _pageCtrl;
  final Map<int, VideoPlayerController> _pool = {};
  final Map<int, bool> _ready = {};
  late int _current;
  late List<VideoData> _videosWithAds;
  bool _isVisible = true;
  bool _isMovingPage = false;

  // ── Fast-scroll detection ──
  final List<int> _pageChangeTimes = [];
  bool get _isFastScrolling {
    final now = DateTime.now().millisecondsSinceEpoch;
    _pageChangeTimes.removeWhere((t) => now - t > 400);
    return _pageChangeTimes.length >= _kFastScrollThreshold;
  }

  // ── Debounced preloading ──
  Timer? _preloadDebounce;
  final Set<int> _pendingInit = {};

  // ── Throttled side effects ──
  DateTime? _lastViewLog;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
    _injectAds();
    WidgetsBinding.instance.addObserver(this);
    _adjustPreloadCount();
    _initAround(widget.initialIndex, immediate: true);
    
    // Request high refresh rate and turbo optimizations for gaming-smooth scrolling
    PerformanceService().setHighRefreshRate();
    PerformanceService().enableTouchOverclocking();
    PerformanceService().setTurboMode(true);
    PerformanceService().optimizeGpuLayers();
  }

  @override
  void didUpdateWidget(VideoFeedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if a global refresh happened
    if (widget.refreshCounter != oldWidget.refreshCounter) {
      _current = 0;
      if (_pageCtrl.hasClients) {
        _pageCtrl.jumpToPage(0);
      }
      _injectAds();
      _initAround(0, immediate: true);
    } else if (widget.videos != oldWidget.videos) {
      _injectAds();
      _initAround(_current, immediate: true);
    }
  }

  void pauseVideo() {
    if (_isVisible) {
      _isVisible = false;
      _pool[_current]?.pause();
      if (mounted) setState(() {});
    }
  }

  void resumeVideo() {
    if (!_isVisible) {
      _isVisible = true;
      if (_ready[_current] == true) _pool[_current]?.play();
      if (mounted) setState(() {});
    }
  }

  void _injectAds() {
    _videosWithAds = [];
    for (int i = 0; i < widget.videos.length; i++) {
      _videosWithAds.add(widget.videos[i]);
      if ((i + 1) % 6 == 0) {
        _videosWithAds.add(
          VideoData(
            id: -1,
            uploaderId: -1,
            url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
            username: "sponsored_ad",
            displayName: "Sponsored",
            avatarUrl: "",
            thumbnailUrl: "",
            caption: "Discover the amazing features of our new platform! 🚀 #advertisement #tech",
            sound: "Original Sound - Ads",
            likes: 0,
            comments: 0,
            views: 0,
            shares: 0,
            isAd: true,
            adCta: "Install Now",
            adLink: "https://google.com",
          ),
        );
      }
    }
  }

  Future<void> _adjustPreloadCount() async {
    final info = await PerformanceService().getMemoryInfo();
    if (info != null) {
      final avail = (info['availMem'] as int? ?? 0) ~/ (1024 * 1024);
      if (mounted) {
        setState(() {
          kPreloadAhead = nativeService.calculateMaxPreload(avail, 1);
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _preloadDebounce?.cancel();
    for (final c in _pool.values) {
      c.dispose();
    }
    _pool.clear();
    _ready.clear();
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

  // ═══════════════════════════════════════════════════════
  //  PRELOAD ENGINE  (debounced + fast-scroll aware)
  // ═══════════════════════════════════════════════════════
  void _initAround(int index, {bool immediate = false}) {
    if (!mounted) return;

    // Cancel pending debounce; we'll schedule a new one
    _preloadDebounce?.cancel();

    if (immediate) {
      _executePreload(index);
      return;
    }

    // During fast scroll, shrink window to reduce jank
    if (_isFastScrolling) {
      _executePreload(index, aggressive: false);
    }

    // Debounce the full preload so rapid snaps don't thrash
    _preloadDebounce = Timer(
      const Duration(milliseconds: _kPreloadDebounceMs),
          () {
        if (mounted) _executePreload(index);
      },
    );
  }

  void _executePreload(int center, {bool aggressive = true}) {
    if (!mounted) return;

    // Use a safer way to get velocity if available, or default to 0
    double velocity = 0;
    if (_pageCtrl.hasClients) {
      try {
        // Accessing velocity via pixels/time if activity is restricted
        velocity = _pageCtrl.position.pixels; // Fallback or use a different metric
      } catch (_) {}
    }

    final ahead = aggressive ? kPreloadAhead : 1;
    final behind = aggressive ? kPreloadBehind : 0;

    final keep = <int>{};
    
    // Use C++ to filter and prioritize buffer window based on velocity
    for (int i = 0; i < _videosWithAds.length; i++) {
      // Logic: 0 = priority (keep), 1 = background, -1 = dispose
      final priority = nativeService.calculateBufferPriority(velocity, i, center);
      
      // Keep videos within the immediate window regardless of C++ suggestion for safety
      if (i >= center - behind && i <= center + ahead) {
        keep.add(i);
        continue;
      }
      
      // If C++ suggests high priority even outside the window (e.g. fast scrolling ahead)
      if (priority > 0) {
        keep.add(i);
      }
    }

    // ── Dispose off-screen controllers OFF the main thread work ──
    final toRemove = _pool.keys.where((k) => !keep.contains(k)).toList();
    for (final k in toRemove) {
      _pool[k]?.pause();
      _pool[k]?.dispose();
      _pool.remove(k);
      _ready.remove(k);
    }

    // ── Initialize new ones ──
    for (final i in keep) {
      if (_pool.containsKey(i) || _pendingInit.contains(i)) continue;

      final url = _videosWithAds[i].url;
      if (url.isEmpty) continue;

      _pendingInit.add(i);

      if (kIsWeb) {
        _initWeb(i, url);
      } else {
        _initNative(i, url);
      }
    }
  }

  Future<void> _initWeb(int i, String url) async {
    final ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
    _pool[i] = ctrl;
    _ready[i] = false;

    try {
      await ctrl.initialize();
      _pendingInit.remove(i);
      if (!mounted) return;
      ctrl.setLooping(true);
      ctrl.setVolume(1.0);
      if (i == _current && _isVisible) ctrl.play();
      if (mounted) setState(() => _ready[i] = true);
    } catch (_) {
      _pendingInit.remove(i);
    }
  }

  Future<void> _initNative(int i, String url) async {
    try {
      final file = await DefaultCacheManager().getSingleFile(url);
      if (!mounted) return;

      final ctrl = VideoPlayerController.file(
        file,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
      );
      _pool[i] = ctrl;
      _ready[i] = false;

      await ctrl.initialize();
      _pendingInit.remove(i);
      if (!mounted) return;

      ctrl.setLooping(true);
      ctrl.setVolume(1.0);
      if (i == _current && _isVisible) ctrl.play();
      if (mounted) setState(() => _ready[i] = true);
    } catch (e) {
      _pendingInit.remove(i);
      if (!mounted) return;
      // Fallback
      final ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
      _pool[i] = ctrl;
      try {
        await ctrl.initialize();
        if (!mounted) return;
        if (i == _current && _isVisible) ctrl.play();
        if (mounted) setState(() => _ready[i] = true);
      } catch (_) {}
    }
  }

  // ═══════════════════════════════════════════════════════
  //  PAGE CHANGE  (velocity-aware + throttled effects)
  // ═══════════════════════════════════════════════════════
  void _onPageChanged(int index) {
    if (index == _current) return;

    final now = DateTime.now();
    _pageChangeTimes.add(now.millisecondsSinceEpoch);

    final wasFast = _isFastScrolling;
    final oldCurrent = _current;
    _current = index;

    // ── Throttled haptic (removed to fix unwanted vibration) ──

    // ── Throttled view count (skip ads + fast scroll) ──
    if (!_videosWithAds[index].isAd && !wasFast) {
      if (_lastViewLog == null ||
          now.difference(_lastViewLog!) > const Duration(milliseconds: _kEffectThrottleMs)) {
        _lastViewLog = now;
        context.read<HomeProvider>().incrementView(_videosWithAds[index].id);
      }
    }

    // ── Pause old, play new (only if not fast-scrolling) ──
    if (!wasFast) {
      if (oldCurrent != index && _pool.containsKey(oldCurrent)) {
        _pool[oldCurrent]?.pause();
      }
      if (_ready[index] == true && _isVisible) {
        _pool[index]?.play();
      }
    }

    // ── Debounced preload ──
    _initAround(index);

    if (mounted) setState(() {});
  }

  // ═══════════════════════════════════════════════════════
  //  NAVIGATION  (velocity-aware duration)
  // ═══════════════════════════════════════════════════════
  void _navigatePage(int delta, {bool fromKeyboard = false}) {
    if (_isMovingPage) return;
    final target = _current + delta;
    if (target < 0 || target >= _videosWithAds.length) return;

    _isMovingPage = true;

    // Use shorter animation if we're already in a fast-scroll burst
    final duration = _isFastScrolling || fromKeyboard
        ? _kSnapAnimFast
        : _kSnapAnimSlow;

    _pageCtrl
        .animateToPage(
      target,
      duration: duration,
      curve: Curves.easeOutCubic,
    )
        .then((_) => _isMovingPage = false);
  }

  void _jumpToPage(int delta) {
    final target = _current + delta;
    if (target < 0 || target >= _videosWithAds.length) return;
    _pageCtrl.jumpToPage(target); // zero-cost, no animation jank
  }

  void _togglePlayCurrent() {
    final ctrl = _pool[_current];
    if (ctrl == null) return;
    ctrl.value.isPlaying ? ctrl.pause() : ctrl.play();
  }

  // ═══════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            _navigatePage(1, fromKeyboard: true),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            _navigatePage(-1, fromKeyboard: true),
        const SingleActivator(LogicalKeyboardKey.space): _togglePlayCurrent,
        const SingleActivator(LogicalKeyboardKey.keyK): _togglePlayCurrent,
      },
      child: Focus(
        autofocus: true,
        child: Stack(
          children: [
            _buildVerticalFeed(),
            if (ResponsiveLayout.isDesktop(context))
              Positioned(
                right: 32,
                bottom: 120,
                child: Column(
                  children: [
                    _buildNavButton(
                      icon: CupertinoIcons.chevron_up,
                      onPressed: () => _navigatePage(-1),
                      enabled: _current > 0,
                    ),
                    const SizedBox(height: 16),
                    _buildNavButton(
                      icon: CupertinoIcons.chevron_down,
                      onPressed: () => _navigatePage(1),
                      enabled: _current < _videosWithAds.length - 1,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool enabled,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white, size: 28),
          onPressed: enabled ? onPressed : null,
          hoverColor: Colors.white.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  Widget _buildVerticalFeed() {
    if (widget.videos.isEmpty) return _buildShimmerFeed();

    return VxPremiumRefresher(
      onRefresh: () => context.read<HomeProvider>().fetchHomeFeed(refresh: true, context: context),
      child: RawGestureDetector(
        gestures: {
          ZeroSlopVerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<ZeroSlopVerticalDragGestureRecognizer>(
            () => ZeroSlopVerticalDragGestureRecognizer(),
            (instance) {
              instance.onStart = (details) {
                nativeService.processTouchEvent(0, 0, details.localPosition.dx, details.localPosition.dy, DateTime.now().millisecondsSinceEpoch);
              };
              instance.onUpdate = (details) {
                nativeService.processTouchEvent(0, 1, details.localPosition.dx, details.localPosition.dy, DateTime.now().millisecondsSinceEpoch);
                final delta = nativeService.getNativeScrollDelta();
                if (delta != 0 && _pageCtrl.hasClients) {
                  // Instant jump driven by C++ delta for zero-latency
                  _pageCtrl.position.jumpTo(_pageCtrl.position.pixels - delta);
                }
              };
              instance.onEnd = (details) {
                nativeService.processTouchEvent(0, 2, 0, 0, DateTime.now().millisecondsSinceEpoch);
                
                // Retrieve the high-precision velocity calculated in C++
                final velocity = nativeService.getNativeVelocity();
                final position = _pageCtrl.position.pixels;
                final viewport = _pageCtrl.position.viewportDimension;
                
                // TikTok-style page snapping
                double currentPage = _pageCtrl.page ?? _current.toDouble();
                int targetPage;
                
                if (velocity.abs() > 400) { 
                  // Velocity is negative for upward swipe, positive for downward
                  // But our PageView vertical axis: increasing index = increasing pixels (upward move)
                  targetPage = velocity < 0 ? currentPage.ceil() : currentPage.floor();
                  if (velocity < 0 && (currentPage - targetPage).abs() < 0.1) targetPage++;
                  if (velocity > 0 && (currentPage - targetPage).abs() < 0.1) targetPage--;
                } else {
                  targetPage = (position / viewport).round();
                }
                
                targetPage = targetPage.clamp(0, _videosWithAds.length - 1);
                
                _pageCtrl.animateToPage(
                  targetPage,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              };
            },
          ),
        },
        behavior: HitTestBehavior.opaque,
        child: Listener(
          onPointerSignal: _handlePointerSignal,
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: PageView.builder(
              controller: _pageCtrl,
              scrollDirection: Axis.vertical,
              itemCount: _videosWithAds.length,
              onPageChanged: _onPageChanged,
              physics: const NeverScrollableScrollPhysics(), // Managed by our ZeroSlop pipeline
              allowImplicitScrolling: true,
              itemBuilder: (context, index) {
                final data = _videosWithAds[index];
                return RepaintBoundary(
                  child: data.isAd
                      ? FeedAdItem(
                    key: ValueKey('${widget.feedKey}_ad_$index'),
                    data: data,
                    controller: _pool[index],
                    isReady: _ready[index] ?? false,
                    isCurrent: index == _current && _isVisible,
                  )
                      : FeedVideoItem(
                    key: ValueKey('${widget.feedKey}_$index'),
                    data: data,
                    controller: _pool[index],
                    isReady: _ready[index] ?? false,
                    isCurrent: index == _current && _isVisible,
                    tabController: widget.tabController,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handlePointerSignal(PointerSignalEvent pointerSignal) {
    if (pointerSignal is! PointerScrollEvent) return;
    if (_isMovingPage) return;

    final delta = pointerSignal.scrollDelta.dy;
    if (delta.abs() <= 10) return;

    // Mouse-wheel / trackpad: use jump for large deltas (fast scroll)
    if (delta.abs() > 40) {
      _jumpToPage(delta > 0 ? 1 : -1);
      return;
    }

    _isMovingPage = true;
    if (delta > 0 && _current < _videosWithAds.length - 1) {
      _pageCtrl
          .nextPage(duration: _kSnapAnimFast, curve: Curves.easeOutCubic)
          .then((_) => _isMovingPage = false);
    } else if (delta < 0 && _current > 0) {
      _pageCtrl
          .previousPage(duration: _kSnapAnimFast, curve: Curves.easeOutCubic)
          .then((_) => _isMovingPage = false);
    } else {
      _isMovingPage = false;
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _pool[_current]?.pause();
    } else if (notification is ScrollUpdateNotification) {
       // Automatic haptic feedback during scroll was removed to improve user experience
    } else if (notification is ScrollEndNotification) {
      if (_ready[_current] == true && _isVisible) {
        _pool[_current]?.play();
      }
      _initAround(_current);
    }
    return false;
  }

  Widget _buildShimmerFeed() {
    return ListView.builder(
      itemCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[900]!,
          highlightColor: Colors.grey[800]!,
          child: Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
            child: Stack(
              children: [
                Positioned(
                  bottom: 100,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 150, height: 20, color: Colors.white),
                      const SizedBox(height: 10),
                      Container(width: 250, height: 15, color: Colors.white),
                    ],
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 100,
                  child: Column(
                    children: List.generate(
                      4,
                          (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: CircleAvatar(backgroundColor: Colors.white, radius: 25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}