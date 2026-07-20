import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../Services/sound_service.dart';
import '../../Services/haptic_service.dart';
import 'widgets/vx_premium_loader.dart';

class SoundPickerPage extends StatefulWidget {
  const SoundPickerPage({super.key});

  @override
  State<SoundPickerPage> createState() => _SoundPickerPageState();
}

class _SoundPickerPageState extends State<SoundPickerPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<VxSound> _sounds = [];
  bool _isLoading = true;
  String? _playingSoundId;
  VideoPlayerController? _previewController;

  @override
  void initState() {
    super.initState();
    _loadSounds();
  }

  void _loadSounds() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _sounds = SoundService.getTrendingSounds();
      _isLoading = false;
    });
  }

  void _search(String query) {
    setState(() {
      _sounds = SoundService.searchSounds(query);
    });
  }

  Future<void> _togglePreview(VxSound sound) async {
    if (_playingSoundId == sound.id) {
      await _previewController?.pause();
      setState(() => _playingSoundId = null);
      return;
    }

    HapticService.impactLight();
    await _previewController?.dispose();
    
    _previewController = VideoPlayerController.networkUrl(Uri.parse(sound.url));
    setState(() {
      _playingSoundId = sound.id;
    });

    await _previewController!.initialize();
    await _previewController!.play();
    _previewController!.setLooping(true);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _previewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
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
                  icon: Icon(CupertinoIcons.xmark, color: textColor),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  "Sounds",
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 18),
                ),
                centerTitle: true,
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: _search,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: "Search sounds...",
                            hintStyle: TextStyle(color: textColor.withValues(alpha: 0.3)),
                            prefixIcon: Icon(CupertinoIcons.search, color: textColor.withValues(alpha: 0.3), size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(child: VxPremiumLoader(color: Color(0xFFFE2C55))),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final sound = _sounds[index];
                        final isPlaying = _playingSoundId == sound.id;
                        return _buildSoundTile(sound, isPlaying, textColor, isDark);
                      },
                      childCount: _sounds.length,
                    ),
                  ),
                ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSoundTile(VxSound sound, bool isPlaying, Color textColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _togglePreview(sound),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Album Art
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    sound.coverUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                if (isPlaying)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(CupertinoIcons.pause_fill, color: Colors.white, size: 24),
                  )
                else
                  const Icon(CupertinoIcons.play_fill, color: Colors.white, size: 20),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sound.title,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sound.artist,
                    style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${sound.duration.inSeconds}s",
                    style: TextStyle(color: textColor.withValues(alpha: 0.3), fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Select Button
            GestureDetector(
              onTap: () {
                HapticService.impactMedium();
                Navigator.pop(context, sound);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFE2C55), Color(0xFFFF4FB3)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Use",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
