import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BottomBarSwitcher extends StatelessWidget {
  final ValueNotifier<bool>   isSeekingNotifier;
  final ValueNotifier<double> seekProgressNotifier;
  final VideoPlayerController ctrl;

  const BottomBarSwitcher({
    super.key,
    required this.isSeekingNotifier,
    required this.seekProgressNotifier,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isSeekingNotifier,
      builder: (_, isSeeking, __) {
        if (isSeeking) {
          return ValueListenableBuilder<double>(
            valueListenable: seekProgressNotifier,
            builder: (_, progress, __) => UltraSeekBar(progress: progress),
          );
        }
        return VideoProgressBar(controller: ctrl);
      },
    );
  }
}

class UltraSeekBar extends StatelessWidget {
  final double progress;
  const UltraSeekBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 4,
          color: Colors.white24,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: const ColoredBox(color: Colors.pinkAccent),
          ),
        ),
      ),
    );
  }
}

class VideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;
  const VideoProgressBar({super.key, required this.controller});

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
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
