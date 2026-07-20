import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../Layout/responsive_layout.dart';
import '../../Explore/search_page.dart';

class HomeTopBar extends StatefulWidget {
  final TabController tabController;
  final bool isSidebar;
  const HomeTopBar({super.key, required this.tabController, this.isSidebar = false});

  @override
  State<HomeTopBar> createState() => _HomeTopBarState();
}

class _HomeTopBarState extends State<HomeTopBar> {
  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSidebar) {
      return _buildSidebarTabs();
    }

    if (ResponsiveLayout.isDesktop(context)) {
      return const SizedBox.shrink();
    }

    final top = MediaQuery.of(context).padding.top;
    
    // Smooth transition using animation value
    final animationValue = widget.tabController.animation?.value ?? widget.tabController.index.toDouble();
    
    // Following Icon (index 0)
    double followingOpacity = (1.0 - animationValue).clamp(0.4, 1.0);
    if (animationValue > 1.0) followingOpacity = 0.4;

    // Friends Icon (index 1)
    double friendsOpacity;
    if (animationValue <= 1.0) {
      friendsOpacity = (0.4 + (animationValue * 0.6)).clamp(0.4, 1.0);
    } else {
      friendsOpacity = (1.0 - (animationValue - 1.0) * 0.6).clamp(0.4, 1.0);
    }

    // Trending/For You Icon (index 2)
    double trendingOpacity = 0.4;
    if (animationValue >= 1.0) {
      trendingOpacity = (0.4 + (animationValue - 1.0) * 0.6).clamp(0.4, 1.0);
    }

    final currentIndex = widget.tabController.index;

    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        height: top + 60,
        padding: EdgeInsets.only(top: top, left: 24, right: 24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left corner: Premium Live Icon
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.tv_fill, color: Colors.white, size: 20),
              ),
            ),
            
            // Center: Premium Tab Icons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModernTabItem(
                  onTap: () => widget.tabController.animateTo(0),
                  isActive: currentIndex == 0,
                  icon: CupertinoIcons.heart_fill,
                  opacity: followingOpacity,
                ),
                const SizedBox(width: 30),
                _buildModernTabItem(
                  onTap: () => widget.tabController.animateTo(1),
                  isActive: currentIndex == 1,
                  icon: CupertinoIcons.person_2_fill,
                  opacity: friendsOpacity,
                ),
                const SizedBox(width: 30),
                _buildModernTabItem(
                  onTap: () => widget.tabController.animateTo(2),
                  isActive: currentIndex == 2,
                  icon: CupertinoIcons.flame_fill,
                  opacity: trendingOpacity,
                ),
              ],
            ),

            // Right corner: Search Icon for consistency
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchPage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.search, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarTabs() {
    final currentIndex = widget.tabController.index;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSidebarTabItem(
          onTap: () => widget.tabController.animateTo(0),
          isActive: currentIndex == 0,
          icon: CupertinoIcons.heart_fill,
          label: "Following",
        ),
        const SizedBox(height: 20),
        _buildSidebarTabItem(
          onTap: () => widget.tabController.animateTo(1),
          isActive: currentIndex == 1,
          icon: CupertinoIcons.person_2_fill,
          label: "Friends",
        ),
        const SizedBox(height: 20),
        _buildSidebarTabItem(
          onTap: () => widget.tabController.animateTo(2),
          isActive: currentIndex == 2,
          icon: CupertinoIcons.flame_fill,
          label: "For You",
        ),
      ],
    );
  }

  Widget _buildSidebarTabItem({
    required VoidCallback onTap,
    required bool isActive,
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFE2C55).withValues(alpha: 0.1) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? const Color(0xFFFE2C55) : Colors.white70,
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white60,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTabItem({
    required VoidCallback onTap,
    required bool isActive,
    required IconData icon,
    required double opacity,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: isActive ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: opacity),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isActive ? 5 : 0,
            height: isActive ? 5 : 0,
            decoration: const BoxDecoration(
              color: Color(0xFFFE2C55),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
