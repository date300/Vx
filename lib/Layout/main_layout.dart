import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // নতুন যোগ করা হয়েছে

import '../Layout/responsive_layout.dart';
import '../Layout/theme_provider.dart';
import '../Pages/Auth/auth_gate_page.dart';
import '../Pages/Home/home_page.dart';
import '../Pages/Explore/explore_page.dart';
import '../Pages/Inbox/inbox_page.dart';
import '../Pages/Profile/profile_page.dart';
import '../Pages/Upload/upload_popup.dart';

class AuthService {
  static bool isLoggedIn = true; // ডিফল্টভাবে ট্রু করে রাখা হয়েছে UI ডিজাইনের জন্য

  // অ্যাপ স্টার্ট হওয়ার সময় লগইন স্ট্যাটাস চেক করবে (আপাতত বন্ধ)
  static Future<void> checkLoginStatus() async {
    // final prefs = await SharedPreferences.getInstance();
    // isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    isLoggedIn = true; 
  }
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

    // অ্যাপ চালু হওয়ার সাথে সাথে লগইন চেক
    AuthService.checkLoginStatus().then((_) {
      if (mounted) setState(() {});
    });
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

  void _onItemTapped(int index) async {
    // লগইন চেক আপাতত বন্ধ রাখা হয়েছে UI ডিজাইনের জন্য
    /*
    if ((index == 2 || index == 3) && !AuthService.isLoggedIn) {
      await showAuthPopup(context);
      
      final prefs = await SharedPreferences.getInstance();
      AuthService.isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      if (AuthService.isLoggedIn && mounted) {
        setState(() => _selectedIndex = index);
      }
      return;
    }
    */
    
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
    final isDesktop = ResponsiveLayout.isDesktop(context);

    _updateSystemUI(isDark);

    final bgColor = isDark ? Colors.black : Colors.white;
    final navBgColor = isDark
        ? Colors.black.withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.75);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.07);
    final activeIconColor = isDark ? Colors.white : Colors.black;
    final inactiveIconColor = isDark
        ? Colors.white.withValues(alpha: 0.42)
        : Colors.black.withValues(alpha: 0.35);
    final uploadBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.38)
        : Colors.black.withValues(alpha: 0.30);

    final uploadGradient = LinearGradient(
      colors: [const Color(0xFFFF4FB3), const Color(0xFF9B4DFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: bgColor,
      body: Row(
        children: [
          if (isDesktop)
            _buildSideBar(
              isDark: isDark,
              borderColor: borderColor,
              activeIconColor: activeIconColor,
              inactiveIconColor: inactiveIconColor,
              uploadBorderColor: uploadBorderColor,
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1600),
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _pages,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : _buildNavBar(
              isDark: isDark,
              navBgColor: navBgColor,
              borderColor: borderColor,
              activeIconColor: activeIconColor,
              inactiveIconColor: inactiveIconColor,
              uploadBorderColor: uploadBorderColor,
            ),
    );
  }

  Widget _buildSideBar({
    required bool isDark,
    required Color borderColor,
    required Color activeIconColor,
    required Color inactiveIconColor,
    required Color uploadBorderColor,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 200;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isCompact ? 80 : 260,
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white,
            border: Border(
              right: BorderSide(color: borderColor, width: 0.5),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              if (!isCompact)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        'VX',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: activeIconColor,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Icon(CupertinoIcons.infinite, color: activeIconColor, size: 32),
              const SizedBox(height: 32),
              _buildSideNavItem(
                index: 0,
                label: isCompact ? "" : 'Home',
                icon: CupertinoIcons.house,
                activeIcon: CupertinoIcons.house_fill,
                activeColor: activeIconColor,
                inactiveColor: inactiveIconColor,
                isCompact: isCompact,
              ),
              _buildSideNavItem(
                index: 1,
                label: isCompact ? "" : 'Explore',
                icon: CupertinoIcons.search,
                activeIcon: CupertinoIcons.search,
                activeColor: activeIconColor,
                inactiveColor: inactiveIconColor,
                isCompact: isCompact,
              ),
              _buildSideNavItem(
                index: 2,
                label: isCompact ? "" : 'Inbox',
                icon: CupertinoIcons.bell,
                activeIcon: CupertinoIcons.bell_fill,
                activeColor: activeIconColor,
                inactiveColor: inactiveIconColor,
                isCompact: isCompact,
              ),
              _buildSideNavItem(
                index: 3,
                label: isCompact ? "" : 'Profile',
                icon: CupertinoIcons.person,
                activeIcon: CupertinoIcons.person_fill,
                activeColor: activeIconColor,
                inactiveColor: inactiveIconColor,
                isCompact: isCompact,
              ),
              const Spacer(),
              _buildSideUploadButton(
                uploadBorderColor: uploadBorderColor,
                activeColor: activeIconColor,
                isCompact: isCompact,
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSideNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required Color activeColor,
    required Color inactiveColor,
    bool isCompact = false,
  }) {
    final isActive = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 12 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment:
                isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 24,
                color: isActive ? activeColor : inactiveColor,
              ),
              if (!isCompact) ...[
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive ? activeColor : inactiveColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSideUploadButton({
    required Color uploadBorderColor,
    required Color activeColor,
    bool isCompact = false,
  }) {
    if (isCompact) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: IconButton(
          onPressed: () => showUploadPopup(context),
          icon: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFF4FB3), Color(0xFF9B4DFF)],
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: const Icon(CupertinoIcons.plus, size: 28, color: Colors.white),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF4FB3), Color(0xFF9B4DFF)],
          ),
        ),
        child: ElevatedButton.icon(
          onPressed: () => showUploadPopup(context),
          icon: const Icon(CupertinoIcons.add, size: 20),
          label: const Text('Create', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
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
                _buildUploadButton(),
                _buildNavItem(
                  index: 2,
                  icon: CupertinoIcons.bell,
                  activeIcon: CupertinoIcons.bell_fill,
                  activeColor: activeIconColor,
                  inactiveColor: inactiveIconColor,
                ),
                _buildNavItem(
                  index: 3,
                  icon: CupertinoIcons.person,
                  activeIcon: CupertinoIcons.person_fill,
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

  Widget _buildUploadButton() {
    return GestureDetector(
      onTap: () => showUploadPopup(context),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF4FB3), Color(0xFF9B4DFF)],
                ),
              ),
              child: const Center(
                child: Icon(
                  CupertinoIcons.add,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 9),
          ],
        ),
      ),
    );
  }

  // Removed _buildProfileItem as it's now covered by _buildNavItem with custom icons

}
