import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Profile/user_profile_page.dart';

class RightActions extends StatelessWidget {
  final String              username;
  final ValueNotifier<bool> likedNotifier;
  final ValueNotifier<int>  likeCountNotifier;
  final ValueNotifier<bool> savedNotifier;
  final int                 commentCount;
  final int                 shareCount;
  final bool                isFollowing;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onFollow;
  final VoidCallback? onMore;

  const RightActions({
    super.key,
    required this.username,
    required this.likedNotifier,
    required this.likeCountNotifier,
    required this.savedNotifier,
    required this.commentCount,
    required this.shareCount,
    required this.isFollowing,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
    required this.onFollow,
    this.onMore,
  });

  String _fmt(int n) {
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)}M".replaceAll('.0M', 'M');
    if (n >= 1000)    return "${(n / 1000).toStringAsFixed(1)}K".replaceAll('.0K', 'K');
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final initial = username.length > 1 ? username[1].toUpperCase() : "U";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfilePage(username: username),
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.pinkAccent, Colors.deepPurpleAccent],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(color: Colors.pinkAccent.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 1),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(initial,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
              ),
              if (!isFollowing)
                Positioned(
                  bottom: -9,
                  child: Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        ValueListenableBuilder<bool>(
          valueListenable: likedNotifier,
          builder: (_, liked, __) => ValueListenableBuilder<int>(
            valueListenable: likeCountNotifier,
            builder: (_, count, __) => AnimatedActionBtn(
              icon:  liked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
              label: _fmt(count),
              color: liked ? Colors.redAccent : Colors.white,
              onTap: onLike,
            ),
          ),
        ),

        const SizedBox(height: 20),

        ActionBtn(
          icon: Icons.chat_bubble_outline_rounded,
          label: _fmt(commentCount),
          onTap: onComment,
        ),

        const SizedBox(height: 20),

        ValueListenableBuilder<bool>(
          valueListenable: savedNotifier,
          builder: (_, saved, __) => AnimatedActionBtn(
            icon:  saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            label: "Save",
            color: saved ? Colors.amberAccent : Colors.white,
            onTap: onSave,
            glowColor: saved ? Colors.yellow : null,
          ),
        ),

        const SizedBox(height: 20),

        ActionBtn(
          icon: Icons.share_outlined,
          label: _fmt(shareCount),
          onTap: onShare,
          flip: true,
        ),

        if (onMore != null) ...[
          const SizedBox(height: 20),
          ActionBtn(
            icon: Icons.more_horiz_rounded,
            label: "",
            onTap: onMore!,
          ),
        ],

        const SizedBox(height: 20),

        const SpinningDisc(),
      ],
    );
  }
}

class AnimatedActionBtn extends StatefulWidget {
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;
  final Color?       glowColor;

  const AnimatedActionBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.glowColor,
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
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.82,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: ScaleTransition(
          scale: _ctrl,
          child: Column(
            children: [
              Icon(
                widget.icon, color: widget.color, size: 36,
              ),
              if (widget.label.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(widget.label, style: TextStyle(
                  color: widget.color, fontSize: 12, fontWeight: FontWeight.w700,
                )),
              ],
            ],
          ),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Transform.scale(
              scaleX: flip ? -1 : 1,
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700,
              )),
            ],
          ],
        ),
      ),
    );
  }
}

class SpinningDisc extends StatefulWidget {
  const SpinningDisc({super.key});

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
    return RotationTransition(
      turns: _ctrl,
      child: Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF2A2A2A), Color(0xFF111111)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white24, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.pinkAccent.withValues(alpha: 0.3), blurRadius: 8)],
        ),
        child: const Center(
          child: SizedBox(
            width: 14, height: 14,
            child: DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white24),
              child: Center(
                child: Icon(Icons.music_note_rounded, color: Colors.white70, size: 9)),
            ),
          ),
        ),
      ),
    );
  }
}
