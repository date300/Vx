import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class UploadSideActions extends StatefulWidget {
  final FlashMode flashMode;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleFlash;
  final bool hasSound;
  final double volume;
  final Function(double) onVolumeChanged;

  const UploadSideActions({
    super.key,
    required this.flashMode,
    required this.onToggleCamera,
    required this.onToggleFlash,
    this.hasSound = false,
    this.volume = 1.0,
    required this.onVolumeChanged,
  });

  @override
  State<UploadSideActions> createState() => _UploadSideActionsState();
}

class _UploadSideActionsState extends State<UploadSideActions> {
  bool _showVolumeSlider = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_showVolumeSlider)
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 150,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFFFE2C55),
                        inactiveTrackColor: Colors.white24,
                        thumbColor: Colors.white,
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: widget.volume,
                        onChanged: widget.onVolumeChanged,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSideIcon(
                    CupertinoIcons.switch_camera, 
                    "Flip", 
                    onTap: widget.onToggleCamera
                  ),
                  _buildSideIcon(
                    widget.flashMode == FlashMode.off ? CupertinoIcons.bolt_slash_fill : CupertinoIcons.bolt_fill, 
                    "Flash", 
                    onTap: widget.onToggleFlash
                  ),
                  if (widget.hasSound)
                    _buildSideIcon(
                      _showVolumeSlider ? CupertinoIcons.speaker_3_fill : CupertinoIcons.music_note, 
                      "Volume",
                      onTap: () => setState(() => _showVolumeSlider = !_showVolumeSlider),
                      active: _showVolumeSlider,
                    ),
                  _buildSideIcon(CupertinoIcons.speedometer, "Speed"),
                  _buildSideIcon(CupertinoIcons.timer, "Timer"),
                  _buildSideIcon(CupertinoIcons.circle_grid_hex_fill, "Filters"),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideIcon(IconData icon, String label, {VoidCallback? onTap, bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          children: [
            Icon(
              icon, 
              color: active ? const Color(0xFFFE2C55) : Colors.white, 
              size: 26
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? const Color(0xFFFE2C55) : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
