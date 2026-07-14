import 'package:flutter/material.dart';
import '../../Profile/user_profile_page.dart';
import '../models/video_data.dart';

class BottomInfo extends StatelessWidget {
  final VideoData    data;
  final bool         isFollowing;
  final bool         expanded;
  final VoidCallback onToggleCaption;
  final VoidCallback onFollow;

  const BottomInfo({
    super.key,
    required this.data,
    required this.isFollowing,
    required this.expanded,
    required this.onToggleCaption,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.2),
            Colors.black.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(username: data.username),
                ),
              );
            },
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    data.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                      shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.verified,
                  color: Colors.blueAccent,
                  size: 16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onToggleCaption,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: RichText(
                maxLines: expanded ? null : 2,
                overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14, // Slightly increased for modern look
                    height: 1.45,
                    fontFamily: 'Roboto', // Modern font feel
                    shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                  ),
                  children: [
                    TextSpan(text: data.caption),
                    if (!expanded)
                      const TextSpan(
                        text: " ...more",
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SoundTicker(sound: data.sound),
        ],
      ),
    );
  }
}

class SoundTicker extends StatefulWidget {
  final String sound;
  const SoundTicker({super.key, required this.sound});

  @override
  State<SoundTicker> createState() => _SoundTickerState();
}

class _SoundTickerState extends State<SoundTicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 8))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final text = "${widget.sound}          ${widget.sound}";
    return Row(
      children: [
        const Icon(Icons.music_note_rounded, color: Colors.white70, size: 13),
        const SizedBox(width: 5),
        Expanded(
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (ctx, _) {
                final w      = ctx.size?.width ?? 200;
                final offset = -_ctrl.value * w;
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                    maxLines: 1, softWrap: false,
                    overflow: TextOverflow.visible,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
