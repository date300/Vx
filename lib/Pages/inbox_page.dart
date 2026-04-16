import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ডামি মেসেজ মডেল
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

  // ডামি ডেটা — পরে API দিয়ে রিপ্লেস করো
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
      lastMessage: "Thanks for following! 🙌",
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
      lastMessage: "Haha 😄 ekdom thik bolecho",
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
      lastMessage: "Loved your last post ❤️",
      time: "2d",
      isUnread: false,
      unreadCount: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Inbox",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              CupertinoIcons.pencil_ellipsis_rectangle,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
      body: _messages.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageTile(_messages[index]);
              },
            ),
    );
  }

  Widget _buildMessageTile(_Message msg) {
    return InkWell(
      onTap: () {
        // TODO: মেসেজ ডিটেইলস পেজে নেভিগেট করো
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.white.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // অ্যাভাটার
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      msg.avatar,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // অনলাইন ইন্ডিকেটর (প্রথম ২টায় দেখাবে)
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
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // নাম ও মেসেজ
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.name,
                    style: TextStyle(
                      color: Colors.white,
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
                      color: msg.isUnread
                          ? Colors.white.withOpacity(0.8)
                          : Colors.white.withOpacity(0.4),
                      fontSize: 13,
                      fontWeight:
                          msg.isUnread ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // সময় ও আনরেড ব্যাজ
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  msg.time,
                  style: TextStyle(
                    color: msg.isUnread
                        ? Colors.white
                        : Colors.white.withOpacity(0.35),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                if (msg.unreadCount > 0)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        msg.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.black,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.tray,
            color: Colors.white.withOpacity(0.2),
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            "No messages yet",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "When someone messages you,\nit will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
