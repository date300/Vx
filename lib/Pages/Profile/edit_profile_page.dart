import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Layout/theme_provider.dart';
import 'profile_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _instagramController;
  late final TextEditingController _youtubeController;
  late final TextEditingController _facebookController;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().userProfile ?? {};
    _nameController = TextEditingController(text: profile['nickname'] ?? "");
    _usernameController = TextEditingController(text: profile['username'] ?? "");
    _bioController = TextEditingController(text: profile['bio'] ?? "");
    _instagramController = TextEditingController(text: profile['instagram_url'] ?? "");
    _youtubeController = TextEditingController(text: profile['youtube_url'] ?? "");
    _facebookController = TextEditingController(text: profile['facebook_url'] ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> _pickAndUploadAvatar() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null || !mounted) return;

    final provider = context.read<ProfileProvider>();
    final token = await _getToken();
    if (token.isEmpty || !mounted) return;

    final success = await provider.uploadAvatar(token, File(picked.path));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Profile photo updated" : (provider.errorMessage ?? "Upload failed")),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.black87,
        ),
      );
    }
  }

  Future<void> _pickAndUploadCover() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null || !mounted) return;

    final provider = context.read<ProfileProvider>();
    final token = await _getToken();
    if (token.isEmpty || !mounted) return;

    final success = await provider.uploadCover(token, File(picked.path));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Cover photo updated" : (provider.errorMessage ?? "Upload failed")),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.black87,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    final provider = context.read<ProfileProvider>();
    final token = await _getToken();

    if (token.isEmpty || !mounted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Not logged in")),
        );
      }
      return;
    }

    final success = await provider.updateProfile(
      token: token,
      nickname: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      bio: _bioController.text.trim(),
      instagramUrl: _instagramController.text.trim(),
      youtubeUrl: _youtubeController.text.trim(),
      facebookUrl: _facebookController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Profile updated successfully! ✨"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: const Color(0xFFFE2C55),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? "Update failed"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

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

    final bgColor = isDark ? Colors.black : const Color(0xFFF8F8F8);
    final titleColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.white54 : Colors.black54;
    final cardColor = isDark ? const Color(0xFF121212) : Colors.white;

    final profile = context.watch<ProfileProvider>().userProfile ?? {};

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.xmark, color: titleColor, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit profile",
          style: TextStyle(color: titleColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        actions: [
          Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              return provider.isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: CupertinoActivityIndicator(),
                      ),
                    )
                  : TextButton(
                      onPressed: _saveProfile,
                      child: const Text(
                        "Save",
                        style: TextStyle(
                            color: Color(0xFFFE2C55),
                            fontWeight: FontWeight.w900,
                            fontSize: 16),
                      ),
                    );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 25),
            // ── Photos Section ──
            Consumer<ProfileProvider>(
              builder: (context, provider, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPhotoSection(
                      label: "Change photo",
                      imageUrl: profile['avatar_url'],
                      titleColor: titleColor,
                      isCircle: true,
                      isUploading: provider.isUploadingAvatar,
                      onTap: _pickAndUploadAvatar,
                    ),
                    _buildPhotoSection(
                      label: "Change cover",
                      imageUrl: profile['cover_url'],
                      titleColor: titleColor,
                      isCircle: false,
                      isUploading: provider.isUploadingCover,
                      onTap: _pickAndUploadCover,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),

            // ── Account Info ──
            _buildSectionHeader("BASIC INFO", subtitleColor),
            _buildModernContainer(cardColor, isDark, [
              _buildModernEditField(
                label: "Name",
                controller: _nameController,
                titleColor: titleColor,
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildModernEditField(
                label: "Username",
                controller: _usernameController,
                titleColor: titleColor,
                prefix: "vx.com/",
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildModernEditField(
                label: "Bio",
                controller: _bioController,
                titleColor: titleColor,
                maxLines: 3,
                isDark: isDark,
              ),
            ]),

            const SizedBox(height: 30),

            // ── Social ──
            _buildSectionHeader("SOCIAL", subtitleColor),
            _buildModernContainer(cardColor, isDark, [
              _buildModernEditField(
                label: "Instagram",
                placeholder: "Add Instagram link",
                controller: _instagramController,
                titleColor: titleColor,
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildModernEditField(
                label: "YouTube",
                placeholder: "Add YouTube link",
                controller: _youtubeController,
                titleColor: titleColor,
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildModernEditField(
                label: "Facebook",
                placeholder: "Add Facebook link",
                controller: _facebookController,
                titleColor: titleColor,
                isDark: isDark,
              ),
            ]),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection({
    required String label,
    required String? imageUrl,
    required Color titleColor,
    required bool isUploading,
    required VoidCallback onTap,
    bool isCircle = true,
  }) {
    final hasUrl = imageUrl != null && imageUrl.isNotEmpty;
    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: isCircle ? null : BorderRadius.circular(16),
                  color: titleColor.withValues(alpha: 0.05),
                  border: Border.all(color: titleColor.withValues(alpha: 0.08), width: 1),
                  image: hasUrl
                      ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: !hasUrl
                    ? Icon(
                        isCircle ? CupertinoIcons.person_fill : CupertinoIcons.photo,
                        color: titleColor.withValues(alpha: 0.2),
                        size: 40,
                      )
                    : null,
              ),
              // Glassmorphism Overlay
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: isCircle ? null : BorderRadius.circular(16),
                  color: Colors.black.withValues(alpha: 0.35),
                ),
                child: isUploading
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : const Icon(CupertinoIcons.camera_fill, color: Colors.white, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: TextStyle(color: titleColor, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color subtitleColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(color: subtitleColor, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildModernContainer(Color cardColor, bool isDark, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildModernEditField({
    required String label,
    required TextEditingController controller,
    String? placeholder,
    required Color titleColor,
    required bool isDark,
    String? prefix,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(color: titleColor, fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              style: TextStyle(color: titleColor, fontSize: 15, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(color: titleColor.withValues(alpha: 0.3), fontSize: 15),
                prefixText: prefix,
                prefixStyle: TextStyle(color: const Color(0xFFFE2C55).withValues(alpha: 0.6), fontSize: 15, fontWeight: FontWeight.w600),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
    );
  }
}
