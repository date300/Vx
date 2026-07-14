import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SeekOverlayLayer extends StatelessWidget {
  final ValueNotifier<bool>   isSeekingNotifier;
  final ValueNotifier<double> seekProgressNotifier;
  final double                seekStartProgress;
  final bool                  ready;
  final VideoPlayerController? ctrl;

  const SeekOverlayLayer({
    super.key,
    required this.isSeekingNotifier,
    required this.seekProgressNotifier,
    required this.seekStartProgress,
    required this.ready,
    required this.ctrl,
  });

  static String _fmtDur(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isSeekingNotifier,
      builder: (_, isSeeking, __) {
        if (!isSeeking) return const SizedBox.shrink();
        return ValueListenableBuilder<double>(
          valueListenable: seekProgressNotifier,
          builder: (_, progress, __) {
            final size = MediaQuery.of(context).size;
            final barW = size.width * 0.7;
            return Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _fmtDur(ready ? ctrl!.value.duration * progress : Duration.zero),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 12)],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: barW,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: barW * progress,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.pinkAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            progress > seekStartProgress
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
            );
          },
        );
      },
    );
  }
}
