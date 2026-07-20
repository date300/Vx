import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../Layout/responsive_layout.dart';
import '../Layout/theme_provider.dart';
import '../Pages/Auth/auth_gate_page.dart';
import '../Pages/Home/home_page.dart';
import '../Pages/Explore/explore_page.dart';
import '../Pages/Inbox/inbox_page.dart';
import '../Pages/Profile/profile_page.dart';
import '../Pages/Upload/upload_popup.dart';
import '../Services/auth_service.dart';
import '../Services/notification_service.dart';
import '../Services/performance_service.dart';

import '../Pages/Settings/settings_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _showSettings = false;
  final GlobalKey<HomeFeedPageState> _homeKey = GlobalKey<HomeFeedPageState>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _updateSystemUI(bool isDarkStatus, bool isDarkNav) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkStatus ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDarkNav ? Brightness.light : Brightness.dark,
      ),
    );
  }

  List<Widget> get _pages => [
    HomeFeedPage(key: _homeKey, isVisible: _selectedIndex == 0),
    const ExplorePage(),
    const InboxPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) async {
    if (index == _selectedIndex) return;
    
    // Auto-optimize memory when switching tabs to keep things fresh
    PerformanceService().optimizeMemory();

    final loggedIn = await AuthService.checkIsLoggedIn();
    if ((index == 2 || index == 3) && !loggedIn) {
      if (!mounted) return;
      await showAuthPopup(context);
      
      if (!mounted) return;
      final stillLoggedIn = await AuthService.checkIsLoggedIn();
      if (stillLoggedIn && mounted) {
        setState(() => _selectedIndex = index);
      }
      return;
    }
    
    setState(() => _selectedIndex = index);
  }

  void _handleUpload(BuildContext context) async {
    final loggedIn = await AuthService.checkIsLoggedIn();
    if (!loggedIn) {
      if (!mounted) return;
      await showAuthPopup(context);
      
      final stillLoggedIn = await AuthService.checkIsLoggedIn();
      if (!stillLoggedIn) return;
    }
    
    if (mounted) {
      _homeKey.currentState?.pausePlayback();
      await showUploadPopup(context);
      if (mounted) _homeKey.currentState?.resumePlayback();
    }
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
    final isTablet  = ResponsiveLayout.isTablet(context);
    final showSidebar = isDesktop || isTablet;

    final bool isHome = _selectedIndex == 0;
    final bool shouldBeDarkNav = isDark || isHome;

    _updateSystemUI(isDark, shouldBeDarkNav);

    final navBgColor = shouldBeDarkNav
        ? Colors.black.withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.75);
    final borderColor = shouldBeDarkNav
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);
    final activeIconColor = shouldBeDarkNav ? Colors.white : Colors.black;
    final inactiveIconColor = shouldBeDarkNav
        ? Colors.white.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.4);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Row(
        children: [
          if (showSidebar)
            _buildSideBar(
              themeProvider: themeProvider,
              isDark: isDark,
              borderColor: borderColor,
              activeIconColor: activeIconColor,
              inactiveIconColor: inactiveIconColor,
              isCompact: isTablet,
            ),
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: _selectedIndex == 0 ? 1200 : 1600,
                    ),
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _pages,
                    ),
                  ),
                ),
                if (_showSettings && isDesktop)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 400,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black : Colors.white,
                        border: Border(
                          left: BorderSide(color: borderColor, width: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(-5, 0),
                          ),
                        ],
                      ),
                      child: SettingsPage(
                        isDesktopOverlay: true,
                        onClose: () => setState(() => _showSettings = false),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: showSidebar
          ? null
          : _buildNavBar(
              isDark: shouldBeDarkNav,
              navBgColor: navBgColor,
              borderColor: borderColor,
              activeIconColor: activeIconColor,
              inactiveIconColor: inactiveIconColor,
            ),
    );
  }

  Widget _buildSideBar({
    required ThemeProvider themeProvider,
    required bool isDark,
    required Color borderColor,
    required Color activeIconColor,
    required Color inactiveIconColor,
    bool isCompact = false,
  }) {
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
          if (!isCompact) ...[
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(color: borderColor, height: 1),
            ),
            const SizedBox(height: 24),
            _buildSideNavItem(
              index: -1,
              label: 'Settings',
              icon: CupertinoIcons.settings,
              activeIcon: CupertinoIcons.settings,
              activeColor: activeIconColor,
              inactiveColor: inactiveIconColor,
              onTap: () {
                if (ResponsiveLayout.isDesktop(context)) {
                  setState(() => _showSettings = !_showSettings);
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                }
              },
            ),
            _buildSideNavItem(
              index: -1,
              label: 'Creator Tools',
              icon: CupertinoIcons.chart_bar_square,
              activeIcon: CupertinoIcons.chart_bar_square,
              activeColor: activeIconColor,
              inactiveColor: inactiveIconColor,
              onTap: () {},
            ),
            _buildSideNavItem(
              index: -1,
              label: 'QR Code',
              icon: CupertinoIcons.qrcode,
              activeIcon: CupertinoIcons.qrcode,
              activeColor: activeIconColor,
              inactiveColor: inactiveIconColor,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            _buildSidebarThemeSelector(themeProvider, isDark, activeIconColor, inactiveIconColor),
          ],
          const Spacer(),
          _buildSideUploadButton(
            activeColor: activeIconColor,
            isCompact: isCompact,
          ),
          const SizedBox(height: 40),
        ],
      ),
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
    VoidCallback? onTap,
  }) {
    final isActive = index != -1 && _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap ?? () => _onItemTapped(index),
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

  Widget _buildSidebarThemeSelector(ThemeProvider themeProvider, bool isDark, Color activeColor, Color inactiveColor) {
    final currentMode = themeProvider.themeMode;
    final bgColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _buildThemeOption(CupertinoIcons.moon, ThemeMode.dark, currentMode, themeProvider),
            _buildThemeOption(CupertinoIcons.sun_max, ThemeMode.light, currentMode, themeProvider),
            _buildThemeOption(CupertinoIcons.device_phone_portrait, ThemeMode.system, currentMode, themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(IconData icon, ThemeMode mode, ThemeMode currentMode, ThemeProvider themeProvider) {
    final bool isSelected = currentMode == mode;
    final Color primaryPink = const Color(0xFFFE2C55);

    return Expanded(
      child: GestureDetector(
        onTap: () => themeProvider.setTheme(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primaryPink : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(
                color: primaryPink.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildSideUploadButton({
    required Color activeColor,
    bool isCompact = false,
  }) {
    const gradient = LinearGradient(colors: [Color(0xFFFE2C55), Color(0xFFFF4FB3)]);
    if (isCompact) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: IconButton(
          onPressed: () => _handleUpload(context),
          icon: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradient,
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(CupertinoIcons.plus, size: 28, color: Colors.white),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFE2C55).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () => _handleUpload(context),
          icon: const Icon(CupertinoIcons.add, size: 20),
          label: const Text('Create', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
  }) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 35.0, sigmaY: 35.0),
        child: SafeArea(
          bottom: true,
          child: Container(
            height: 62,
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
                _buildUploadButton(isDark),
                _buildNavItem(
                  index: 2,
                  icon: CupertinoIcons.bell,
                  activeIcon: CupertinoIcons.bell_fill,
                  activeColor: activeIconColor,
                  inactiveColor: inactiveIconColor,
                  showBadge: true,
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
    bool showBadge = false,
  }) {
    final isActive = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    key: ValueKey('${index}_$isActive'),
                    size: 26,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
                if (showBadge)
                  Positioned(
                    top: -3,
                    right: -7,
                    child: Consumer<NotificationService>(
                      builder: (context, ns, _) {
                        if (ns.unreadCount == 0) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFE2C55),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedIndex == 0 ? Colors.black : Colors.white,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFE2C55).withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(minWidth: 18),
                          child: Text(
                            ns.unreadCount > 99 ? "99+" : ns.unreadCount.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: isActive ? 5 : 0,
              height: isActive ? 5 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFFFE2C55),
                shape: BoxShape.circle,
                boxShadow: isActive ? [
                  BoxShadow(
                    color: const Color(0xFFFE2C55).withValues(alpha: 0.4),
                    blurRadius: 4,
                  )
                ] : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(bool isDark) {
    return GestureDetector(
      onTap: () => _handleUpload(context),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFE2C55), Color(0xFFFF4FB3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFE2C55).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  CupertinoIcons.plus,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 11),
          ],
        ),
      ),
    );
  }
}
