import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../Layout/theme_provider.dart';
import '../../../Services/native_service.dart';
import '../../Profile/profile_page.dart';
import 'package:vx/Pages/Home/models/comment_item.dart';

Future<void> showCommentPopup(BuildContext context, {
  required List<CommentItem> comments,
  required int commentCount,
  required void Function(String) onPost,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Comments",
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),
            CommentSheet(
              comments: comments,
              commentCount: commentCount,
              onPost: onPost,
              isPopup: true,
            ),
          ],
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedValue = nativeService.calculateSheetEasing(animation.value, 1.0);
      return Transform.translate(
        offset: Offset(0, (1 - curvedValue) * MediaQuery.of(context).size.height * 0.75),
        child: child,
      );
    },
  );
}

class CommentSheet extends StatefulWidget {
  final List<CommentItem>    comments;
  final int                   commentCount;
  final void Function(String) onPost;
  final bool                  isPopup;

  const CommentSheet({
    super.key,
    required this.comments, required this.commentCount, required this.onPost,
    this.isPopup = false,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _ctrl   = TextEditingController();
  final FocusNode             _focus  = FocusNode();
  final ScrollController      _scroll = ScrollController();

  final List<String> _emojis = ["❤️", "😂", "🔥", "😍", "👏", "🙌", "✨", "😮", "💯", "😭", "💀", "✅"];

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose(); _focus.dispose(); _scroll.dispose();
    super.dispose();
  }

  void _post() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.mediumImpact();
    widget.onPost(text);
    _ctrl.clear();
    _focus.unfocus();
    if (_scroll.hasClients) {
      _scroll.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeOutQuart);
    }
  }

  void _addEmoji(String e) {
    HapticFeedback.lightImpact();
    final text = _ctrl.text;
    final pos = _ctrl.selection.baseOffset;
    if (pos >= 0) {
      _ctrl.text = text.substring(0, pos) + e + text.substring(pos);
      _ctrl.selection = TextSelection.fromPosition(TextPosition(offset: pos + e.length));
    } else {
      _ctrl.text += e;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final themeProvider = context.watch<ThemeProvider>();
    
    bool isDark = themeProvider.themeMode == ThemeMode.dark;
    if (themeProvider.themeMode == ThemeMode.system) {
      isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    }

    final bgColor = isDark 
        ? const Color(0xFF0F0F0F).withValues(alpha: 0.92) 
        : Colors.white.withValues(alpha: 0.94);
    final titleColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.white70 : Colors.black54;
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.07);
    final inputBarBg = isDark ? const Color(0xFF161616).withValues(alpha: 0.8) : Colors.grey[50]!.withValues(alpha: 0.8);
    final inputFieldBg = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04);
    final hintColor = isDark ? Colors.white30 : Colors.black38;
    final textColor = isDark ? Colors.white : Colors.black87;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05), width: 0.5)
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.1), 
                  borderRadius: BorderRadius.circular(2.5)),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text("${widget.commentCount} comments",
                      style: TextStyle(
                        color: titleColor, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.2)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, 
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04)
                        ),
                        child: Icon(CupertinoIcons.xmark, color: iconColor, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.comments.length,
                  itemBuilder: (_, i) {
                    final c = widget.comments[i];
                    return _CommentTile(
                      isDark: isDark,
                      item: c,
                      onLike: () => setState(() {
                        c.liked  = !c.liked;
                        c.likes += c.liked ? 1 : -1;
                        HapticFeedback.lightImpact();
                      }),
                    );
                  },
                ),
              ),
              
              // Emoji Quick Bar
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: inputBarBg,
                      border: Border(top: BorderSide(color: dividerColor, width: 0.5)),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      itemCount: _emojis.length,
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => _addEmoji(_emojis[i]),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.center,
                          child: Text(_emojis[i], style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.only(
                  left: 16, right: 16, top: 12,
                  bottom: bottomInset > 0 ? bottomInset + 12 : MediaQuery.of(context).padding.bottom + 12,
                ),
                decoration: BoxDecoration(
                  color: inputBarBg,
                  border: Border(top: BorderSide(color: dividerColor, width: 0.5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: inputFieldBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: dividerColor, width: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _ctrl,
                          focusNode: _focus,
                          maxLines: 5,
                          minLines: 1,
                          style: TextStyle(color: textColor, fontSize: 15),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _post(),
                          decoration: InputDecoration(
                            hintText: "Add a comment...",
                            hintStyle: TextStyle(color: hintColor, fontSize: 15),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _post,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _ctrl.text.isNotEmpty 
                            ? const LinearGradient(colors: [Color(0xFFFE2C55), Color(0xFFFF4FB3)]) 
                            : null,
                          color: _ctrl.text.isNotEmpty ? null : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                        ),
                        child: Icon(
                          CupertinoIcons.arrow_up, 
                          color: _ctrl.text.isNotEmpty ? Colors.white : (isDark ? Colors.white24 : Colors.black26), 
                          size: 20
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
  }
}

class _CommentTile extends StatelessWidget {
  final CommentItem item;
  final VoidCallback onLike;
  final bool isDark;
  
  const _CommentTile({
    required this.item, 
    required this.onLike,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final usernameColor = isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black87.withValues(alpha: 0.7);
    final commentTextColor = isDark ? Colors.white : Colors.black87;
    final metaColor = isDark ? Colors.white38 : Colors.black45;

    void _toProfile(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(username: item.username),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _toProfile(context),
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
              ),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                child: Text(
                  item.username.length > 1 ? item.username[1].toUpperCase() : "U", 
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54, 
                    fontSize: 13, 
                    fontWeight: FontWeight.w900
                  )
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _toProfile(context),
                  child: Text(item.username, style: TextStyle(
                    color: usernameColor, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 4),
                Text(item.text, style: TextStyle(
                  color: commentTextColor, fontSize: 14.5, height: 1.5, letterSpacing: 0.1)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text("Just now", style: TextStyle(color: metaColor, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 24),
                    Text("Reply", style: TextStyle(color: metaColor, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onLike,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    item.liked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                    key: ValueKey(item.liked),
                    color: item.liked ? const Color(0xFFFE2C55) : iconColor(context, isDark),
                    size: 20,
                  ),
                ),
                if (item.likes > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.likes.toString(),
                    style: TextStyle(color: metaColor, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color iconColor(BuildContext context, bool isDark) {
    return isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.25);
  }
}
