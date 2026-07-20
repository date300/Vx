import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'video_publish_screen.dart';
import '../../Services/haptic_service.dart';
import '../../Services/video_editor_service.dart';
import 'widgets/vx_premium_loader.dart';

class VideoPreviewScreen extends StatefulWidget {
  final String videoPath;

  const VideoPreviewScreen({super.key, required this.videoPath});

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late VideoPlayerController _controller;
  double _startValue = 0.0;
  double _endValue = 1.0;
  bool _isTrimming = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _endValue = _controller.value.duration.inMilliseconds.toDouble();
        });
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full Screen Video Preview
          if (_controller.value.isInitialized)
            GestureDetector(
              onTap: () {
                setState(() {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                });
              },
              child: SizedBox.expand(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
            )
          else
            const Center(child: VxPremiumLoader(color: Colors.white)),

          // Premium Top Back Button
          Positioned(
            top: 60,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(CupertinoIcons.back, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          ),

          // Side Actions (Premium Glassmorphism Pill)
          Positioned(
            right: 15,
            top: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      _buildSideIcon(CupertinoIcons.textformat, "Text"),
                      _buildSideIcon(CupertinoIcons.smiley, "Stickers"),
                      _buildSideIcon(CupertinoIcons.wand_stars, "Effects"),
                      _buildSideIcon(CupertinoIcons.circle_grid_hex_fill, "Filters"),
                      _buildSideIcon(CupertinoIcons.music_note, "Audio"),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Modern Trimming & Controls Overlay
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trimming UI
                if (_controller.value.isInitialized)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(Duration(milliseconds: _startValue.toInt())),
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                  const Text("TRIM VIDEO", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                                  Text(
                                    _formatDuration(Duration(milliseconds: _endValue.toInt())),
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              RangeSlider(
                                values: RangeValues(_startValue, _endValue),
                                min: 0.0,
                                max: _controller.value.duration.inMilliseconds.toDouble(),
                                activeColor: const Color(0xFFFE2C55),
                                inactiveColor: Colors.white12,
                                onChanged: (values) {
                                  setState(() {
                                    _startValue = values.start;
                                    _endValue = values.end;
                                  });
                                  _controller.seekTo(Duration(milliseconds: _startValue.toInt()));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Bottom Bar with Next Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildBottomTool(CupertinoIcons.scissors, "Edit"),
                      const SizedBox(width: 24),
                      _buildBottomTool(CupertinoIcons.speaker_2_fill, "Volume"),
                      const Spacer(),
                      // Next Button with Brand Gradient
                      GestureDetector(
                        onTap: _isTrimming ? null : _handleNext,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFE2C55), Color(0xFFFF4FB3)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFE2C55).withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: _isTrimming
                              ? const SizedBox(width: 20, height: 20, child: VxPremiumLoader(size: 2, color: Colors.white))
                              : const Text(
                                  "Next",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _handleNext() async {
    HapticService.impactMedium();
    String finalPath = widget.videoPath;
    if (_startValue > 0 || _endValue < _controller.value.duration.inMilliseconds) {
      setState(() => _isTrimming = true);
      final trimmedPath = await VideoEditorService.trimVideo(
        inputPath: widget.videoPath,
        startTime: _startValue / 1000.0,
        duration: (_endValue - _startValue) / 1000.0,
      );
      setState(() => _isTrimming = false);
      if (trimmedPath != null) finalPath = trimmedPath;
    }
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPublishScreen(videoPath: finalPath)));
    }
  }

  Widget _buildSideIcon(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildBottomTool(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
