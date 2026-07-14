import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Layout/theme_provider.dart';
import 'chat_detail_screen.dart';

class _Message {
  final String name;
  final String avatar;
  final String lastMessage;
  final String time;
  final bool isUnread;
  final int unreadCount;

  const _Message({
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.time,
    this.isUnread = false,
    this.unreadCount = 0,
  });
}

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  static const List<_Message> _messages = [
    _Message(
      name: "Rafi Ahmed",
      avatar: "RA",
      lastMessage: "Bhai, onek sundor hoyeche!",
      time: "2m",
      isUnread: true,
      unreadCount: 3,
    ),
    _Message(
      name: "Nadia Islam",
      avatar: "NI",
      lastMessage: "Thanks for following! 🎉",
      time: "15m",
      isUnread: true,
      unreadCount: 1,
    ),
    _Message(
      name: "Tanvir Hossain",
      avatar: "TH",
      lastMessage: "Ei content ta share korte pari?",
      time: "1h",
      isUnread: false,
      unreadCount: 0,
    ),
    _Message(
      name: "Sadia Rahman",
      avatar: "SR",
      lastMessage: "Haha 😂 ekdom thik bolecho",
      time: "3h",
      isUnread: false,
      unreadCount: 0,
    ),
    _Message(
      name: "Farhan Kabir",
      avatar: "FK",
      lastMessage: "Next video kobe dibe?",
      time: "1d",
      isUnread: false,
      unreadCount: 0,
    ),
    _Message(
      name: "Mitu Akter",
      avatar: "MA",
      lastMessage: "Loved your last post 🔥🔥",
      time: "2d",
      isUnread: false,
      unreadCount: 0,
    ),
  ];

  // ── থিম helper ──
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
    final avatarBgColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.07);
    final avatarBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.10);
    final highlightColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);
    final onlineBorderColor = isDark ? Colors.black : Colors.white;
    final badgeBgColor = isDark ? Colors.white : Colors.black;
    final badgeTextColor = isDark ? Colors.black : Colors.white;
    final emptyIconColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.15);
    final emptyTitleColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.4);
    final emptySubtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.3);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Messages",
          style: TextStyle(
            color: titleColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              CupertinoIcons.pencil_ellipsis_rectangle,
              color: titleColor,
              size: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark, titleColor, highlightColor),
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(
                    emptyIconColor: emptyIconColor,
                    emptyTitleColor: emptyTitleColor,
                    emptySubtitleColor: emptySubtitleColor,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageTile(
                        context,
                        _messages[index],
                        isDark: isDark,
                        titleColor: titleColor,
                        avatarBgColor: avatarBgColor,
                        avatarBorderColor: avatarBorderColor,
                        highlightColor: highlightColor,
                        onlineBorderColor: onlineBorderColor,
                        badgeBgColor: badgeBgColor,
                        badgeTextColor: badgeTextColor,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, Color titleColor, Color highlightColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: highlightColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          style: TextStyle(color: titleColor),
          decoration: InputDecoration(
            hintText: "Search messages...",
            hintStyle: TextStyle(color: titleColor.withValues(alpha: 0.4), fontSize: 15),
            border: InputBorder.none,
            icon: Icon(CupertinoIcons.search, color: titleColor.withValues(alpha: 0.4), size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageTile(
    BuildContext context,
    _Message msg, {
    required bool isDark,
    required Color titleColor,
    required Color avatarBgColor,
    required Color avatarBorderColor,
    required Color highlightColor,
    required Color onlineBorderColor,
    required Color badgeBgColor,
    required Color badgeTextColor,
  }) {
    final nameColor = titleColor;
    final msgColor = msg.isUnread
        ? titleColor.withValues(alpha: 0.8)
        : titleColor.withValues(alpha: 0.4);
    final timeColor = msg.isUnread
        ? titleColor
        : titleColor.withValues(alpha: 0.35);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              userName: msg.name,
              avatar: msg.avatar,
            ),
          ),
        );
      },
      splashColor: Colors.transparent,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // ── Avatar ──
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avatarBgColor,
                    border: Border.all(
                      color: avatarBorderColor,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      msg.avatar,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // ── Online dot ──
                if (msg.isUnread)
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: onlineBorderColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // ── Name & Message ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.name,
                    style: TextStyle(
                      color: nameColor,
                      fontSize: 15,
                      fontWeight:
                          msg.isUnread ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    msg.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: msgColor,
                      fontSize: 13,
                      fontWeight:
                          msg.isUnread ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ── Time & Badge ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  msg.time,
                  style: TextStyle(color: timeColor, fontSize: 12),
                ),
                const SizedBox(height: 5),
                if (msg.unreadCount > 0)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        msg.unreadCount.toString(),
                        style: TextStyle(
                          color: badgeTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required Color emptyIconColor,
    required Color emptyTitleColor,
    required Color emptySubtitleColor,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.tray, color: emptyIconColor, size: 60),
          const SizedBox(height: 16),
          Text(
            "No messages yet",
            style: TextStyle(
              color: emptyTitleColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "When someone messages you,\nit will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: emptySubtitleColor,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
