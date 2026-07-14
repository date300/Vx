import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_data.dart';
import '../../../Layout/responsive_layout.dart';
import '../../../Services/performance_service.dart';
import '../../../Services/native_service.dart';
import '../utils/home_physics.dart';
import 'feed_video_item.dart';
import 'feed_ad_item.dart';

int kPreloadAhead = 3; // Reduced from 12 to 3 for better performance
const int kPreloadBehind = 1;

class VideoFeedList extends StatefulWidget {
  final List<VideoData> videos;
  final String feedKey;
  const VideoFeedList({super.key, required this.videos, required this.feedKey});

  @override
  State<VideoFeedList> createState() => _VideoFeedListState();
}

class _VideoFeedListState extends State<VideoFeedList>
    with WidgetsBindingObserver {
  final PageController _pageCtrl = PageController();
  final Map<int, VideoPlayerController> _pool  = {};
  final Map<int, bool>                 _ready = {};
  int _current = 0;
  late List<VideoData> _videosWithAds;

  @override
  void initState() {
    super.initState();
    _injectAds();
    WidgetsBinding.instance.addObserver(this);
    _adjustPreloadCount();
    _initAround(0);
  }

  void _injectAds() {
    _videosWithAds = [];
    for (int i = 0; i < widget.videos.length; i++) {
      _videosWithAds.add(widget.videos[i]);
      // Inject an ad every 2 videos
      if ((i + 1) % 2 == 0) {
        _videosWithAds.add(
          VideoData(
            url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4", // Mock Ad Video
            username: "@sponsored_ad",
            displayName: "Sponsored",
            caption: "Discover the amazing features of our new platform! 🚀 #advertisement #tech",
            sound: "Original Sound - Ads",
            likes: 0,
            comments: 0,
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
      setState(() {
        kPreloadAhead = nativeService.calculateMaxPreload(avail, 1);
      });
    }
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
      if (i >= 0 && i < _videosWithAds.length) keep.add(i);
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
        Uri.parse(_videosWithAds[i].url),
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
    if (index == _current) return; // Prevent redundant calls

    _pool[_current]?.pause();
    _current = index;

    if (_ready[index] == true) {
      _pool[index]?.play();
    }

    // Delay initialization slightly to let the UI finish snapping
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && _current == index) {
        _initAround(index);
      }
    });

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _buildVerticalFeed(),
      tabletBody: _buildGridFeed(2),
      desktopBody: _buildGridFeed(4),
    );
  }

  Widget _buildVerticalFeed() {
    return PageView.builder(
      controller: _pageCtrl,
      scrollDirection: Axis.vertical,
      itemCount: _videosWithAds.length,
      onPageChanged: _onPageChanged,
      physics: const UltraFastScrollPhysics(),
      itemBuilder: (context, index) {
        final data = _videosWithAds[index];
        return RepaintBoundary(
          child: data.isAd
              ? FeedAdItem(
                  key: ValueKey('${widget.feedKey}_ad_$index'),
                  data: data,
                  controller: _pool[index],
                  isReady: _ready[index] ?? false,
                  isCurrent: index == _current,
                )
              : FeedVideoItem(
                  key: ValueKey('${widget.feedKey}_$index'),
                  data: data,
                  controller: _pool[index],
                  isReady: _ready[index] ?? false,
                  isCurrent: index == _current,
                ),
        );
      },
    );
  }

  Widget _buildGridFeed(int crossAxisCount) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int dynamicCount = (constraints.maxWidth / 300).floor().clamp(2, 6);

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: dynamicCount,
            childAspectRatio: 9 / 16,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _videosWithAds.length,
          itemBuilder: (context, index) {
            final data = _videosWithAds[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: data.isAd
                  ? FeedAdItem(
                      key: ValueKey('${widget.feedKey}_grid_ad_$index'),
                      data: data,
                      controller: _pool[index],
                      isReady: _ready[index] ?? false,
                      isCurrent: index == _current,
                    )
                  : FeedVideoItem(
                      key: ValueKey('${widget.feedKey}_grid_$index'),
                      data: data,
                      controller: _pool[index],
                      isReady: _ready[index] ?? false,
                      isCurrent: index == _current,
                      isGridMode: true,
                    ),
            );
          },
        );
      },
    );
  }
}
