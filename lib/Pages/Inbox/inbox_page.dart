import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../Core/constants.dart' as constants;
import '../../Layout/theme_provider.dart';
import '../../Services/auth_service.dart';
import '../../Services/websocket_service.dart';
import '../../Services/notification_service.dart';
import '../../widgets/vx_premium_refresher.dart';
import 'chat_detail_screen.dart';

class _Conversation {
  final int id;
  final String name;
  final String avatar;
  final String lastMessage;
  final String time;
  final bool isUnread;
  final int targetId;

  const _Conversation({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.time,
    this.isUnread = false,
    required this.targetId,
  });
}

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  List<_Conversation> _conversations = [];
  bool _isLoading = true;
  StreamSubscription? _wsSubscription;
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ["All", "Unread", "Groups", "Requests"];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _listenToWS();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationService>().fetchNotifications();
      context.read<NotificationService>().fetchUnreadCount();
    });
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }

  void _listenToWS() {
    _wsSubscription = webSocketService.eventStream.listen((event) {
      if (event['type'] == 'chat_message') {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    final token = await AuthService.getToken();
    int? myId = await AuthService.getUserId();

    if (token == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Fallback: If userId is missing from prefs, fetch it from profile API
    if (myId == null) {
      try {
        final profileRes = await http.get(
          Uri.parse('${constants.baseUrl}/user/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
        );
        if (profileRes.statusCode == 200) {
          final profileData = jsonDecode(profileRes.body);
          myId = profileData['data']['id'];
          // Save it for next time
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', myId!);
        }
      } catch (e) {
        debugPrint("Profile Fetch Error in Inbox: $e");
      }
    }

    if (myId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${constants.baseUrl}/inbox/conversations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        
        if (mounted) {
          setState(() {
            _conversations = list.map((c) {
              final otherUser = (c['user1_id'] == myId) ? c['user2'] : c['user1'];
              if (otherUser == null) {
                 return _Conversation(
                  id: c['id'],
                  name: 'Deleted User',
                  avatar: '',
                  lastMessage: c['last_msg'] ?? '',
                  time: 'Just now',
                  targetId: 0,
                );
              }
              return _Conversation(
                id: c['id'],
                name: otherUser['nickname'] ?? otherUser['username'] ?? 'User',
                avatar: otherUser['avatar_url'] ?? '',
                lastMessage: c['last_msg'] ?? '',
                time: 'Just now', 
                targetId: otherUser['id'] ?? 0,
              );
            }).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Inbox Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
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
    final highlightColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);
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
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: highlightColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(CupertinoIcons.pencil_ellipsis_rectangle, color: titleColor, size: 22),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark, titleColor, highlightColor),
          Expanded(
            child: VxPremiumRefresher(
              onRefresh: () async {
                await _fetchData();
                if (mounted) {
                  await context.read<NotificationService>().fetchNotifications();
                }
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategoryCarousel(isDark),
                        _buildActivityRow(isDark, titleColor),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Text(
                            "Direct Messages",
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: Color(0xFFFE2C55))),
                    )
                  else if (_conversations.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(
                        emptyIconColor: emptyIconColor,
                        emptyTitleColor: emptyTitleColor,
                        emptySubtitleColor: emptySubtitleColor,
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildMessageTile(
                            context,
                            _conversations[index],
                            isDark: isDark,
                            titleColor: titleColor,
                          );
                        },
                        childCount: _conversations.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
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
        height: 48,
        decoration: BoxDecoration(
          color: highlightColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: titleColor.withValues(alpha: 0.05), width: 1),
        ),
        child: TextField(
          style: TextStyle(color: titleColor),
          decoration: InputDecoration(
            hintText: "Search messages...",
            hintStyle: TextStyle(color: titleColor.withValues(alpha: 0.4), fontSize: 15),
            border: InputBorder.none,
            prefixIcon: Icon(CupertinoIcons.search, color: titleColor.withValues(alpha: 0.4), size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCarousel(bool isDark) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFE2C55) : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityRow(bool isDark, Color titleColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActivityItem(
            label: "Activity",
            icon: CupertinoIcons.bell_fill,
            gradient: const LinearGradient(colors: [Color(0xFFFF4FB3), Color(0xFFFE2C55)]),
            onTap: () => _showNotificationsBottomSheet(context),
          ),
          _buildActivityItem(
            label: "Likes",
            icon: CupertinoIcons.heart_fill,
            gradient: const LinearGradient(colors: [Color(0xFFFF8570), Color(0xFFF7215D)]),
            onTap: () {},
          ),
          _buildActivityItem(
            label: "Comments",
            icon: CupertinoIcons.chat_bubble_fill,
            gradient: const LinearGradient(colors: [Color(0xFF5AC8FA), Color(0xFF007AFF)]),
            onTap: () {},
          ),
          _buildActivityItem(
            label: "Requests",
            icon: CupertinoIcons.person_2_fill,
            gradient: const LinearGradient(colors: [Color(0xFFAF52DE), Color(0xFF5856D6)]),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.last.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(
    BuildContext context,
    _Conversation msg, {
    required bool isDark,
    required Color titleColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                userName: msg.name,
                avatar: msg.avatar,
                targetId: msg.targetId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFE2C55).withValues(alpha: 0.2), width: 2),
                      image: msg.avatar.isNotEmpty ? DecorationImage(image: NetworkImage(msg.avatar), fit: BoxFit.cover) : null,
                    ),
                    child: msg.avatar.isEmpty ? Center(child: Text(msg.name[0], style: TextStyle(color: titleColor, fontSize: 22, fontWeight: FontWeight.w900))) : null,
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CD964),
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? Colors.black : Colors.white, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          msg.name,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          msg.time,
                          style: TextStyle(color: titleColor.withValues(alpha: 0.3), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      msg.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: titleColor.withValues(alpha: 0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
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

  void _showNotificationsBottomSheet(BuildContext context) {
    final isDark = _isDark(context);
    final bgColor = isDark ? const Color(0xFF0D0D0D) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 25, 16, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "All Activity",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                        letterSpacing: -0.6,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<NotificationService>().markAllAsRead();
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFFFE2C55)),
                      child: const Text("Mark as read", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<NotificationService>(
                  builder: (context, ns, child) {
                    if (ns.isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFFE2C55)));
                    if (ns.notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.bell_slash, size: 70, color: titleColor.withValues(alpha: 0.1)),
                            const SizedBox(height: 16),
                            Text("No activity yet", style: TextStyle(color: titleColor.withValues(alpha: 0.4), fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      itemCount: ns.notifications.length,
                      itemBuilder: (context, index) {
                        final n = ns.notifications[index];
                        return _buildNotificationTile(n, isDark, titleColor);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationTile(VxNotification n, bool isDark, Color titleColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: n.isRead ? Colors.transparent : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFE2C55).withValues(alpha: 0.3), width: 2),
          ),
          child: ClipOval(
            child: n.actorAvatar.isNotEmpty 
                ? Image.network(n.actorAvatar, fit: BoxFit.cover)
                : Center(child: Text(n.actorName[0], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
          ),
        ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(color: titleColor, fontSize: 15, height: 1.4),
            children: [
              TextSpan(text: n.actorName, style: const TextStyle(fontWeight: FontWeight.w900)),
              const TextSpan(text: " "),
              TextSpan(text: n.content, style: TextStyle(color: titleColor.withValues(alpha: 0.8), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            "${n.createdAt.hour}:${n.createdAt.minute}",
            style: TextStyle(color: titleColor.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        trailing: n.isRead ? null : Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFE2C55), shape: BoxShape.circle)),
        onTap: () {},
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
          Icon(CupertinoIcons.chat_bubble_2, color: emptyIconColor, size: 80),
          const SizedBox(height: 20),
          Text("No messages yet", style: TextStyle(color: emptyTitleColor, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text("Start a conversation with your friends!", textAlign: TextAlign.center, style: TextStyle(color: emptySubtitleColor, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
