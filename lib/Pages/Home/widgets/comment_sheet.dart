import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../Services/native_service.dart';

class CommentItem {
  final String username;
  final String text;
  int likes;
  bool liked;
  CommentItem(this.username, this.text, this.likes, {this.liked = false});
}

Future<void> showCommentPopup(BuildContext context, {
  required List<CommentItem> comments,
  required int commentCount,
  required void Function(String) onPost,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Comments",
    barrierColor: Colors.black.withValues(alpha: 0.3),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
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
        offset: Offset(0, (1 - curvedValue) * MediaQuery.of(context).size.height * 0.78),
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

  @override
  void dispose() {
    _ctrl.dispose(); _focus.dispose(); _scroll.dispose();
    super.dispose();
  }

  void _post() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.selectionClick();
    widget.onPost(text);
    setState(() {});
    _ctrl.clear();
    _focus.unfocus();
    if (_scroll.hasClients) {
      _scroll.animateTo(0,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 38, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text("${widget.commentCount} comments",
                  style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded, color: Colors.white54, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white10, height: 1),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.comments.length,
              itemBuilder: (_, i) {
                final c = widget.comments[i];
                return _CommentTile(
                  item: c,
                  onLike: () => setState(() {
                    c.liked  = !c.liked;
                    c.likes += c.liked ? 1 : -1;
                  }),
                );
              },
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Padding(
            padding: EdgeInsets.only(
              left: 12, right: 12, top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.pinkAccent, Colors.deepPurpleAccent]),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focus,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _post(),
                      decoration: const InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _post,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.pinkAccent.withValues(alpha: 0.15),
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.pinkAccent, size: 26),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentItem item;
  final VoidCallback onLike;
  const _CommentTile({required this.item, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.white12,
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: const Icon(Icons.person, color: Colors.white54, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.username, style: const TextStyle(
                  color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(item.text, style: const TextStyle(
                  color: Colors.white, fontSize: 14, height: 1.4)),
                const SizedBox(height: 5),
                const Text("Reply",
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onLike,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      item.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      key: ValueKey(item.liked),
                      color: item.liked ? Colors.pinkAccent : Colors.white54,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.likes > 0 ? item.likes.toString() : "",
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
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
