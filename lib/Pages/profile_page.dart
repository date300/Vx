import 'package:flutter/material.dart';
import '../Layout/premium_theme_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // User stats
  final int _followingCount = 234;
  final int _followersCount = 125400;
  final int _likesCount = 2500000;

  // Dummy video thumbnails (প্রোডাক্শনে এগুলো API থেকে আসবে)
  final List<String> _userVideos = const [
    "https://picsum.photos/300/400?random=1",
    "https://picsum.photos/300/400?random=2",
    "https://picsum.photos/300/400?random=3",
    "https://picsum.photos/300/400?random=4",
    "https://picsum.photos/300/400?random=5",
    "https://picsum.photos/300/400?random=6",
    "https://picsum.photos/300/400?random=7",
    "https://picsum.photos/300/400?random=8",
    "https://picsum.photos/300/400?random=9",
    "https://picsum.photos/300/400?random=10",
    "https://picsum.photos/300/400?random=11",
    "https://picsum.photos/300/400?random=12",
  ];

  final List<String> _likedVideos = const [
    "https://picsum.photos/300/400?random=20",
    "https://picsum.photos/300/400?random=21",
    "https://picsum.photos/300/400?random=22",
    "https://picsum.photos/300/400?random=23",
    "https://picsum.photos/300/400?random=24",
    "https://picsum.photos/300/400?random=25",
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "@Sohan_Dev",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.white, size: 28),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Upload video coming soon")),
              );
            },
          ),
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      endDrawer: _buildThemeDrawer(context),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _buildProfileHeader(),
            ),
          ];
        },
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildVideoGrid(_userVideos),
                  _buildVideoGrid(_likedVideos),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Profile Picture with gradient ring
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF4FB3),
                      Color(0xFFB24FF3),
                      Color(0xFF4F9DFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
              ),
              Container(
                width: 98,
                height: 98,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF4FB3),
                      Color(0xFFB24FF3),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Username
          const Text(
            "Sohan Dev",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Bio
          const Text(
            "Flutter Developer 🚀 | UI/UX Enthusiast ✨\nCreating premium apps | DM for collab 📩",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem("Following", _followingCount),
              Container(width: 1, height: 20, color: Colors.white24),
              _buildStatItem("Followers", _followersCount),
              Container(width: 1, height: 20, color: Colors.white24),
              _buildStatItem("Likes", _likesCount),
            ],
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Edit profile coming soon")),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text(
                    "Edit Profile",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Share profile coming soon")),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.share, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          _formatCount(count),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white10, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 2,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        tabs: const [
          Tab(
            icon: Icon(Icons.grid_on, size: 24),
          ),
          Tab(
            icon: Icon(Icons.favorite_border, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoGrid(List<String> videos) {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 9 / 16,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Playing video ${index + 1}")),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video thumbnail (প্রোডাক্শনে actual thumbnail হবে)
              Container(
                color: Colors.grey[900],
                child: Image.network(
                  videos[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[850],
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: Colors.white54,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
              
              // Play icon overlay
              const Positioned(
                bottom: 8,
                left: 8,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              
              // View count
              Positioned(
                bottom: 8,
                right: 8,
                child: Row(
                  children: [
                    const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      _formatCount((index + 1) * 125000),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const Icon(Icons.palette, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    "Theme & Colors",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, thickness: 1),
            
            // Dark/Light Mode Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Appearance",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildModeOption(
                    context,
                    Icons.dark_mode,
                    "Dark Mode",
                    "Comfortable for eyes",
                    true,
                  ),
                  const SizedBox(height: 8),
                  _buildModeOption(
                    context,
                    Icons.light_mode,
                    "Light Mode",
                    "Coming soon",
                    false,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            const Divider(color: Colors.white24, thickness: 1),
            
            // Accent Colors Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Accent Colors",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildColorDot(context, const Color(0xFFFF4FB3), "Pink"),
                      _buildColorDot(context, const Color(0xFF4F9DFF), "Blue"),
                      _buildColorDot(context, const Color(0xFF4FFF9D), "Green"),
                      _buildColorDot(context, const Color(0xFFFF4F4F), "Red"),
                      _buildColorDot(context, const Color(0xFFB24FF3), "Purple"),
                      _buildColorDot(context, const Color(0xFFFFB74F), "Orange"),
                      _buildColorDot(context, const Color(0xFF4FFFF3), "Cyan"),
                      _buildColorDot(context, const Color(0xFFFFF34F), "Yellow"),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Version info
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Divider(color: Colors.white24, thickness: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white38,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Premium App v1.0.0",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool isActive,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: const Color(0xFFFF4FB3), width: 1.5)
            : Border.all(color: Colors.white10, width: 1),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? const Color(0xFFFF4FB3) : Colors.white70,
          size: 26,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white38,
            fontSize: 12,
          ),
        ),
        trailing: isActive
            ? const Icon(Icons.check_circle, color: Color(0xFFFF4FB3), size: 22)
            : null,
        onTap: isActive
            ? null
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$title coming soon")),
                );
              },
      ),
    );
  }

  Widget _buildColorDot(BuildContext context, Color color, String name) {
    return GestureDetector(
      onTap: () {
        PremiumTheme.accentColor.value = color;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$name theme activated"),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: ValueListenableBuilder<Color>(
        valueListenable: PremiumTheme.accentColor,
        builder: (context, activeColor, child) {
          bool isSelected = activeColor.value == color.value;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 56 : 52,
                height: isSelected ? 56 : 52,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : Border.all(color: Colors.white24, width: 1),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.6),
                            blurRadius: 16,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 24)
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) {
      return "${(n / 1000000).toStringAsFixed(1)}M".replaceAll(".0", "");
    }
    if (n >= 1000) {
      return "${(n / 1000).toStringAsFixed(1)}K".replaceAll(".0", "");
    }
    return n.toString();
  }
}
