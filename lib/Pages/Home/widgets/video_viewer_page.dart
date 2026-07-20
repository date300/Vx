import 'package:flutter/material.dart';
import '../models/video_data.dart';
import 'video_feed_list.dart';

class VideoViewerPage extends StatefulWidget {
  final List<VideoData> videos;
  final int initialIndex;
  final String feedKey;

  const VideoViewerPage({
    super.key,
    required this.videos,
    this.initialIndex = 0,
    required this.feedKey,
  });

  @override
  State<VideoViewerPage> createState() => _VideoViewerPageState();
}

class _VideoViewerPageState extends State<VideoViewerPage> {
  final GlobalKey<VideoFeedListState> _feedKey = GlobalKey<VideoFeedListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: VideoFeedList(
        key: _feedKey,
        videos: widget.videos,
        feedKey: widget.feedKey,
        initialIndex: widget.initialIndex,
      ),
    );
  }
}
