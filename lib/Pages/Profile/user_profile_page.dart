import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Layout/theme_provider.dart';
import '../../Services/native_service.dart';
import '../Home/models/video_data.dart';
import '../Inbox/chat_detail_screen.dart';
import 'user_video_list_view.dart';

class UserProfilePage extends StatefulWidget {
  final String username;
  const UserProfilePage({super.key, required this.username});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    final subtitleColor = isDark ? Colors.white54 : Colors.black54;
    final borderColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.username,
          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      _buildCoverImage(borderColor),
                      Positioned(
                        bottom: -40,
                        child: _buildProfileImage(bgColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Text(
                    "@${widget.username.toLowerCase().replaceAll(' ', '_')}",
                    style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  _buildStats(titleColor, subtitleColor, borderColor),
                  const SizedBox(height: 20),
                  _buildActionButtons(titleColor, borderColor),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Content Creator | Tech Enthusiast 🎥\nExploring the world through Vx!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: titleColor.withValues(alpha: 0.7), fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: titleColor,
                  indicatorWeight: 1,
                  labelColor: titleColor,
                  unselectedLabelColor: titleColor.withValues(alpha: 0.38),
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on_rounded)),
                    Tab(icon: Icon(Icons.favorite_border_rounded)),
                  ],
                ),
                bgColor: bgColor,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildVideoGrid(),
            Center(child: Text("Liked Videos", style: TextStyle(color: titleColor.withValues(alpha: 0.54)))),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(Color borderColor) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: borderColor,
        image: const DecorationImage(
          image: NetworkImage("https://picsum.photos/800/400"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileImage(Color borderColor) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 4),
        image: const DecorationImage(
          image: NetworkImage("https://picsum.photos/201"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildStats(Color titleColor, Color subtitleColor, Color borderColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatItem("Following", "245", titleColor, subtitleColor),
        _buildDivider(borderColor),
        _buildStatItem("Followers", "12.8K", titleColor, subtitleColor),
        _buildDivider(borderColor),
        _buildStatItem("Likes", "89.3K", titleColor, subtitleColor),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color titleColor, Color subtitleColor) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: titleColor, fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: subtitleColor, fontSize: 12)),
      ],
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Container(
      height: 15,
      width: 1,
      color: borderColor,
      margin: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  Widget _buildActionButtons(Color titleColor, Color borderColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isFollowing = !_isFollowing),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 10),
            decoration: BoxDecoration(
              color: _isFollowing ? titleColor.withValues(alpha: 0.08) : const Color(0xFFFF4FB3),
              borderRadius: BorderRadius.circular(4),
              border: _isFollowing ? Border.all(color: borderColor) : null,
            ),
            child: Text(
              _isFollowing ? "Following" : "Follow",
              style: TextStyle(
                color: _isFollowing ? titleColor : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                  userName: widget.username,
                  avatar: widget.username.substring(0, 1).toUpperCase(),
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: titleColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Icon(CupertinoIcons.chat_bubble_text, color: titleColor, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final outWidthPtr = calloc<Double>();
        nativeService.calculateGridItemSize(constraints.maxWidth, 3, 1.0, outWidthPtr);
        calloc.free(outWidthPtr);

        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 3 / 4,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          itemCount: 15,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserVideoListView(
                      username: widget.username,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Container(
                color: Colors.white10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      "https://picsum.photos/id/${index + 100}/200/300",
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 5,
                      left: 5,
                      child: Row(
                        children: [
                          const Icon(Icons.play_arrow_outlined, color: Colors.white, size: 16),
                          const SizedBox(width: 2),
                          Text("${(index + 5) * 2}K", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color bgColor;
  _SliverTabBarDelegate(this.tabBar, {required this.bgColor});

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: bgColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
