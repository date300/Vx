import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Pages/Auth/auth_gate_page.dart';
import '../Pages/home_page.dart';
import '../Pages/explore_page.dart';
import '../Pages/upload_page.dart';
import '../Pages/inbox_page.dart';
import '../Pages/profile_page.dart';

class AuthService {
  static bool isLoggedIn = false;
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeFeedPage(),
    ExplorePage(),
    UploadPage(),
    InboxPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    // Auth check BEFORE switching — restricted pages don't switch
    if ((index == 2 || index == 3 || index == 4) &&
        !AuthService.isLoggedIn) {
      showAuthPopup(context);
      return; // ← early return, page stays same
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28.0, sigmaY: 28.0),
        child: SafeArea(
          bottom: true,
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.07),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(index: 0, icon: CupertinoIcons.house, activeIcon: CupertinoIcons.house_fill),
                _buildNavItem(index: 1, icon: CupertinoIcons.search, activeIcon: CupertinoIcons.search),
                _buildUploadButton(),
                _buildNavItem(index: 3, icon: CupertinoIcons.heart, activeIcon: CupertinoIcons.heart_fill),
                _buildProfileItem(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Standard Nav Icon ────────────────────────────────────────────────────
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isActive = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: child,
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey('${index}_$isActive'),
                size: 26,
                color: isActive
                    ? Colors.white
                    : Colors.white.withOpacity(0.42),
              ),
            ),
            const SizedBox(height: 5),
            // Active dot — Instagram's signature
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Center Upload Button (Instagram + style) ─────────────────────────────
  Widget _buildUploadButton() {
    final isActive = _selectedIndex == 2;

    return GestureDetector(
      onTap: () => _onItemTapped(2),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: 44,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withOpacity(0.38),
                  width: 1.6,
                ),
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.add,
                  size: 19,
                  color: isActive
                      ? Colors.white
                      : Colors.white.withOpacity(0.42),
                ),
              ),
            ),
            const SizedBox(height: 5),
            // Dot placeholder to align vertically with others
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  // ─── Profile with ring on active ─────────────────────────────────────────
  Widget _buildProfileItem() {
    final isActive = _selectedIndex == 4;

    return GestureDetector(
      onTap: () => _onItemTapped(4),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? Colors.white : Colors.transparent,
                  width: 2.0,
                ),
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.person_fill,
                  size: 20,
                  color: isActive
                      ? Colors.white
                      : Colors.white.withOpacity(0.42),
                ),
              ),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
