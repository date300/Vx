import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Layout/theme_provider.dart';
import '../../Services/native_service.dart';
import '../Settings/settings_page.dart';
import 'edit_profile_page.dart';
import 'user_video_list_view.dart';
import 'vx_studio_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    final cardColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP BAR (Username & Menu)
            _buildTopBar(titleColor),

            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // 2. PROFILE PICTURE
                          _buildProfileImage(borderColor),
                          const SizedBox(height: 15),
                          // 3. USERNAME
                          Text(
                            "@vx_user_pro",
                            style: TextStyle(color: titleColor, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          // 4. STATS (Following, Followers, Likes)
                          _buildStats(titleColor, subtitleColor, borderColor),
                          const SizedBox(height: 20),
                          // 5. EDIT PROFILE BUTTON
                          _buildActionButtons(context, titleColor, borderColor),
                          const SizedBox(height: 15),

                          // 5.5 VX STUDIO BANNER
                          _buildVxStudioBanner(context, titleColor, cardColor),
                          const SizedBox(height: 15),

                          // 6. BIO
                          Text(
                            "Building the future of short-video apps 🚀\nC++ Native Engine Powered",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: titleColor.withValues(alpha: 0.7), fontSize: 14),
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
                            Tab(icon: Icon(Icons.lock_outline_rounded)),
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
                    Center(child: Text("Private Videos", style: TextStyle(color: titleColor.withValues(alpha: 0.54)))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(Color titleColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.person_add_alt_1_outlined, color: titleColor, size: 26),
          Text("Vx User",
              style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 17)),
          GestureDetector(
            onTap: () => _showSettingsMenu(context),
            child: Icon(Icons.menu_rounded, color: titleColor, size: 28),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    final isDark = _isDark(context);
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: titleColor.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuOption(
                icon: Icons.settings_outlined,
                title: "Settings and privacy",
                titleColor: titleColor,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                },
              ),
              _buildMenuOption(
                icon: Icons.insights_outlined,
                title: "Creator tools",
                titleColor: titleColor,
                onTap: () => Navigator.pop(context),
              ),
              _buildMenuOption(
                icon: Icons.qr_code_scanner_outlined,
                title: "My QR code",
                titleColor: titleColor,
                onTap: () => Navigator.pop(context),
              ),
              _buildMenuOption(
                icon: Icons.share_outlined,
                title: "Share profile",
                titleColor: titleColor,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required Color titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor, size: 24),
      title: Text(
        title,
        style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  Widget _buildProfileImage(Color borderColor) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1),
        image: const DecorationImage(
          image: NetworkImage("https://picsum.photos/200"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildStats(Color titleColor, Color subtitleColor, Color borderColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatItem("Following", "128", titleColor, subtitleColor),
        _buildDivider(borderColor),
        _buildStatItem("Followers", "45.2K", titleColor, subtitleColor),
        _buildDivider(borderColor),
        _buildStatItem("Likes", "1.2M", titleColor, subtitleColor),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color titleColor, Color subtitleColor) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: titleColor, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: subtitleColor, fontSize: 13)),
      ],
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Container(
      height: 15,
      width: 1,
      color: borderColor,
      margin: const EdgeInsets.symmetric(horizontal: 25),
    );
  }

  Widget _buildActionButtons(BuildContext context, Color titleColor, Color borderColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfilePage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            decoration: BoxDecoration(
              color: titleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Text("Edit profile", style: TextStyle(color: titleColor, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: titleColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Icon(Icons.bookmark_border_rounded, color: titleColor, size: 22),
        ),
      ],
    );
  }

  Widget _buildVxStudioBanner(BuildContext context, Color titleColor, Color cardColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VxStudioPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.pinkAccent.withValues(alpha: 0.15),
              Colors.deepPurpleAccent.withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: titleColor.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.graph_circle, color: Colors.pinkAccent, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Vx Studio",
                    style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    "Creator dashboard and analytics",
                    style: TextStyle(color: titleColor.withValues(alpha: 0.5), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: titleColor.withValues(alpha: 0.3), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // C++ Engine দিয়ে গ্রিড আইটেম সাইজ ক্যালকুলেট করা
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
          itemCount: 20,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserVideoListView(
                      username: "Vx User",
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
                      "https://picsum.photos/id/${index + 50}/200/300",
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 5,
                      left: 5,
                      child: Row(
                        children: [
                          const Icon(Icons.play_arrow_outlined, color: Colors.white, size: 16),
                          const SizedBox(width: 2),
                          Text("${(index + 1) * 12}K", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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
