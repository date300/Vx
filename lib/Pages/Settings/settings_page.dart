import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = true;
  bool _notifications = true;
  bool _privateAccount = false;
  bool _autoPlay = true;
  bool _dataSaver = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings and privacy",
          style: TextStyle(
            color: Colors.white,
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
            _buildSectionTitle("Preferences"),
            _buildToggleItem(
              icon: Icons.dark_mode_outlined,
              title: "Dark mode",
              value: _darkMode,
              onChanged: (val) => setState(() => _darkMode = val),
            ),
            _buildToggleItem(
              icon: Icons.notifications_outlined,
              title: "Push notifications",
              value: _notifications,
              onChanged: (val) => setState(() => _notifications = val),
            ),
            _buildToggleItem(
              icon: Icons.lock_outline,
              title: "Private account",
              value: _privateAccount,
              onChanged: (val) => setState(() => _privateAccount = val),
            ),
            _buildToggleItem(
              icon: Icons.play_circle_outline,
              title: "Auto-play videos",
              value: _autoPlay,
              onChanged: (val) => setState(() => _autoPlay = val),
            ),
            _buildToggleItem(
              icon: Icons.data_saver_off_outlined,
              title: "Data saver",
              value: _dataSaver,
              onChanged: (val) => setState(() => _dataSaver = val),
            ),
            _buildMenuItem(
              icon: Icons.language,
              title: "Language",
              subtitle: "English",
              onTap: () => _showSnackBar("Language"),
            ),
            const SizedBox(height: 8),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
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
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white70, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
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
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white70, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFFF4FB3),
        activeTrackColor: const Color(0xFFFF4FB3).withOpacity(0.3),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Log out",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to log out?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar("Logged out");
            },
            child: const Text(
              "Log out",
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
