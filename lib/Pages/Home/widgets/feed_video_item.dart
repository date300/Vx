import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Size;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/comment_sheet.dart';
import '../../Home/home_provider.dart';
import 'package:video_player/video_player.dart' hide Size;
import 'dart:ui' show Size;
import 'package:vx/Pages/Home/models/video_data.dart';
import 'package:vx/Pages/Home/home_provider.dart';
import 'package:vx/Api/Home/home_api.dart';
import 'package:vx/Pages/Profile/profile_provider.dart';
import 'package:vx/Services/native_service.dart';
import 'image_slideshow.dart';
import 'right_actions.dart';
import 'bottom_info.dart';
import 'package:vx/Pages/Home/widgets/comment_sheet.dart';
import 'share_sheet.dart';
import 'seek_overlay.dart';
import 'progress_bars.dart';
import 'package:vx/Pages/Profile/profile_page.dart';
import 'package:vx/Pages/Auth/auth_gate_page.dart';
import 'package:vx/Services/auth_service.dart';
import 'package:vx/Pages/Home/models/comment_item.dart';
import 'package:vx/Pages/Upload/widgets/vx_premium_loader.dart';
import 'package:vx/Layout/responsive_layout.dart';
import 'top_bar.dart';

class FeedVideoItem extends StatefulWidget {
  final VideoData data;
  final VideoPlayerController? controller;
  final bool isReady;
  final bool isCurrent;
  final bool isGridMode;

  final TabController? tabController;

  const FeedVideoItem({
    super.key,
    required this.data,
    required this.controller,
    required this.isReady,
    required this.isCurrent,
    this.isGridMode = false,
    this.tabController,
  });

  @override
  State<FeedVideoItem> createState() => _FeedVideoItemState();
}

class _FeedVideoItemState extends State<FeedVideoItem>
    with TickerProviderStateMixin {
  late final ValueNotifier<bool> _likedNotifier;
  late final ValueNotifier<int>  _likeCountNotifier;
  late final ValueNotifier<bool> _savedNotifier;
  late final ValueNotifier<bool>   _isSeekingNotifier;
  late final ValueNotifier<double> _seekProgressNotifier;
  late final ValueNotifier<bool>   _isPrivateNotifier;

  late final AnimationController _heartCtrl;
  late Animation<double>   _heartScale;
  late Animation<double>   _heartOpacity;

  late final AnimationController _commentAnimCtrl;
  late Animation<double>   _videoScale;
  late Animation<double>   _videoTranslate;
  late Animation<double>   _uiOpacity;

  late final AnimationController _jiggleCtrl;
  double _jiggleFactor = 1.0;

  Offset _tapPosition     = Offset.zero;
  bool   _isPlaying       = true;
  bool   _showHeart       = false;
  bool   _captionExpanded = false;
  bool   _isHolding       = false;
  bool   _isClearMode     = false;
  bool   _showDesktopComments = false;
  bool   _isMuted = false;
  double _volume = 1.0;
  double _zoomScale       = 1.0;
  late int _commentCount;
  late int _shareCount;
  int? _currentUserId;

  double? _calculatedWidth;
  double? _calculatedHeight;
  Size? _lastScreenSize;
  VideoPlayerController? _lastCtrl;

  double _dragStartX        = 0.0;
  double _seekStartProgress = 0.0;
  double _screenWidth       = 0.0;
  double _screenHeight      = 0.0;
  double _totalHorizontalDelta = 0.0;

  final List<CommentItem> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
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
      duration: const Duration(milliseconds: 300),
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

    _commentAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _videoScale = Tween<double>(begin: 1.0, end: 0.55).animate(
      CurvedAnimation(parent: _commentAnimCtrl, curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic)),
    );
    _uiOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _commentAnimCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );

    _jiggleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
      setState(() {
        // Frequency: 8Hz, Amplitude: 0.05, Decay: 5.0
        final jiggle = nativeService.calculateJigglePhysics(_jiggleCtrl.value, 8.0, 0.05, 5.0);
        _jiggleFactor = 1.0 + jiggle;
      });
    });

    if (widget.isCurrent) {
      _jiggleCtrl.forward(from: 0);
    }
  }

  void _updateDimensions() {
    final ctrl = widget.controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;

    final videoWidth = ctrl.value.size.width;
    final videoHeight = ctrl.value.size.height;

    // Fast synchronous check if dimensions are already correct
    final double targetWidth;
    final double targetHeight;
    
    // Dart-side implementation of dimension logic for speed
    final double videoRatio = videoWidth / videoHeight;
    final double containerRatio = _screenWidth / _screenHeight;

    if (videoRatio > containerRatio) {
      targetWidth = _screenWidth;
      targetHeight = _screenWidth / videoRatio;
    } else {
      targetHeight = _screenHeight;
      targetWidth = _screenHeight * videoRatio;
    }

    if (_calculatedWidth == targetWidth && _calculatedHeight == targetHeight && _lastCtrl == ctrl) {
      return;
    }

    if (mounted) {
      setState(() {
        _calculatedWidth = targetWidth;
        _calculatedHeight = targetHeight;
        _lastScreenSize = Size(_screenWidth, _screenHeight);
        _lastCtrl = ctrl;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    _videoTranslate = Tween<double>(begin: 0.0, end: -_screenHeight * 0.15).animate(
      CurvedAnimation(parent: _commentAnimCtrl, curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic)),
    );
  }

  @override
  void didUpdateWidget(FeedVideoItem old) {
    super.didUpdateWidget(old);
    if (widget.isCurrent && !old.isCurrent) {
      setState(() => _isPlaying = true);
      _jiggleCtrl.forward(from: 0);
    }
  }

  Widget _buildDesktopVolumeControl() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _toggleMute,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white10,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isMuted ? CupertinoIcons.volume_mute : CupertinoIcons.volume_up,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: _isMuted ? 0 : _volume,
                onChanged: _onVolumeChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    _commentAnimCtrl.dispose();
    _jiggleCtrl.dispose();
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

  void _onLongPress() {
    _showContextMenu();
  }

  Future<void> _loadCurrentUserId() async {
    _currentUserId = await AuthService.getUserId();
    if (mounted) setState(() {});
  }

  void _showContextMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final isSelf = _currentUserId != null && _currentUserId == widget.data.uploaderId;

    HapticFeedback.heavyImpact();
    widget.controller?.pause();

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
              if (isSelf) ...[
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
                    Navigator.pop(context);
                    _isPrivateNotifier.value = !_isPrivateNotifier.value;
                    HapticFeedback.lightImpact();
                  },
                ),
                _buildMenuOption(
                  icon: Icons.delete_outline_rounded,
                  title: "Delete video",
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation();
                  },
                ),
              ] else ...[
                _buildMenuOption(
                  icon: Icons.report_gmailerrorred_rounded,
                  title: "Report",
                  color: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    _showMockFeedback("Report submitted");
                  },
                ),
                _buildMenuOption(
                  icon: Icons.block_flipped,
                  title: "Block user",
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(context);
                    _showMockFeedback("User blocked");
                  },
                ),
                _buildMenuOption(
                  icon: Icons.sentiment_dissatisfied_rounded,
                  title: "Not interested",
                  color: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    _showMockFeedback("We will show fewer videos like this");
                  },
                ),
              ],
              const Divider(height: 30),
              _buildMenuOption(
                icon: Icons.download_rounded,
                title: "Save to device",
                color: textColor,
                onTap: () {
                  Navigator.pop(context);
                  _showMockFeedback("Starting download...");
                },
              ),
              _buildMenuOption(
                icon: Icons.bookmark_border_rounded,
                title: "Add to collection",
                color: textColor,
                onTap: () {
                  Navigator.pop(context);
                  _onSave();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    ).then((_) {
      if (mounted) {
        if (_isPlaying) widget.controller?.play();
      }
    });
  }

  void _showMockFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.black87,
    ));
  }

  void _onDoubleTapDown(TapDownDetails d) => _tapPosition = d.localPosition;

  void _onDoubleTap() {
    _performProtectedAction(() {
      HapticFeedback.mediumImpact();
      if (!_likedNotifier.value) {
        _likedNotifier.value = true;
        _likeCountNotifier.value = _likeCountNotifier.value + 1;
      }
      _popHeart();
    });
  }

  void _onFollow() {
    _performProtectedAction(() {
      HapticFeedback.selectionClick();
      context.read<HomeProvider>().toggleFollowByUsername(widget.data.username);
    });
  }

  void _onLike() {
    _performProtectedAction(() {
      HapticFeedback.lightImpact();
      final wasLiked = _likedNotifier.value;
      _likedNotifier.value = !wasLiked;
      _likeCountNotifier.value = _likeCountNotifier.value + (wasLiked ? -1 : 1);
      if (!wasLiked) {
        _tapPosition =
            Offset(_screenWidth / 2, MediaQuery.of(context).size.height / 2);
        _popHeart();
      }
    });
  }

  void _popHeart() {
    setState(() => _showHeart = true);
    _heartCtrl.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  void _onComment() {
    if (ResponsiveLayout.isDesktop(context)) {
      _performProtectedAction(() async {
        final provider = context.read<HomeProvider>();
        await provider.fetchComments(widget.data.id);
        if (mounted) {
          setState(() => _showDesktopComments = !_showDesktopComments);
        }
      });
      return;
    }
    _performProtectedAction(() async {
      final provider = context.read<HomeProvider>();
      final wasPlaying = _isPlaying;
      
      _commentAnimCtrl.forward();
      if (wasPlaying) widget.controller?.pause();

      // Fetch comments from API if not already loaded
      await provider.fetchComments(widget.data.id);
      
      if (!mounted) return;

      final currentComments = provider.getCommentsForVideo(widget.data.id) ?? [];

      showCommentPopup(
        context,
        comments: currentComments,
        commentCount: _commentCount,
        onPost: (text) async {
          final username = await AuthService.getUsername() ?? "you";
          await provider.addComment(widget.data.id, text, username);
          if (mounted) {
            setState(() {
              _commentCount = widget.data.comments;
            });
          }
        },
      ).then((_) {
        _commentAnimCtrl.reverse();
        if (wasPlaying && mounted) {
          widget.controller?.play();
          setState(() => _isPlaying = true);
        }
      });
    });
  }

  void _onShare() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareSheet(onMore: _showContextMenu),
    );
  }

  void _onSave() {
    _performProtectedAction(() {
      HapticFeedback.lightImpact();
      _savedNotifier.value = !_savedNotifier.value;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_savedNotifier.value
            ? "Saved to collection ?"
            : "Removed from collection"),
        duration: const Duration(milliseconds: 900),
        backgroundColor:
            _savedNotifier.value ? Colors.pinkAccent : Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      ));
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      widget.controller?.setVolume(_isMuted ? 0 : _volume);
    });
  }

  void _onVolumeChanged(double val) {
    setState(() {
      _volume = val;
      _isMuted = val == 0;
      widget.controller?.setVolume(_volume);
    });
  }

  void _performProtectedAction(VoidCallback action) async {
    final bool loggedIn = await AuthService.checkIsLoggedIn();
    if (loggedIn) {
      action();
    } else {
      if (!mounted) return;
      showAuthPopup(context);
    }
  }

  void _showEditCaptionDialog() {
    final controller = TextEditingController(text: widget.data.caption);
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Edit Caption",
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
      barrierDismissible: true,
      barrierLabel: "Delete Video",
      builder: (context) => AlertDialog(
        title: const Text("Delete Video?"),
        content: const Text("Are you sure you want to permanently delete this video?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final token = await AuthService.getToken();
              if (token == null) return;

              try {
                final response = await HomeApi.deleteVideo(widget.data.id, token);
                final data = json.decode(response.body);

                if (response.statusCode == 200 && data['status'] == true) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Video deleted successfully")));
                    
                    // Refresh feeds
                    context.read<HomeProvider>().fetchHomeFeed(refresh: true);
                    // If we are in profile, refresh profile videos too
                    try {
                      context.read<ProfileProvider>().fetchMyVideos(token);
                    } catch (_) {}
                    
                    // If we are in the viewer page, we might want to pop back to the grid
                    if (widget.isGridMode || Navigator.canPop(context)) {
                      // Navigator.pop(context); // Optional: depends on UX preference
                    }
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? "Failed to delete video")));
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
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
    _totalHorizontalDelta = 0.0;
    _seekStartProgress = ctrl.value.position.inMilliseconds / dur;
    _seekProgressNotifier.value = _seekStartProgress;
    _isSeekingNotifier.value = true;
    ctrl.pause();
  }

  void _onSeekDragUpdate(DragUpdateDetails d) {
    if (!_isSeekingNotifier.value) return;
    _totalHorizontalDelta += d.delta.dx;
    final delta = d.delta.dx / _screenWidth;
    const double sensitivity = 3.0;
    
    // Use C++ fastLerp for ultra-smooth seek progress updates
    final target = _seekProgressNotifier.value + delta * sensitivity;
    final newProg = nativeService.fastLerp(_seekProgressNotifier.value, target, 1.0).clamp(0.0, 1.0);

    _seekProgressNotifier.value = newProg;
  }

  void _onSeekDragEnd(DragEndDetails d) {
    final ctrl = widget.controller;
    if (ctrl == null || !_isSeekingNotifier.value) return;

    // Detect swipe (Left to Right)
    if (_totalHorizontalDelta > 100 && d.velocity.pixelsPerSecond.dx > 500) {
      _isSeekingNotifier.value = false;
      _navigateToProfile();
      if (_isPlaying) ctrl.play();
      return;
    }

    ctrl.seekTo(ctrl.value.duration * _seekProgressNotifier.value);
    _isSeekingNotifier.value = false;
    if (_isPlaying) ctrl.play();
  }

  void _navigateToProfile() {
    final wasPlaying = _isPlaying;
    if (wasPlaying) {
      widget.controller?.pause();
      setState(() => _isPlaying = false);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(username: widget.data.username),
      ),
    ).then((_) {
      if (wasPlaying && mounted) {
        widget.controller?.play();
        setState(() => _isPlaying = true);
      }
    });
  }

  void _updateClearMode(bool active) {
    if (_isClearMode == active) return;
    setState(() => _isClearMode = active);
    if (active) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _onScaleStart(ScaleStartDetails d) {
    if (d.pointerCount >= 2) {
      _updateClearMode(true);
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (d.verticalScale != 1.0) {
      if (!_isClearMode) _updateClearMode(true);
      setState(() => _zoomScale = d.verticalScale.clamp(1.0, 5.0));
    }
  }

  void _onScaleEnd(ScaleEndDetails d) {
    setState(() => _zoomScale = 1.0);
    _updateClearMode(false);
  }

  Widget _buildDesktopInfoSidebar() {
    return Container(
      width: 400,
      color: Colors.black,
      child: Column(
        children: [
          // Header: User Info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: widget.data.avatarUrl.isNotEmpty ? CachedNetworkImageProvider(widget.data.avatarUrl) : null,
                  backgroundColor: Colors.grey[800],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.username,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        widget.data.displayName,
                        style: const TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (widget.data.uploaderId != _currentUserId)
                  ElevatedButton(
                    onPressed: _onFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.data.isFollowing ? Colors.white10 : const Color(0xFFFE2C55),
                      foregroundColor: widget.data.isFollowing ? Colors.white : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(widget.data.isFollowing ? 'Following' : 'Follow'),
                  ),
              ],
            ),
          ),
          // Caption & Sound
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data.caption,
                  style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(CupertinoIcons.music_note_2, color: Colors.white70, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.data.sound,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10, height: 1),
          // Comments Section (Using existing CommentSheet widget)
          Expanded(
            child: CommentSheet(
              comments: context.watch<HomeProvider>().getCommentsForVideo(widget.data.id) ?? [],
              commentCount: _commentCount,
              onPost: (text) async {
                final username = await AuthService.getUsername() ?? "you";
                await context.read<HomeProvider>().addComment(widget.data.id, text, username);
                if (mounted) {
                  setState(() {
                    _commentCount = widget.data.comments;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGridMode) {
      return _buildGridItem();
    }
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final size      = MediaQuery.of(context).size;
    final ctrl      = widget.controller;
    final ready     = widget.isReady && ctrl != null;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    // Interaction Sidebar
    final interactionSidebar = AnimatedOpacity(
      opacity: _isClearMode ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: FadeTransition(
        opacity: _uiOpacity,
        child: RepaintBoundary(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDesktop && widget.tabController != null) ...[
                HomeTopBar(tabController: widget.tabController!, isSidebar: true),
                const SizedBox(height: 32),
                Container(width: 30, height: 1, color: Colors.white10),
                const SizedBox(height: 32),
              ],
              RightActions(
                username:          widget.data.username,
                avatarUrl:         widget.data.avatarUrl,
                likedNotifier:     _likedNotifier,
                likeCountNotifier: _likeCountNotifier,
                savedNotifier:     _savedNotifier,
                commentCount:      _commentCount,
                shareCount:        _shareCount,
                isFollowing:       widget.data.isFollowing,
                isSelf:            _currentUserId != null && _currentUserId == widget.data.uploaderId,
                onLike:    _onLike,
                onComment: _onComment,
                onShare:   _onShare,
                onSave:    _onSave,
                onFollow:  _onFollow,
              ),
              if (isDesktop) ...[
                const SizedBox(height: 20),
                _buildDesktopVolumeControl(),
              ],
            ],
          ),
        ),
      ),
    );

    // Video Layer
    final videoLayer = AnimatedBuilder(
      animation: _commentAnimCtrl,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _videoTranslate.value),
          child: Transform.scale(
            scale: _videoScale.value,
            alignment: Alignment.topCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_commentAnimCtrl.value * 20),
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: _togglePlay,
        onDoubleTapDown: _onDoubleTapDown,
        onDoubleTap: _onDoubleTap,
        onHorizontalDragStart: _onSeekDragStart,
        onHorizontalDragUpdate: _onSeekDragUpdate,
        onHorizontalDragEnd: _onSeekDragEnd,
        behavior: HitTestBehavior.opaque,
        child: Transform.scale(
        scale: _jiggleFactor,
        alignment: Alignment.center,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Colors.black),
            if (widget.data.isImage && widget.data.images != null)
              Transform.scale(
                scale: _zoomScale,
                child: ImageSlideshow(images: widget.data.images!),
              )
            else if (ready)
              RepaintBoundary(
                child: SizedBox.expand(
                  child: Center(
                    child: Builder(
                      builder: (context) {
                        if (kIsWeb) {
                          return Transform.scale(
                            scale: _zoomScale,
                            child: VideoPlayer(ctrl),
                          );
                        }
                        if (_calculatedWidth == null || _lastCtrl != ctrl) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) _updateDimensions();
                          });
                          if (_calculatedWidth == null) return const SizedBox.shrink();
                        }
                        return Transform.scale(
                          scale: _zoomScale,
                          child: SizedBox(
                            width: _calculatedWidth,
                            height: _calculatedHeight,
                            child: VideoPlayer(ctrl),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            else
              const Center(child: VxPremiumLoader(color: Colors.pinkAccent)),

            AnimatedOpacity(
              opacity: _isClearMode ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Stack(
                fit: StackFit.expand,
                children: [
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
                            Icon(Icons.pause_rounded, size: 72, color: Colors.white, shadows: [Shadow(color: Colors.black54, blurRadius: 20)]),
                            SizedBox(height: 12),
                            Text("Hold to pause", style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  if (!_isPlaying && !_isHolding)
                    const Center(
                      child: Icon(Icons.play_arrow_rounded, size: 72, color: Colors.white, shadows: [Shadow(color: Colors.black54, blurRadius: 20)]),
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
                            child: Transform.scale(scale: _heartScale.value, child: const Icon(Icons.favorite_rounded, size: 110, color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

    // Bottom Controls Group (Info + Progress)
    final bottomControls = Positioned(
      left: 0,
      right: isDesktop ? 0 : 0, // We'll use padding inside the Column for left/right
      bottom: bottomPad + 12, // Positioned above Nav Bar
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bottom Info (Caption, User)
          Padding(
            padding: EdgeInsets.only(
              left: 14,
              right: isDesktop ? 14 : 80,
            ),
            child: AnimatedOpacity(
              opacity: _isClearMode ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: FadeTransition(
                opacity: _uiOpacity,
                child: RepaintBoundary(
                  child: BottomInfo(
                    data: widget.data,
                    isFollowing: widget.data.isFollowing,
                    expanded: _captionExpanded,
                    onToggleCaption: () => setState(() => _captionExpanded = !_captionExpanded),
                    onFollow: _onFollow,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Progress Bar Block - Visible only when paused or seeking
          if (ready)
            ValueListenableBuilder<bool>(
              valueListenable: _isSeekingNotifier,
              builder: (context, isSeeking, child) {
                final bool shouldBeVisible = !_isPlaying || isSeeking;
                final bool isVisible = shouldBeVisible && !_isClearMode;

                return AnimatedOpacity(
                  opacity: isVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: FadeTransition(
                    opacity: _uiOpacity,
                    child: BottomBarSwitcher(
                      isSeekingNotifier: _isSeekingNotifier,
                      seekProgressNotifier: _seekProgressNotifier,
                      ctrl: ctrl,
                      isVisible: isVisible,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );

    final mainStack = Stack(
      fit: StackFit.expand,
      children: [
        videoLayer,
        bottomControls,
        if (!isDesktop)
          Positioned(
            right: 8,
            bottom: bottomPad + 8,
            child: interactionSidebar,
          ),
      ],
    );

    Widget content;
    if (isDesktop) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Center(
            child: SizedBox(
              width: 500,
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: mainStack,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: EdgeInsets.only(bottom: bottomPad + 20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(width: 60, child: interactionSidebar),
            ),
          ),
          if (_showDesktopComments) ...[
            const SizedBox(width: 24),
            _buildDesktopInfoSidebar(),
          ],
          const Spacer(),
        ],
      );
    } else {
      content = mainStack;
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyL): _onLike,
        const SingleActivator(LogicalKeyboardKey.keyM): _toggleMute,
      },
      child: Focus(
        autofocus: widget.isCurrent,
        child: Listener(
          behavior: HitTestBehavior.opaque,
          child: GestureDetector(
            onLongPress: _onLongPress,
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onScaleEnd: _onScaleEnd,
            behavior: HitTestBehavior.opaque,
            child: content,
          ),
        ),
      ),
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
            const Center(child: VxPremiumLoader(color: Colors.pinkAccent)),

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
