import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../Layout/theme_provider.dart';
import '../Pages/Auth/auth_gate_page.dart';
import '../Pages/home_page.dart' hide InboxPage;
import '../Pages/explore_page.dart';
import '../Pages/inbox_page.dart';
import '../Pages/profile_page.dart';
import '../Pages/upload_popup.dart';

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

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _updateSystemUI(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  final List<Widget> _pages = const [
    HomeFeedPage(),
    ExplorePage(),
    InboxPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    // [DISABLED TEMPORARILY] Auth gate check - will be enabled later
    // if ((index == 2 || index == 3) && !AuthService.isLoggedIn) {
    //   showAuthPopup(context);
    //   return;
    // }
    setState(() => _selectedIndex = index);
  }

  bool _isDark(ThemeMode mode) {
    if (mode == ThemeMode.system) {
      return WidgetsBinding
              .instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return mode == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = _isDark(themeProvider.themeMode);

    _updateSystemUI(isDark);

    final bgColor = isDark ? Colors.black : Colors.white;
    final navBgColor = isDark
        ? Colors.black.withOpacity(0.55)
        : Colors.white.withOpacity(0.75);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.07)
        : Colors.black.withOpacity(0.07);
    final activeIconColor = isDark ? Colors.white : Colors.black;
    final inactiveIconColor = isDark
        ? Colors.white.withOpacity(0.42)
        : Colors.black.withOpacity(0.35);
    final uploadBorderColor = isDark
        ? Colors.white.withOpacity(0.38)
        : Colors.black.withOpacity(0.30);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildNavBar(
        isDark: isDark,
        navBgColor: navBgColor,
        borderColor: borderColor,
        activeIconColor: activeIconColor,
        inactiveIconColor: inactiveIconColor,
        uploadBorderColor: uploadBorderColor,
      ),
    );
  }

  Widget _buildNavBar({
    required bool isDark,
    required Color navBgColor,
    required Color borderColor,
    required Color activeIconColor,
    required Color inactiveIconColor,
    required Color uploadBorderColor,
  }) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28.0, sigmaY: 28.0),
        child: SafeArea(
          bottom: true,
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: navBgColor,
              border: Border(
                top: BorderSide(color: borderColor, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: CupertinoIcons.house,
                  activeIcon: CupertinoIcons.house_fill,
                  activeColor: activeIconColor,
                  inactiveColor: inactiveIconColor,
                ),
                _buildNavItem(
                  index: 1,
                  icon: CupertinoIcons.search,
                  activeIcon: CupertinoIcons.search,
                  activeColor: activeIconColor,
                  inactiveColor: inactiveIconColor,
                ),
                _buildUploadButton(
                  uploadBorderColor: uploadBorderColor,
                  inactiveColor: inactiveIconColor,
                ),
                _buildNavItem(
                  index: 2,
                  icon: CupertinoIcons.bell,
                  activeIcon: CupertinoIcons.bell_fill,
                  activeColor: activeIconColor,
                  inactiveColor: inactiveIconColor,
                ),
                _buildProfileItem(
                  activeColor: activeIconColor,
                  inactiveColor: inactiveIconColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required Color activeColor,
    required Color inactiveColor,
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
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey('${index}_$isActive'),
                size: 26,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton({
    required Color uploadBorderColor,
    required Color inactiveColor,
  }) {
    return GestureDetector(
      onTap: () => showUploadPopup(context),
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
                  color: uploadBorderColor,
                  width: 1.6,
                ),
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.add,
                  size: 19,
                  color: inactiveColor,
                ),
              ),
            ),
            const SizedBox(height: 9),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final isActive = _selectedIndex == 3;

    return GestureDetector(
      onTap: () => _onItemTapped(3),
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
                  color: isActive ? activeColor : Colors.transparent,
                  width: 2.0,
                ),
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.person_fill,
                  size: 20,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
