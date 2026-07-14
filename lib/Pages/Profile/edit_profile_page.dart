import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Layout/theme_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController(text: "Vx User");
  final TextEditingController _usernameController = TextEditingController(text: "vx_user_pro");
  final TextEditingController _bioController = TextEditingController(text: "Building the future of short-video apps 🚀\nC++ Native Engine Powered");

  bool _isDark(BuildContext context) {
    final mode = context.read<ThemeProvider>().themeMode;
    if (mode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return mode == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final isDark = _isDark(context);

    final bgColor = isDark ? Colors.black : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.white54 : Colors.black54;
    final borderColor = isDark ? Colors.white12 : Colors.black12;
    final highlightColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: titleColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit profile",
          style: TextStyle(color: titleColor, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Save logic
              Navigator.pop(context);
            },
            child: Text(
              "Save",
              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // ── Profile Photo ──
            _buildPhotoSection(titleColor, subtitleColor),
            const SizedBox(height: 30),

            // ── Fields ──
            _buildEditField(
              label: "Name",
              controller: _nameController,
              titleColor: titleColor,
              borderColor: borderColor,
            ),
            _buildEditField(
              label: "Username",
              controller: _usernameController,
              titleColor: titleColor,
              borderColor: borderColor,
              prefix: "vx.com/",
            ),
            _buildEditField(
              label: "Bio",
              controller: _bioController,
              titleColor: titleColor,
              borderColor: borderColor,
              maxLines: 3,
            ),

            const SizedBox(height: 20),
            Divider(color: borderColor, thickness: 0.5),
            const SizedBox(height: 10),

            // ── Social ──
            _buildSectionHeader("Social", subtitleColor),
            _buildEditField(
              label: "Instagram",
              placeholder: "Add Instagram to your profile",
              titleColor: titleColor,
              borderColor: borderColor,
            ),
            _buildEditField(
              label: "YouTube",
              placeholder: "Add YouTube to your profile",
              titleColor: titleColor,
              borderColor: borderColor,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(Color titleColor, Color subtitleColor) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: titleColor.withValues(alpha: 0.1),
                image: const DecorationImage(
                  image: NetworkImage("https://picsum.photos/200"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.3),
              ),
              child: const Icon(CupertinoIcons.camera, color: Colors.white, size: 30),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "Change photo",
          style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color subtitleColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(color: subtitleColor, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField({
    required String label,
    TextEditingController? controller,
    String? placeholder,
    required Color titleColor,
    required Color borderColor,
    String? prefix,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: titleColor, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              style: TextStyle(color: titleColor, fontSize: 15),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(color: titleColor.withValues(alpha: 0.3), fontSize: 15),
                prefixText: prefix,
                prefixStyle: TextStyle(color: titleColor.withValues(alpha: 0.4), fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: titleColor.withValues(alpha: 0.2), size: 14),
        ],
      ),
    );
  }
}
