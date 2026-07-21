import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_data.dart';

class StoryViewer extends StatefulWidget {
  final List<VideoData> stories;
  final int initialIndex;
  const StoryViewer({super.key, required this.stories, required this.initialIndex});

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  late PageController _pageController;
  int _currentIndex = 0;
  VideoPlayerController? _videoController;
  Timer? _timer;
  double _progress = 0.0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _startStory();
  }

  void _startStory() {
    _timer?.cancel();
    _videoController?.dispose();
    _videoController = null;
    _progress = 0.0;

    final story = widget.stories[_currentIndex];
    if (!story.isImage) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(story.url))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController!.play();
            _startTimer(duration: _videoController!.value.duration);
          }
        });
    } else {
      _startTimer(duration: const Duration(seconds: 5));
    }
  }

  void _startTimer({required Duration duration}) {
    const tick = Duration(milliseconds: 50);
    final totalTicks = duration.inMilliseconds / tick.inMilliseconds;
    
    _timer = Timer.periodic(tick, (t) {
      if (!_isPaused) {
        setState(() {
          _progress += 1.0 / totalTicks;
        });

        if (_progress >= 1.0) {
          _nextStory();
        }
      }
    });
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      _currentIndex++;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startStory();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startStory();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPressStart: (_) => setState(() => _isPaused = true),
        onLongPressEnd: (_) => setState(() => _isPaused = false),
        onTapDown: (details) {
          final x = details.globalPosition.dx;
          if (x < MediaQuery.of(context).size.width / 3) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.stories.length,
              itemBuilder: (context, index) {
                final story = widget.stories[index];
                if (story.isImage) {
                  return Image.network(story.url, fit: BoxFit.contain);
                } else {
                  if (_videoController != null && _videoController!.value.isInitialized) {
                    return Center(
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                }
              },
            ),
            // Progress Bar
            Positioned(
              top: 50,
              left: 10,
              right: 10,
              child: Row(
                children: List.generate(widget.stories.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: LinearProgressIndicator(
                        value: index == _currentIndex
                            ? _progress
                            : (index < _currentIndex ? 1.0 : 0.0),
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 2,
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Top User Info
            Positioned(
              top: 70,
              left: 15,
              right: 15,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(widget.stories[_currentIndex].avatarUrl),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.stories[_currentIndex].username,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
