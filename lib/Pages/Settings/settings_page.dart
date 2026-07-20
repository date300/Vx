import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Layout/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  final bool isDesktopOverlay;
  final VoidCallback? onClose;

  const SettingsPage({
    super.key,
    this.isDesktopOverlay = false,
    this.onClose,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _privateAccount = false;
  bool _autoPlay = true;
  bool _dataSaver = false;

  static const Color _primaryPink = Color(0xFFFE2C55);
  static const Color _accentPink = Color(0xFFFF4FB3);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications = prefs.getBool('notifications') ?? true;
      _privateAccount = prefs.getBool('private_account') ?? false;
      _autoPlay = prefs.getBool('auto_play') ?? true;
      _dataSaver = prefs.getBool('data_saver') ?? false;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  bool get _isDark {
    final mode = context.read<ThemeProvider>().themeMode;
    if (mode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return mode == ThemeMode.dark;
  }

  Color get _bgColor => _isDark ? Colors.black : const Color(0xFFF8F8F8);
  Color get _cardColor => _isDark ? const Color(0xFF121212) : Colors.white;
  Color get _titleColor => _isDark ? Colors.white : Colors.black;
  Color get _subtitleColor => _isDark ? Colors.white54 : Colors.black54;

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(top),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("ACCOUNT"),
                  _buildModernContainer([
                    _buildModernMenuItem(
                      icon: CupertinoIcons.person,
                      title: "Manage account",
                      subtitle: "Password, security, personal info",
                      onTap: () => _showSnackBar("Manage account"),
                    ),
                    _buildDivider(),
                    _buildModernMenuItem(
                      icon: CupertinoIcons.shield,
                      title: "Privacy",
                      subtitle: "Visibility, interactions, blocked",
                      onTap: () => _showSnackBar("Privacy"),
                    ),
                    _buildDivider(),
                    _buildModernMenuItem(
                      icon: CupertinoIcons.lock_shield,
                      title: "Security and login",
                      subtitle: "Two-factor auth, login activity",
                      onTap: () => _showSnackBar("Security and login"),
                    ),
                    _buildDivider(),
                    _buildModernMenuItem(
                      icon: CupertinoIcons.creditcard,
                      title: "Balance",
                      subtitle: "Coins, gifts, transactions",
                      onTap: () => _showSnackBar("Balance"),
                    ),
                  ]),

                  const SizedBox(height: 30),
                  _buildSectionHeader("CONTENT & ACTIVITY"),
                  _buildModernContainer([
                    _buildModernMenuItem(
                      icon: CupertinoIcons.heart,
                      title: "Liked videos",
                      onTap: () => _showSnackBar("Liked videos"),
                    ),
                    _buildDivider(),
                    _buildModernMenuItem(
                      icon: CupertinoIcons.bookmark,
                      title: "Collections",
                      onTap: () => _showSnackBar("Collections"),
                    ),
                    _buildDivider(),
                    _buildModernMenuItem(
                      icon: CupertinoIcons.clock,
                      title: "Watch history",
                      onTap: () => _showSnackBar("Watch history"),
                    ),
                  ]),

                  const SizedBox(height: 30),
                  _buildSectionHeader("PREFERENCES"),
                  _buildModernContainer([
                    _buildThemeSelector(),
                    _buildDivider(),
                    _buildToggleItem(
                      icon: CupertinoIcons.bell,
                      title: "Push notifications",
                      value: _notifications,
                      onChanged: (val) {
                        setState(() => _notifications = val);
                        _saveBool('notifications', val);
                      },
                    ),
                    _buildDivider(),
                    _buildToggleItem(
                      icon: CupertinoIcons.eye_slash,
                      title: "Private account",
                      value: _privateAccount,
                      onChanged: (val) {
                        setState(() => _privateAccount = val);
                        _saveBool('private_account', val);
                      },
                    ),
                    _buildDivider(),
                    _buildToggleItem(
                      icon: CupertinoIcons.play_circle,
                      title: "Auto-play videos",
                      value: _autoPlay,
                      onChanged: (val) {
                        setState(() => _autoPlay = val);
                        _saveBool('auto_play', val);
                      },
                    ),
                  ]),

                  const SizedBox(height: 30),
                  _buildSectionHeader("SUPPORT"),
                  _buildModernContainer([
                    _buildModernMenuItem(
                      icon: CupertinoIcons.question_circle,
                      title: "Help Center",
                      onTap: () => _showSnackBar("Help Center"),
                    ),
                    _buildDivider(),
                    _buildModernMenuItem(
                      icon: CupertinoIcons.doc_text,
                      title: "Terms of Service",
                      onTap: () => _showSnackBar("Terms of Service"),
                    ),
                  ]),

                  const SizedBox(height: 40),
                  _buildDangerZone(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(double top) {
    return SliverAppBar(
      expandedHeight: widget.isDesktopOverlay ? 80.0 : 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: _bgColor,
      automaticallyImplyLeading: false,
      leading: widget.isDesktopOverlay
          ? null
          : IconButton(
              icon: Icon(CupertinoIcons.back, color: _titleColor),
              onPressed: () => Navigator.pop(context),
            ),
      actions: [
        if (widget.isDesktopOverlay)
          IconButton(
            icon: Icon(CupertinoIcons.xmark, color: _titleColor),
            onPressed: widget.onClose,
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          "Settings",
          style: TextStyle(
            color: _titleColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _primaryPink.withValues(alpha: 0.05),
                _bgColor,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: _subtitleColor,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildModernContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: _isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildModernMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _primaryPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _primaryPink, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _titleColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: _subtitleColor, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_forward, color: _subtitleColor, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _primaryPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primaryPink, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: _titleColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: _primaryPink,
            trackColor: _isDark ? Colors.white10 : Colors.black12,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 60,
      endIndent: 20,
      color: _isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
    );
  }

  Widget _buildThemeSelector() {
    final themeProvider = context.watch<ThemeProvider>();
    final currentMode = themeProvider.themeMode;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.paintbrush, color: _primaryPink, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                "Theme",
                style: TextStyle(
                  color: _titleColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: _isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildThemeOption(CupertinoIcons.moon, "Dark", ThemeMode.dark, currentMode, themeProvider),
                _buildThemeOption(CupertinoIcons.sun_max, "Light", ThemeMode.light, currentMode, themeProvider),
                _buildThemeOption(CupertinoIcons.device_phone_portrait, "System", ThemeMode.system, currentMode, themeProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(IconData icon, String label, ThemeMode mode, ThemeMode currentMode, ThemeProvider themeProvider) {
    final bool isSelected = currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => themeProvider.setTheme(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _primaryPink : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(
                color: _primaryPink.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : _subtitleColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? Colors.white : _subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Column(
      children: [
        InkWell(
          onTap: () => _showLogoutDialog(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.power, color: Colors.redAccent, size: 20),
                SizedBox(width: 12),
                Text(
                  "Log Out",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => _showSnackBar("Delete account"),
          child: Text(
            "Delete Account",
            style: TextStyle(color: _subtitleColor, fontSize: 13, decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: _isDark ? const Color(0xFF1E1E1E) : Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out of your account?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Log Out"),
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar("Logged out");
            },
          ),
        ],
      ),
    );
  }
}
