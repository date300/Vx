import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/video_data.dart';
import '../../../Services/native_service.dart';
import 'image_slideshow.dart';
import 'right_actions.dart';
import 'bottom_info.dart';
import 'comment_sheet.dart';
import 'share_sheet.dart';
import 'seek_overlay.dart';
import 'progress_bars.dart';

class FeedVideoItem extends StatefulWidget {
  final VideoData data;
  final VideoPlayerController? controller;
  final bool isReady;
  final bool isCurrent;
  final bool isGridMode;

  const FeedVideoItem({
    super.key,
    required this.data,
    required this.controller,
    required this.isReady,
    required this.isCurrent,
    this.isGridMode = false,
  });

  @override
  State<FeedVideoItem> createState() => _FeedVideoItemState();
}

class _FeedVideoItemState extends State<FeedVideoItem>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<bool> _likedNotifier;
  late final ValueNotifier<int>  _likeCountNotifier;
  late final ValueNotifier<bool> _savedNotifier;
  late final ValueNotifier<bool>   _isSeekingNotifier;
  late final ValueNotifier<double> _seekProgressNotifier;
  late final ValueNotifier<bool>   _isPrivateNotifier;

  late final AnimationController _heartCtrl;
  late final Animation<double>   _heartScale;
  late final Animation<double>   _heartOpacity;

  Offset _tapPosition     = Offset.zero;
  bool   _isPlaying       = true;
  bool   _showHeart       = false;
  bool   _isFollowing     = false;
  bool   _captionExpanded = false;
  bool   _isHolding       = false;
  late int _commentCount;
  late int _shareCount;

  double _dragStartX        = 0.0;
  double _seekStartProgress = 0.0;
  double _screenWidth       = 0.0;

  final List<CommentItem> _comments = [];

  @override
  void initState() {
    super.initState();
    _likedNotifier        = ValueNotifier(false);
    _likeCountNotifier    = ValueNotifier(widget.data.likes);
    _savedNotifier        = ValueNotifier(false);
    _isSeekingNotifier    = ValueNotifier(false);
    _seekProgressNotifier = ValueNotifier(0.0);
    _isPrivateNotifier    = ValueNotifier(false);
    _commentCount         = widget.data.comments;
    _shareCount           = widget.data.shares;

    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _heartScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),  weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),  weight: 20),
    ]).animate(_heartCtrl);
    _heartOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_heartCtrl);

    _comments.addAll([
      CommentItem("@user_1",        "This is amazing! ?", 342),
      CommentItem("@flutter_dev",   "Smooth af bro ?",    120),
      CommentItem("@creative_soul", "Love this content ?",  87),
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenWidth = MediaQuery.of(context).size.width;
  }

  @override
  void didUpdateWidget(FeedVideoItem old) {
    super.didUpdateWidget(old);
    if (widget.isCurrent && !old.isCurrent) {
      setState(() => _isPlaying = true);
    }
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    _likedNotifier.dispose();
    _likeCountNotifier.dispose();
    _savedNotifier.dispose();
    _isSeekingNotifier.dispose();
    _seekProgressNotifier.dispose();
    _isPrivateNotifier.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final ctrl = widget.controller;
    if (ctrl == null || !widget.isReady) return;
    setState(() => _isPlaying = !_isPlaying);
    _isPlaying ? ctrl.play() : ctrl.pause();
  }

  void _onLongPressStart(LongPressStartDetails d) {
    final ctrl = widget.controller;
    if (ctrl == null || !widget.isReady) return;
    HapticFeedback.mediumImpact();
    setState(() => _isHolding = true);
    ctrl.pause();
  }

  void _onLongPressEnd(LongPressEndDetails d) {
    final ctrl = widget.controller;
    if (ctrl == null || !widget.isReady) return;
    setState(() => _isHolding = false);
    if (_isPlaying) ctrl.play();
  }

  void _onDoubleTapDown(TapDownDetails d) => _tapPosition = d.localPosition;

  void _onDoubleTap() {
    HapticFeedback.mediumImpact();
    if (!_likedNotifier.value) {
      _likedNotifier.value     = true;
      _likeCountNotifier.value = _likeCountNotifier.value + 1;
    }
    _popHeart();
  }

  void _onLike() {
    HapticFeedback.lightImpact();
    final wasLiked           = _likedNotifier.value;
    _likedNotifier.value     = !wasLiked;
    _likeCountNotifier.value = _likeCountNotifier.value + (wasLiked ? -1 : 1);
    if (!wasLiked) {
      _tapPosition = Offset(_screenWidth / 2, MediaQuery.of(context).size.height / 2);
      _popHeart();
    }
  }

  void _popHeart() {
    setState(() => _showHeart = true);
    _heartCtrl.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  void _onComment() {
    final wasPlaying = _isPlaying;
    widget.controller?.pause();
    showCommentPopup(
      context,
      comments: _comments,
      commentCount: _commentCount,
      onPost: (text) => setState(() {
        _comments.insert(0, CommentItem("@you", text, 0));
        _commentCount += 1;
      }),
    ).then((_) {
      if (wasPlaying && mounted) {
        widget.controller?.play();
        setState(() => _isPlaying = true);
      }
    });
  }

  void _onShare() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const ShareSheet(),
    );
  }

  void _onSave() {
    HapticFeedback.lightImpact();
    _savedNotifier.value = !_savedNotifier.value;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_savedNotifier.value ? "Saved to collection ?" : "Removed from collection"),
      duration: const Duration(milliseconds: 900),
      backgroundColor: _savedNotifier.value ? Colors.pinkAccent : Colors.grey[800],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
    ));
  }

  void _onFollow() {
    HapticFeedback.selectionClick();
    setState(() => _isFollowing = !_isFollowing);
  }

  void _showManageMenu() {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildMenuOption(
                    icon: Icons.edit_outlined,
                    title: "Edit caption",
                    color: textColor,
                    onTap: () {
                      Navigator.pop(context);
                      _showEditCaptionDialog();
                    },
                  ),
                  _buildMenuOption(
                    icon: _isPrivateNotifier.value ? Icons.public_rounded : Icons.lock_outline_rounded,
                    title: _isPrivateNotifier.value ? "Make Public" : "Make Private",
                    color: textColor,
                    onTap: () {
                      _isPrivateNotifier.value = !_isPrivateNotifier.value;
                      setModalState(() {});
                      HapticFeedback.lightImpact();
                    },
                  ),
                  _buildMenuOption(
                    icon: Icons.download_rounded,
                    title: "Save video",
                    color: textColor,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Divider(height: 30),
                  _buildMenuOption(
                    icon: Icons.delete_outline_rounded,
                    title: "Delete",
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation();
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditCaptionDialog() {
    final controller = TextEditingController(text: widget.data.caption);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Caption"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              // Mock save
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Caption updated")));
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Video?"),
        content: const Text("Are you sure you want to permanently delete this video?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              // Mock delete
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Video deleted")));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 26),
      title: Text(
        title,
        style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  void _onSeekDragStart(DragStartDetails d) {
    final ctrl = widget.controller;
    if (ctrl == null || !widget.isReady) return;
    final dur = ctrl.value.duration.inMilliseconds;
    if (dur == 0) return;
    _dragStartX = d.localPosition.dx;
    _seekStartProgress = ctrl.value.position.inMilliseconds / dur;
    _seekProgressNotifier.value = _seekStartProgress;
    _isSeekingNotifier.value = true;
    ctrl.pause();
  }

  void _onSeekDragUpdate(DragUpdateDetails d) {
    if (!_isSeekingNotifier.value) return;
    final delta = d.delta.dx / _screenWidth;
    const double sensitivity = 3.0;
    final newProg = (nativeService.fastLerp(_seekProgressNotifier.value, _seekProgressNotifier.value + delta * sensitivity, 1.0)).clamp(0.0, 1.0);
    _seekProgressNotifier.value = newProg;
  }

  void _onSeekDragEnd(DragEndDetails d) {
    final ctrl = widget.controller;
    if (ctrl == null || !_isSeekingNotifier.value) return;
    ctrl.seekTo(ctrl.value.duration * _seekProgressNotifier.value);
    _isSeekingNotifier.value = false;
    if (_isPlaying) ctrl.play();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGridMode) {
      return _buildGridItem();
    }
    final size      = MediaQuery.of(context).size;
    final ctrl      = widget.controller;
    final ready     = widget.isReady && ctrl != null;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: _togglePlay,
          onDoubleTapDown: _onDoubleTapDown,
          onDoubleTap: _onDoubleTap,
          onLongPressStart: _onLongPressStart,
          onLongPressEnd: _onLongPressEnd,
          onHorizontalDragStart: _onSeekDragStart,
          onHorizontalDragUpdate: _onSeekDragUpdate,
          onHorizontalDragEnd: _onSeekDragEnd,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Colors.black),
              if (widget.data.isImage && widget.data.images != null)
                ImageSlideshow(images: widget.data.images!)
              else if (ready)
                RepaintBoundary(
                  child: SizedBox.expand(
                    child: Center(
                      child: Builder(
                        builder: (context) {
                          final videoWidth = ctrl.value.size.width;
                          final videoHeight = ctrl.value.size.height;
                          final containerWidth = size.width;
                          final containerHeight = size.height;

                          final outWidthPtr = calloc<Double>();
                          final outHeightPtr = calloc<Double>();

                          try {
                            nativeService.calculateVideoDimensions(
                              videoWidth, videoHeight,
                              containerWidth, containerHeight,
                              outWidthPtr, outHeightPtr,
                            );

                            final finalWidth = outWidthPtr.value;
                            final finalHeight = outHeightPtr.value;

                            return SizedBox(
                              width: finalWidth,
                              height: finalHeight,
                              child: VideoPlayer(ctrl),
                            );
                          } finally {
                            calloc.free(outWidthPtr);
                            calloc.free(outHeightPtr);
                          }
                        },
                      ),
                    ),
                  ),
                )
              else
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.pinkAccent, strokeWidth: 2.5,
                  ),
                ),

              Positioned(
                bottom: 0, left: 0, right: 0,
                height: size.height * 0.60,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xE6000000), Color(0x80000000), Colors.transparent],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 0, left: 0, right: 0,
                height: size.height * 0.25,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x80000000), Colors.transparent],
                    ),
                  ),
                ),
              ),

              SeekOverlayLayer(
                isSeekingNotifier: _isSeekingNotifier,
                seekProgressNotifier: _seekProgressNotifier,
                seekStartProgress: _seekStartProgress,
                ready: ready,
                ctrl: ctrl,
              ),

              if (_isHolding)
                ColoredBox(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pause_rounded,
                          size: 72,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 20)],
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Hold to pause",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),

              if (!_isPlaying && !_isHolding)
                const Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 72,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 20)],
                  ),
                ),

              if (_showHeart)
                Positioned(
                  left: _tapPosition.dx - 55,
                  top:  _tapPosition.dy - 55,
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _heartCtrl,
                      builder: (_, __) => Opacity(
                        opacity: _heartOpacity.value,
                        child: Transform.scale(
                          scale: _heartScale.value,
                          child: const Icon(
                            Icons.favorite_rounded, size: 110,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        if (ready)
          Positioned(
            left: 0, right: 0,
            bottom: bottomPad,
            child: BottomBarSwitcher(
              isSeekingNotifier: _isSeekingNotifier,
              seekProgressNotifier: _seekProgressNotifier,
              ctrl: ctrl,
            ),
          ),

        Positioned(
          right: 8,
          bottom: bottomPad + 16,
          child: RepaintBoundary(
            child: RightActions(
              username:          widget.data.username,
              likedNotifier:     _likedNotifier,
              likeCountNotifier: _likeCountNotifier,
              savedNotifier:     _savedNotifier,
              commentCount:      _commentCount,
              shareCount:        _shareCount,
              isFollowing:       _isFollowing,
              onLike:    _onLike,
              onComment: _onComment,
              onShare:   _onShare,
              onSave:    _onSave,
              onFollow:  _onFollow,
              onMore:    widget.data.username == "Vx User" ? _showManageMenu : null,
            ),
          ),
        ),

        Positioned(
          left: 14, right: 80,
          bottom: bottomPad + 12,
          child: BottomInfo(
            data: widget.data,
            isFollowing: _isFollowing,
            expanded: _captionExpanded,
            onToggleCaption: () =>
                setState(() => _captionExpanded = !_captionExpanded),
            onFollow: _onFollow,
          ),
        ),
      ],
    );
  }

  Widget _buildGridItem() {
    final ctrl = widget.controller;
    final ready = widget.isReady && ctrl != null;
    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.black),
          if (ready)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: ctrl.value.size.width,
                height: ctrl.value.size.height,
                child: VideoPlayer(ctrl),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.pinkAccent, strokeWidth: 2)),

          Positioned(
            bottom: 0, left: 0, right: 0, height: 60,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 10, left: 10, right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '@${widget.data.username}',
                  style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.data.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70, fontSize: 11,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                ),
              ],
            ),
          ),

          if (!_isPlaying && ready)
            Center(
              child: Icon(
                Icons.play_arrow_rounded,
                size: 48,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }
}
