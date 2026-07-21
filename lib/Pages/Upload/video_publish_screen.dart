import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../Core/constants.dart' as constants;
import '../../Services/haptic_service.dart';
import '../Home/home_provider.dart';
import 'widgets/vx_premium_loader.dart';
import '../../Services/draft_service.dart';
import '../../Services/auth_service.dart';

class VideoPublishScreen extends StatefulWidget {
  final String videoPath;
  final List<String>? imagePaths;
  final VideoDraft? draft;
  final bool isImage;
  final bool isStory;
  final int? soundId;
  final String? soundTitle;

  const VideoPublishScreen({
    super.key,
    required this.videoPath,
    this.imagePaths,
    this.draft,
    this.isImage = false,
    this.isStory = false,
    this.soundId,
    this.soundTitle,
  });

  @override
  State<VideoPublishScreen> createState() => _VideoPublishScreenState();
}

class _VideoPublishScreenState extends State<VideoPublishScreen> {
  late TextEditingController _captionController;
  late VideoPlayerController _videoController;
  
  bool _isUploading = false;
  bool _allowComments = true;
  String _privacySetting = "Public";
  late double _coverTimestamp;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.draft?.caption ?? "");
    _coverTimestamp = widget.draft?.coverTimestamp ?? 0.0;

    if (!widget.isImage) {
      _videoController = VideoPlayerController.file(File(widget.videoPath))
        ..initialize().then((_) {
          if (_coverTimestamp > 0) {
            _videoController.seekTo(Duration(milliseconds: _coverTimestamp.toInt()));
          }
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    if (!widget.isImage) {
      _videoController.dispose();
    }
    super.dispose();
  }

  Future<void> _handlePost() async {
    setState(() => _isUploading = true);
    HapticService.impactMedium();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login first")));
        }
        setState(() => _isUploading = false);
        return;
      }

      final uri = Uri.parse('${constants.baseUrl}/upload/video');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      
      if (widget.imagePaths != null && widget.imagePaths!.isNotEmpty) {
        for (var path in widget.imagePaths!) {
          request.files.add(await http.MultipartFile.fromPath('images', path));
        }
        request.fields['is_image'] = 'true';
      } else {
        request.files.add(await http.MultipartFile.fromPath('video', widget.videoPath));
        if (widget.isImage) {
          request.fields['is_image'] = 'true';
        }
      }

      if (widget.isStory) {
        request.fields['is_story'] = 'true';
      }

      if (widget.soundId != null) {
        request.fields['sound_id'] = widget.soundId.toString();
      } else if (widget.soundTitle != null) {
        request.fields['sound'] = widget.soundTitle!;
      }
      
      final caption = _captionController.text;
      final hashtags = _extractHashtags(caption);
      
      if (caption.isNotEmpty) request.fields['caption'] = caption;
      if (hashtags.isNotEmpty) request.fields['hashtags'] = hashtags.join(',');
      
      // Send cover timestamp in seconds (FFmpeg format)
      final coverSeconds = _coverTimestamp / 1000.0;
      request.fields['cover_timestamp'] = coverSeconds.toStringAsFixed(3);

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      
      if (response.statusCode == 401) {
        if (mounted) {
          AuthService.handleUnauthorized(context);
        }
        return;
      }

      Map<String, dynamic>? result;
      if (response.statusCode == 201 || response.statusCode == 200) {
        result = json.decode(response.body);
      }

      if (!mounted) return;

      if (result != null) {
        if (mounted) {
      context.read<HomeProvider>().fetchHomeFeed(refresh: true, context: context);
      Navigator.popUntil(context, (route) => route.isFirst);
    }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Video posted successfully! 🚀")));
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post failed. Please try again.")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _handleDraft() async {
    HapticService.impactMedium();
    setState(() => _isUploading = true);

    try {
      final draft = VideoDraft(
        id: widget.draft?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        videoPath: widget.videoPath,
        caption: _captionController.text,
        coverTimestamp: _coverTimestamp,
        createdAt: DateTime.now(),
      );

      await DraftService.saveDraft(draft);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Saved to drafts! 📂")),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save draft: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  List<String> _extractHashtags(String text) {
    final exp = RegExp(r"\B#\w\w+");
    return exp.allMatches(text).map((m) => m.group(0)!.substring(1)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF8F9FA);
    final cardColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Text("Post", style: TextStyle(color: textColor, fontWeight: FontWeight.w900)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: textColor, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Caption + Thumbnail Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _captionController,
                          maxLines: 6,
                          style: TextStyle(color: textColor, fontSize: 15),
                          decoration: InputDecoration(
                            hintText: "Write a caption...",
                            hintStyle: TextStyle(color: textColor.withValues(alpha: 0.3)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Thumbnail Preview with "Select cover" overlay
                      GestureDetector(
                        onTap: widget.isImage ? null : _showCoverSelector,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              width: 100,
                              height: 140,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black : Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: widget.isImage 
                                  ? Image.file(File(widget.videoPath), fit: BoxFit.cover)
                                  : _videoController.value.isInitialized
                                      ? Center(
                                          child: AspectRatio(
                                            aspectRatio: _videoController.value.aspectRatio,
                                            child: VideoPlayer(_videoController),
                                          ),
                                        )
                                      : const Center(child: VxPremiumLoader(size: 3)),
                            ),
                            if (!widget.isImage)
                              Container(
                                width: 100,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                                ),
                                child: const Text(
                                  "Select cover",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Settings Group
                Text("SETTINGS", style: TextStyle(color: textColor.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    children: [
                      _buildSettingItem(
                        icon: CupertinoIcons.person_2,
                        title: "Who can watch",
                        trailingText: _privacySetting,
                        onTap: _showPrivacyPicker,
                        isDark: isDark,
                      ),
                      _divider(isDark),
                      _buildSettingItem(
                        icon: CupertinoIcons.chat_bubble_2,
                        title: "Allow comments",
                        trailing: CupertinoSwitch(
                          value: _allowComments,
                          activeTrackColor: const Color(0xFFFE2C55),
                          onChanged: (v) => setState(() => _allowComments = v),
                        ),
                        isDark: isDark,
                      ),
                      _divider(isDark),
                      _buildSettingItem(
                        icon: CupertinoIcons.repeat,
                        title: "Allow Duet & Stitch",
                        trailing: const CupertinoSwitch(value: true, activeTrackColor: Color(0xFFFE2C55), onChanged: null),
                        isDark: isDark,
                      ),
                      _divider(isDark),
                      _buildSettingItem(
                        icon: CupertinoIcons.cloud_download,
                        title: "Save to device",
                        trailing: const CupertinoSwitch(value: true, activeTrackColor: Color(0xFFFE2C55), onChanged: null),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 150),
              ],
            ),
          ),

          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
                  decoration: BoxDecoration(
                    color: bgColor.withValues(alpha: 0.8),
                    border: Border(top: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05))),
                  ),
                  child: Row(
                    children: [
                      // Drafts Button
                      Expanded(
                        child: GestureDetector(
                          onTap: _isUploading ? null : _handleDraft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.archivebox, color: textColor, size: 20),
                                const SizedBox(width: 8),
                                Text("Drafts", style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Post Button
                      Expanded(
                        child: GestureDetector(
                          onTap: _isUploading ? null : _handlePost,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFFE2C55), Color(0xFFFF4FB3)]),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFE2C55).withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(CupertinoIcons.paperplane_fill, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _isUploading ? "Posting..." : "Post",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_isUploading)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: const Center(child: VxPremiumLoader(color: Color(0xFFFE2C55))),
            ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) => Divider(height: 1, indent: 56, color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03));

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? trailingText,
    Widget? trailing,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    final textColor = isDark ? Colors.white : Colors.black;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (trailing is CupertinoSwitch) ? const Color(0xFFFE2C55).withValues(alpha: 0.1) : textColor.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: (trailing is CupertinoSwitch) ? const Color(0xFFFE2C55) : textColor.withValues(alpha: 0.7), size: 20),
      ),
      title: Text(title, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600)),
      trailing: trailing ?? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: TextStyle(color: textColor.withValues(alpha: 0.4), fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Icon(CupertinoIcons.chevron_right, color: textColor.withValues(alpha: 0.2), size: 16),
        ],
      ),
      onTap: onTap,
    );
  }

  void _showCoverSelector() {
    HapticService.impactLight();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text("Select cover", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: AspectRatio(
                                aspectRatio: _videoController.value.aspectRatio,
                                child: VideoPlayer(_videoController),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFFFE2C55),
                                inactiveTrackColor: Colors.white24,
                                thumbColor: Colors.white,
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: _coverTimestamp,
                                min: 0.0,
                                max: _videoController.value.duration.inMilliseconds.toDouble(),
                                onChanged: (v) {
                                  setModalState(() => _coverTimestamp = v);
                                  setState(() => _coverTimestamp = v);
                                  _videoController.seekTo(Duration(milliseconds: v.toInt()));
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text("Drag to pick a cover frame", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFFFE2C55), Color(0xFFFF4FB3)]),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Center(child: Text("Confirm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPrivacyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Text("Who can watch", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 16),
              _privacyOption("Public", "Everyone can see this video"),
              _privacyOption("Friends", "Followers you follow back"),
              _privacyOption("Private", "Only you can see this video"),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _privacyOption(String title, String subtitle) {
    final isSelected = _privacySetting == title;
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: isSelected ? const Icon(CupertinoIcons.check_mark_circled, color: Color(0xFFFE2C55)) : null,
      onTap: () {
        setState(() => _privacySetting = title);
        Navigator.pop(context);
      },
    );
  }
}
