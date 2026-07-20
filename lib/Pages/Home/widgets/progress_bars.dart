import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BottomBarSwitcher extends StatelessWidget {
  final ValueNotifier<bool>   isSeekingNotifier;
  final ValueNotifier<double> seekProgressNotifier;
  final VideoPlayerController ctrl;
  final bool isVisible;

  const BottomBarSwitcher({
    super.key,
    required this.isSeekingNotifier,
    required this.seekProgressNotifier,
    required this.ctrl,
    this.isVisible = true,
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
        return VideoProgressBar(controller: ctrl, isVisible: isVisible);
      },
    );
  }
}

class UltraSeekBar extends StatelessWidget {
  final double progress;
  const UltraSeekBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 18), // Match timestamp height
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 2.5,
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8 + 4), // Match GestureDetector height (20) / 2 + bottom padding
        ],
      ),
    );
  }
}

class VideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isVisible;
  const VideoProgressBar({super.key, required this.controller, this.isVisible = true});

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
  void didUpdateWidget(VideoProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  DateTime _lastUpdate = DateTime.now();

  void _rebuild() {
    if (!mounted || _dragging || !widget.isVisible) return;
    
    final now = DateTime.now();
    if (now.difference(_lastUpdate).inMilliseconds > 200) {
      setState(() {
        _lastUpdate = now;
      });
    }
  }

  String _fmtDur(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  double get _progress {
    if (_dragging) return _dragValue;
    final dur = widget.controller.value.duration.inMilliseconds;
    if (dur == 0) return 0;
    return widget.controller.value.position.inMilliseconds / dur;
  }

  @override
  Widget build(BuildContext context) {
    final current = _dragging 
        ? Duration(milliseconds: (widget.controller.value.duration.inMilliseconds * _dragValue).toInt())
        : widget.controller.value.position;
    final total = widget.controller.value.duration;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${_fmtDur(current)} / ${_fmtDur(total)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onHorizontalDragStart: (_) => setState(() => _dragging = true),
            onHorizontalDragUpdate: (d) {
              final w = MediaQuery.of(context).size.width;
              setState(() => _dragValue = (_dragValue + d.delta.dx / w).clamp(0.0, 1.0));
            },
            onHorizontalDragEnd: (_) {
              widget.controller.seekTo(widget.controller.value.duration * _dragValue);
              setState(() => _dragging = false);
            },
            child: Container(
              height: 20, // Increased touch area
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Track
                  Container(
                    height: 2.5,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Progress
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FractionallySizedBox(
                        widthFactor: _progress,
                        child: Container(
                          height: 2.5,
                          decoration: BoxDecoration(
                            color: Colors.pinkAccent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Thumb
                  if (_dragging)
                    Positioned(
                      left: (MediaQuery.of(context).size.width - 32) * _progress + 16 - 6,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4)
                          ],
                        ),
                      ),
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
