import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../Profile/profile_page.dart';
import '../sound_detail_page.dart';
import '../models/video_data.dart';

class RightActions extends StatelessWidget {
  final String              username;
  final String              avatarUrl;
  final SoundData?          soundData;
  final ValueNotifier<bool> likedNotifier;
  final ValueNotifier<int>  likeCountNotifier;
  final ValueNotifier<bool> savedNotifier;
  final int                 commentCount;
  final int                 shareCount;
  final bool                isFollowing;
  final bool                isSelf;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onFollow;

  const RightActions({
    super.key,
    required this.username,
    required this.avatarUrl,
    this.soundData,
    required this.likedNotifier,
    required this.likeCountNotifier,
    required this.savedNotifier,
    required this.commentCount,
    required this.shareCount,
    required this.isFollowing,
    this.isSelf = false,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
    required this.onFollow,
  });

  String _fmt(int n) {
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)}M".replaceAll('.0M', 'M');
    if (n >= 1000)    return "${(n / 1000).toStringAsFixed(1)}K".replaceAll('.0K', 'K');
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Like Button
        ValueListenableBuilder<bool>(
          valueListenable: likedNotifier,
          builder: (_, liked, __) => ValueListenableBuilder<int>(
            valueListenable: likeCountNotifier,
            builder: (_, count, __) => AnimatedActionBtn(
              icon:  liked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              label: _fmt(count),
              color: liked ? const Color(0xFFFE2C55) : Colors.white.withValues(alpha: 0.9),
              onTap: onLike,
              isPremium: true,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 2. Comment Button
        ActionBtn(
          icon: CupertinoIcons.chat_bubble_fill,
          label: _fmt(commentCount),
          onTap: onComment,
        ),

        const SizedBox(height: 10),

        // 3. Save Button
        ValueListenableBuilder<bool>(
          valueListenable: savedNotifier,
          builder: (_, saved, __) => AnimatedActionBtn(
            icon:  saved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
            label: "Save",
            color: saved ? const Color(0xFFFFE100) : Colors.white.withValues(alpha: 0.9),
            onTap: onSave,
            isPremium: true,
          ),
        ),

        const SizedBox(height: 10),

        // 4. Share Button
        ActionBtn(
          icon: CupertinoIcons.reply,
          label: _fmt(shareCount),
          onTap: onShare,
          flip: true,
        ),

        const SizedBox(height: 18),

        SpinningDisc(
          avatarUrl: soundData?.authorAvatar,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SoundDetailPage(
                  soundId: soundData?.id,
                  soundTitle: soundData?.title ?? "Original Sound",
                  username: soundData?.authorName ?? username,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class AnimatedActionBtn extends StatefulWidget {
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;
  final bool         isPremium;

  const AnimatedActionBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isPremium = false,
  });

  @override
  State<AnimatedActionBtn> createState() => _AnimatedActionBtnState();
}

class _AnimatedActionBtnState extends State<AnimatedActionBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.8,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _onTap() {
    _ctrl.reverse().then((_) => _ctrl.forward());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _ctrl,
        child: Column(
          children: [
            Icon(
              widget.icon, color: widget.color.withValues(alpha: 0.85), size: 28,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
            if (widget.label.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(widget.label, style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.bold,
                shadows: const [Shadow(color: Colors.black38, blurRadius: 2)],
              )),
            ],
          ],
        ),
      ),
    );
  }
}

class ActionBtn extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;
  final bool         flip;

  const ActionBtn({
    super.key,
    required this.icon, required this.label,
    required this.onTap, this.flip = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Transform.scale(
            scaleX: flip ? -1 : 1,
            child: Icon(
              icon, color: Colors.white.withValues(alpha: 0.85), size: 28,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(label, style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.bold,
              shadows: const [Shadow(color: Colors.black38, blurRadius: 2)],
            )),
          ],
        ],
      ),
    );
  }
}

class SpinningDisc extends StatefulWidget {
  final String? avatarUrl;
  final VoidCallback? onTap;
  const SpinningDisc({super.key, this.avatarUrl, this.onTap});

  @override
  State<SpinningDisc> createState() => _SpinningDiscState();
}

class _SpinningDiscState extends State<SpinningDisc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 5))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: RepaintBoundary(
        child: RotationTransition(
          turns: _ctrl,
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF2A2A2A), Color(0xFF111111)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white10, width: 1.2),
              boxShadow: [BoxShadow(color: Colors.pinkAccent.withValues(alpha: 0.2), blurRadius: 6)],
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 28, height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.avatarUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Icon(Icons.music_note_rounded, color: Colors.white60, size: 14),
                          errorWidget: (context, url, error) => const Icon(Icons.music_note_rounded, color: Colors.white60, size: 14),
                        )
                      : const Center(
                          child: Icon(Icons.music_note_rounded, color: Colors.white60, size: 14),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
