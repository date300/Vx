import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Layout/theme_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final String userName;
  final String avatar;

  const ChatDetailScreen({
    super.key,
    required this.userName,
    required this.avatar,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {"text": "Hey! How are you?", "isMe": false, "time": "10:00 AM"},
    {"text": "I'm good, thanks! What about you?", "isMe": true, "time": "10:01 AM"},
    {"text": "Doing great! Loved your recent video on Vx! 🔥", "isMe": false, "time": "10:02 AM"},
    {"text": "Thank you so much! More content coming soon.", "isMe": true, "time": "10:05 AM"},
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        "text": _messageController.text.trim(),
        "isMe": true,
        "time": "Just now",
      });
      _messageController.clear();
    });
  }

  bool _isDark(BuildContext context) {
    final mode = context.read<ThemeProvider>().themeMode;
    if (mode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return mode == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final isDark = _isDark(context);

    final bgColor = isDark ? Colors.black : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5);
    final inputBgColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(isDark, titleColor, secondaryTextColor),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg["text"], msg["isMe"], msg["time"], isDark, titleColor);
              },
            ),
          ),
          _buildInputBar(isDark, titleColor, inputBgColor, bgColor),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, Color titleColor, Color secondaryTextColor) {
    return AppBar(
      backgroundColor: isDark ? Colors.black : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: titleColor.withValues(alpha: 0.1),
            child: Text(
              widget.avatar,
              style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userName,
                style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Active now",
                style: TextStyle(color: Colors.greenAccent, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(CupertinoIcons.phone, color: titleColor, size: 22),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(CupertinoIcons.videocam, color: titleColor, size: 26),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildChatBubble(String text, bool isMe, String time, bool isDark, Color titleColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isMe ? const LinearGradient(
                colors: [Color(0xFFFF4FB3), Color(0xFF9B4DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ) : null,
              color: isMe ? null : titleColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(color: isMe || isDark ? Colors.white : Colors.black, fontSize: 15),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(color: titleColor.withValues(alpha: 0.3), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isDark, Color titleColor, Color inputBgColor, Color bgColor) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding > 0 ? bottomPadding : 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: titleColor.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(shape: BoxShape.circle, color: titleColor.withValues(alpha: 0.1)),
            child: Icon(CupertinoIcons.camera_fill, color: titleColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: inputBgColor,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: titleColor, fontSize: 15),
                decoration: InputDecoration(
                  hintText: "Message...",
                  hintStyle: TextStyle(color: titleColor.withValues(alpha: 0.3), fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFF4FB3), Color(0xFF9B4DFF)],
                ),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
