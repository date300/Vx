import 'package:flutter/material.dart';

class HomeTopBar extends StatefulWidget {
  final TabController tabController;
  const HomeTopBar({super.key, required this.tabController});

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
    final top = MediaQuery.of(context).padding.top;
    final index = widget.tabController.index;
    final offset = widget.tabController.offset;
    
    // Calculate opacities based on tab selection and scroll offset
    // This provides a smooth transition between icons
    double followingOpacity = 0.4;
    double trendingOpacity = 0.4;
    
    if (index == 0) {
      followingOpacity = (1.0 - offset.abs()).clamp(0.4, 1.0);
      trendingOpacity = (0.4 + offset.abs() * 0.6).clamp(0.4, 1.0);
    } else {
      trendingOpacity = (1.0 - offset.abs()).clamp(0.4, 1.0);
      followingOpacity = (0.4 + offset.abs() * 0.6).clamp(0.4, 1.0);
    }

    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        height: top + 60,
        padding: EdgeInsets.only(top: top, left: 20, right: 20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left corner: Minimal TV Icon
            Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.live_tv_rounded, color: Colors.white.withOpacity(0.8), size: 22),
            ),
            
            // Center: Minimalist Icons instead of Text
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => widget.tabController.animateTo(0),
                  child: AnimatedScale(
                    scale: index == 0 ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      index == 0 ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                      color: Colors.white.withOpacity(followingOpacity),
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                GestureDetector(
                  onTap: () => widget.tabController.animateTo(1),
                  child: AnimatedScale(
                    scale: index == 1 ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      index == 1 ? Icons.auto_awesome_rounded : Icons.auto_awesome_outlined,
                      color: Colors.white.withOpacity(trendingOpacity),
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
