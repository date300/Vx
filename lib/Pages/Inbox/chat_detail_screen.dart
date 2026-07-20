import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../Core/constants.dart' as constants;
import '../../Layout/theme_provider.dart';
import '../../Services/auth_service.dart';
import '../../Services/websocket_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String userName;
  final String avatar;
  final int targetId;

  const ChatDetailScreen({
    super.key,
    required this.userName,
    required this.avatar,
    required this.targetId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  StreamSubscription? _wsSubscription;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _listenToWS();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _listenToWS() {
    _wsSubscription = webSocketService.eventStream.listen((event) {
      if (event['type'] == 'chat_message') {
        final payload = event['payload'];
        if (payload['sender_id'] == widget.targetId) {
          setState(() {
            _messages.add({
              "id": payload['id'],
              "text": payload['text'],
              "isMe": false,
              "time": "Just now",
            });
          });
          _scrollToBottom();
        }
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _fetchMessages() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${constants.baseUrl}/inbox/messages/${widget.targetId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        
        setState(() {
          _messages = list.map((m) => {
            "id": m['id'],
            "text": m['text'],
            "isMe": m['sender_id'] != widget.targetId,
            "time": "Just now", 
          }).toList();
        });
        _scrollToBottom();
      }
    } catch (e) {}
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    final token = await AuthService.getToken();
    if (token == null) return;

    setState(() {
      _messages.add({
        "text": text,
        "isMe": true,
        "time": "Just now",
      });
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      await http.post(
        Uri.parse('${constants.baseUrl}/inbox/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'receiver_id': widget.targetId,
          'text': text,
        }),
      );
    } catch (e) {}
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
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
        icon: Icon(Icons.arrow_back_rounded, color: titleColor, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: titleColor.withValues(alpha: 0.1),
            backgroundImage: widget.avatar.isNotEmpty ? NetworkImage(widget.avatar) : null,
            child: widget.avatar.isEmpty
                ? Text(
                    widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : "?",
                    style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.bold),
                  )
                : null,
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
