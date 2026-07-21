import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vx/Api/Explore/explore_api.dart';
import 'package:vx/Services/auth_service.dart';
import '../../Layout/theme_provider.dart';
import '../Upload/upload_popup.dart';
import 'models/video_data.dart';
import 'home_provider.dart';
import '../Upload/widgets/vx_premium_loader.dart';

class SoundDetailPage extends StatefulWidget {
  final int? soundId;
  final String soundTitle;
  final String username;

  const SoundDetailPage({
    super.key,
    this.soundId,
    required this.soundTitle,
    required this.username,
  });

  @override
  State<SoundDetailPage> createState() => _SoundDetailPageState();
}

class _SoundDetailPageState extends State<SoundDetailPage> {
  bool _isLoading = true;
  SoundData? _soundDetails;
  List<VideoData> _videos = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (widget.soundId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final token = await AuthService.getToken();
      final response = await ExploreApi.getSoundDetails(widget.soundId!, token: token);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        if (mounted) {
          setState(() {
            _soundDetails = SoundData.fromJson(data['sound']);
            if (data['videos'] != null) {
              _videos = (data['videos'] as List)
                  .map((v) => VideoData.fromJson(v))
                  .toList();
            }
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = data['message'] ?? "Failed to load sound details";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Error: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    bool isDark = themeProvider.themeMode == ThemeMode.dark;
    if (themeProvider.themeMode == ThemeMode.system) {
      isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    }

    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium App Bar
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: bgColor.withValues(alpha: 0.8),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
            leading: IconButton(
              icon: Icon(CupertinoIcons.back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(CupertinoIcons.share, color: textColor),
                onPressed: () {},
              ),
            ],
            title: Text(
              "Sound",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),

          // Sound Header Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spinning Disc / Album Art
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2A2A2A), Color(0xFF111111)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFE2C55).withValues(alpha: 0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: _soundDetails?.authorAvatar.isNotEmpty == true
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: _soundDetails!.authorAvatar,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : null,
                      ),
                      if (_soundDetails == null || _soundDetails!.authorAvatar.isEmpty)
                        const Icon(CupertinoIcons.music_note_2, color: Colors.white, size: 40),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _soundDetails?.title ?? widget.soundTitle,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _soundDetails?.authorName ?? widget.username,
                          style: TextStyle(
                            color: subColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              "${_videos.length} videos",
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Add to Favorites Button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: textColor.withValues(alpha: 0.1)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.bookmark, size: 16, color: textColor),
                              const SizedBox(width: 8),
                              Text(
                                "Add to Favorites",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // Video Grid
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: VxPremiumLoader(color: Color(0xFFFE2C55)),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Text(_error!, style: const TextStyle(color: Colors.white70)),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 1.5,
                  mainAxisSpacing: 1.5,
                  childAspectRatio: 3 / 4,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final video = _videos[index];
                    return GestureDetector(
                      onTap: () {
                        // In a real app, open the video viewer starting at this index
                      },
                      child: Container(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: video.thumbnailUrl.isNotEmpty ? video.thumbnailUrl : video.avatarUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.white.withValues(alpha: 0.05)),
                              errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
                            ),
                            Positioned(
                              bottom: 6,
                              left: 6,
                              child: Row(
                                children: [
                                  const Icon(CupertinoIcons.play_fill, color: Colors.white, size: 12),
                                  const SizedBox(width: 2),
                                  Text(
                                    "${video.views}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _videos.length,
                ),
              ),
            ),

          // Padding for FAB
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: GestureDetector(
          onTap: () => showUploadPopup(
            context, 
            initialSound: _soundDetails?.title ?? widget.soundTitle,
            initialSoundId: _soundDetails?.id,
          ),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFE2C55), Color(0xFFFF4FB3)],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFE2C55).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.videocam_fill, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Text(
                  "Use this sound",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
