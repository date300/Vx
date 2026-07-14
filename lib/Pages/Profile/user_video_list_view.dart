import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../Home/models/video_data.dart';
import '../Home/widgets/feed_video_item.dart';

class UserVideoListView extends StatefulWidget {
  final String username;
  final int initialIndex;

  const UserVideoListView({
    super.key,
    required this.username,
    required this.initialIndex,
  });

  @override
  State<UserVideoListView> createState() => _UserVideoListViewState();
}

class _UserVideoListViewState extends State<UserVideoListView> {
  late PageController _pageController;
  final List<VideoPlayerController> _controllers = [];
  final List<VideoData> _videos = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    
    // Mocking user videos
    for (int i = 0; i < 20; i++) {
      _videos.add(VideoData(
        url: i % 2 == 0 
            ? "https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-light-1282-preview.mp4"
            : "https://assets.mixkit.co/videos/preview/mixkit-tree-with-yellow-flowers-1173-preview.mp4",
        username: widget.username,
        displayName: widget.username,
        caption: "Sharing my amazing moments with Vx! Video #$i #viral",
        sound: "Original Sound - ${widget.username}",
        likes: 1200 + (i * 100),
        comments: 45 + i,
        shares: 12 + i,
      ));
      
      final controller = VideoPlayerController.networkUrl(Uri.parse(_videos[i].url));
      _controllers.add(controller);
      
      if (i == widget.initialIndex) {
        controller.initialize().then((_) {
          if (mounted) setState(() {});
          controller.play();
          controller.setLooping(true);
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int index) {
    for (int i = 0; i < _controllers.length; i++) {
      if (i == index) {
        if (!_controllers[i].value.isInitialized) {
          _controllers[i].initialize().then((_) {
            if (mounted) setState(() {});
            _controllers[i].play();
            _controllers[i].setLooping(true);
          });
        } else {
          _controllers[i].play();
        }
      } else {
        _controllers[i].pause();
      }
    }
  }

  Widget _buildVideoItem(int index) {
    return FeedVideoItem(
      data: _videos[index],
      controller: _controllers[index],
      isReady: _controllers[index].value.isInitialized,
      isCurrent: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.username == "Vx User" ? "My Videos" : "Videos",
          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _videos.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          return _buildVideoItem(index);
        },
      ),
    );
  }
}
