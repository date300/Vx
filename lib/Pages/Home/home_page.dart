import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'home_provider.dart';
import 'widgets/top_bar.dart';
import 'widgets/video_feed_list.dart';
import 'widgets/story_row.dart';
import '../Upload/widgets/vx_premium_loader.dart';

class HomeFeedPage extends StatefulWidget {
  final bool isVisible;
  final VoidCallback? onVisibilityChanged;
  const HomeFeedPage({super.key, this.isVisible = true, this.onVisibilityChanged});

  @override
  State<HomeFeedPage> createState() => HomeFeedPageState();
}

class HomeFeedPageState extends State<HomeFeedPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final GlobalKey<VideoFeedListState> _followingKey = GlobalKey<VideoFeedListState>();
  final GlobalKey<VideoFeedListState> _friendsKey = GlobalKey<VideoFeedListState>();
  final GlobalKey<VideoFeedListState> _newKey = GlobalKey<VideoFeedListState>();
  bool _isManuallyPaused = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().fetchHomeFeed();
    });
  }

  void pausePlayback() {
    _isManuallyPaused = true;
    _followingKey.currentState?.pauseVideo();
    _friendsKey.currentState?.pauseVideo();
    _newKey.currentState?.pauseVideo();
  }

  void resumePlayback() {
    _isManuallyPaused = false;
    if (widget.isVisible) {
      _followingKey.currentState?.resumeVideo();
      _friendsKey.currentState?.resumeVideo();
      _newKey.currentState?.resumeVideo();
    }
  }

  @override
  void didUpdateWidget(HomeFeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible && !_isManuallyPaused) {
      if (widget.isVisible) {
        _followingKey.currentState?.resumeVideo();
        _friendsKey.currentState?.resumeVideo();
        _newKey.currentState?.resumeVideo();
      } else {
        _followingKey.currentState?.pauseVideo();
        _friendsKey.currentState?.pauseVideo();
        _newKey.currentState?.pauseVideo();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  TabController get tabController => _tabController;

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final videos = homeProvider.videos;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (homeProvider.isLoading && videos.isEmpty)
            const Center(child: VxPremiumLoader(color: Colors.pinkAccent))
          else if (homeProvider.errorMessage != null && videos.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white54, size: 48),
                  const SizedBox(height: 16),
                  Text(homeProvider.errorMessage!, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => homeProvider.fetchHomeFeed(),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            )
          else
            TabBarView(
              controller: _tabController,
              children: [
                VideoFeedList(
                  key: _followingKey,
                  videos: homeProvider.followingVideos, 
                  feedKey: 'following',
                  tabController: _tabController,
                  refreshCounter: homeProvider.refreshCounter,
                ),
                VideoFeedList(
                  key: _friendsKey,
                  videos: homeProvider.friendsVideos,
                  feedKey: 'friends',
                  tabController: _tabController,
                  refreshCounter: homeProvider.refreshCounter,
                ),
                VideoFeedList(
                  key: _newKey,
                  videos: videos,
                  feedKey: 'new',
                  tabController: _tabController,
                  refreshCounter: homeProvider.refreshCounter,
                ),
              ],
            ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 0,
            right: 0,
            child: StoryRow(stories: homeProvider.stories),
          ),
          HomeTopBar(tabController: _tabController),
        ],
      ),
    );
  }
}
