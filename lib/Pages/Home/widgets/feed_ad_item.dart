import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_data.dart';
import 'right_actions.dart';
import 'bottom_info.dart';

class FeedAdItem extends StatefulWidget {
  final VideoData data;
  final VideoPlayerController? controller;
  final bool isReady;
  final bool isCurrent;

  const FeedAdItem({
    super.key,
    required this.data,
    required this.controller,
    required this.isReady,
    required this.isCurrent,
  });

  @override
  State<FeedAdItem> createState() => _FeedAdItemState();
}

class _FeedAdItemState extends State<FeedAdItem> {
  bool _isPlaying = true;

  void _togglePlay() {
    final ctrl = widget.controller;
    if (ctrl == null || !widget.isReady) return;
    setState(() => _isPlaying = !_isPlaying);
    _isPlaying ? ctrl.play() : ctrl.pause();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
    final ready = widget.isReady && ctrl != null;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.black),
          if (ready)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: ctrl.value.size.width,
                  height: ctrl.value.size.height,
                  child: VideoPlayer(ctrl),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2)),

          // Ad Label (Top Left)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white24),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text(
                    "Sponsored",
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Info (Ad Caption)
          Positioned(
            left: 14, right: 80,
            bottom: bottomPad + 70, // Higher to make room for CTA
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.data.username, style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                )),
                const SizedBox(height: 6),
                Text(widget.data.caption, style: const TextStyle(
                  color: Colors.white, fontSize: 13.5, height: 1.45,
                  shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                )),
              ],
            ),
          ),

          // CTA Button (Call to Action)
          Positioned(
            left: 0, right: 0,
            bottom: bottomPad + 10,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GestureDetector(
                onTap: () {
                  // Link opening logic would go here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Opening: ${widget.data.adLink ?? 'Website'}")),
                  );
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 8, spreadRadius: 1),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.data.adCta ?? "Learn More",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Right Actions (Limited for Ads)
          Positioned(
            right: 8,
            bottom: bottomPad + 80,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white10,
                  child: Icon(Icons.ads_click, color: Colors.amber, size: 28),
                ),
                const SizedBox(height: 20),
                _AdActionIcon(icon: Icons.favorite_border_rounded, label: "Like"),
                const SizedBox(height: 20),
                _AdActionIcon(icon: Icons.share_rounded, label: "Share"),
              ],
            ),
          ),

          if (!_isPlaying)
            const Center(
              child: Icon(Icons.play_arrow_rounded, size: 72, color: Colors.white54),
            ),
        ],
      ),
    );
  }
}

class _AdActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _AdActionIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
