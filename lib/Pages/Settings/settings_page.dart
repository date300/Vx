import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Layout/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _privateAccount = false;
  bool _autoPlay = true;
  bool _dataSaver = false;

  static const Color _pink = Color(0xFFFF4FB3);

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

  Color get _bgColor => _isDark ? Colors.black : Colors.white;
  Color get _surfaceColor =>
      _isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
  Color get _iconBgColor => _isDark
      ? Colors.white.withOpacity(0.06)
      : Colors.black.withOpacity(0.06);
  Color get _titleColor => _isDark ? Colors.white : Colors.black;
  Color get _subtitleColor => _isDark ? Colors.white38 : Colors.black38;
  Color get _sectionTitleColor => _isDark ? Colors.white54 : Colors.black54;
  Color get _arrowColor => _isDark ? Colors.white38 : Colors.black38;
  Color get _iconColor => _isDark ? Colors.white70 : Colors.black54;

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _titleColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings and privacy",
          style: TextStyle(
            color: _titleColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Account ──
            _buildSectionTitle("Account"),
            _buildMenuItem(
              icon: Icons.person_outline,
              title: "Manage account",
              subtitle: "Password, security, personal info",
              onTap: () => _showSnackBar("Manage account"),
            ),
            _buildMenuItem(
              icon: Icons.verified_user_outlined,
              title: "Privacy",
              subtitle: "Visibility, interactions, blocked accounts",
              onTap: () => _showSnackBar("Privacy"),
            ),
            _buildMenuItem(
              icon: Icons.security_outlined,
              title: "Security and login",
              subtitle: "Two-factor auth, login activity",
              onTap: () => _showSnackBar("Security and login"),
            ),
            _buildMenuItem(
              icon: Icons.payment_outlined,
              title: "Balance",
              subtitle: "Coins, gifts, transactions",
              onTap: () => _showSnackBar("Balance"),
            ),
            _buildMenuItem(
              icon: Icons.qr_code_scanner,
              title: "QR code",
              subtitle: "Scan or share your profile QR",
              onTap: () => _showSnackBar("QR code"),
            ),

            const SizedBox(height: 8),

            // ── Content & Activity ──
            _buildSectionTitle("Content & Activity"),
            _buildMenuItem(
              icon: Icons.favorite_border,
              title: "Liked videos",
              subtitle: "Videos you have liked",
              onTap: () => _showSnackBar("Liked videos"),
            ),
            _buildMenuItem(
              icon: Icons.bookmark_border,
              title: "Collections",
              subtitle: "Your saved collections",
              onTap: () => _showSnackBar("Collections"),
            ),
            _buildMenuItem(
              icon: Icons.history,
              title: "Watch history",
              subtitle: "Clear or manage watch history",
              onTap: () => _showSnackBar("Watch history"),
            ),
            _buildMenuItem(
              icon: Icons.comment_outlined,
              title: "Comments",
              subtitle: "Manage your comments",
              onTap: () => _showSnackBar("Comments"),
            ),

            const SizedBox(height: 8),

            // ── Preferences ──
            _buildSectionTitle("Preferences"),
            _buildThemeSelector(),
            _buildToggleItem(
              icon: Icons.notifications_outlined,
              title: "Push notifications",
              value: _notifications,
              onChanged: (val) {
                setState(() => _notifications = val);
                _saveBool('notifications', val);
              },
            ),
            _buildToggleItem(
              icon: Icons.lock_outline,
              title: "Private account",
              value: _privateAccount,
              onChanged: (val) {
                setState(() => _privateAccount = val);
                _saveBool('private_account', val);
              },
            ),
            _buildToggleItem(
              icon: Icons.play_circle_outline,
              title: "Auto-play videos",
              value: _autoPlay,
              onChanged: (val) {
                setState(() => _autoPlay = val);
                _saveBool('auto_play', val);
              },
            ),
            _buildToggleItem(
              icon: Icons.data_saver_off_outlined,
              title: "Data saver",
              value: _dataSaver,
              onChanged: (val) {
                setState(() => _dataSaver = val);
                _saveBool('data_saver', val);
              },
            ),
            _buildMenuItem(
              icon: Icons.language,
              title: "Language",
              subtitle: "English",
              onTap: () => _showSnackBar("Language"),
            ),

            const SizedBox(height: 8),

            // ── Support & About ──
            _buildSectionTitle("Support & About"),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: "Help Center",
              subtitle: "FAQs, contact support, report a problem",
              onTap: () => _showSnackBar("Help Center"),
            ),
            _buildMenuItem(
              icon: Icons.policy_outlined,
              title: "Terms of Service",
              onTap: () => _showSnackBar("Terms of Service"),
            ),
            _buildMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              onTap: () => _showSnackBar("Privacy Policy"),
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: "About",
              subtitle: "Version 1.0.0",
              onTap: () => _showSnackBar("About"),
            ),

            const SizedBox(height: 8),

            // ── Danger Zone ──
            _buildSectionTitle("Danger Zone"),
            _buildDangerItem(
              icon: Icons.logout,
              title: "Log out",
              onTap: () => _showLogoutDialog(context),
            ),
            _buildDangerItem(
              icon: Icons.delete_forever,
              title: "Delete account",
              color: Colors.redAccent,
              onTap: () => _showSnackBar("Delete account"),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    final themeProvider = context.watch<ThemeProvider>();
    final currentMode = themeProvider.themeMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _iconBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.brightness_6_outlined,
                        color: _iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    "Theme",
                    style: TextStyle(
                      color: _titleColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: _isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildThemeOption(
                      icon: Icons.dark_mode,
                      label: "Dark",
                      mode: ThemeMode.dark,
                      currentMode: currentMode,
                      themeProvider: themeProvider,
                    ),
                    _buildThemeOption(
                      icon: Icons.light_mode,
                      label: "Light",
                      mode: ThemeMode.light,
                      currentMode: currentMode,
                      themeProvider: themeProvider,
                    ),
                    _buildThemeOption(
                      icon: Icons.phone_android,
                      label: "System",
                      mode: ThemeMode.system,
                      currentMode: currentMode,
                      themeProvider: themeProvider,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String label,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required ThemeProvider themeProvider,
  }) {
    final bool isSelected = currentMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => themeProvider.setTheme(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _pink : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Colors.white
                    : (_isDark ? Colors.white38 : Colors.black38),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : (_isDark ? Colors.white38 : Colors.black38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          color: _sectionTitleColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _iconBgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _titleColor,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: TextStyle(color: _subtitleColor, fontSize: 12))
          : null,
      trailing:
          Icon(Icons.arrow_forward_ios, color: _arrowColor, size: 14),
      onTap: onTap,
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _iconBgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _titleColor,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: _pink,
        activeTrackColor: _pink.withOpacity(0.3),
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey.withOpacity(0.3),
      ),
    );
  }

  Widget _buildDangerItem({
    required IconData icon,
    required String title,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$message coming soon"),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF2A2A2A),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Logout",
      builder: (context) => AlertDialog(
        backgroundColor: _surfaceColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Log out",
          style: TextStyle(
              color: _titleColor, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to log out?",
          style: TextStyle(color: _subtitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: TextStyle(color: _sectionTitleColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar("Logged out");
            },
            child: const Text(
              "Log out",
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
