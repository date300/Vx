import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Services/filter_library.dart';
import '../../../Services/haptic_service.dart';

class UploadBottomControls extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onRecordTap;
  final VoidCallback onGalleryTap;
  final int selectedFilterIndex;
  final Function(int) onFilterSelected;
  final Function(int) onModeChanged;

  const UploadBottomControls({
    super.key,
    required this.isRecording,
    required this.onRecordTap,
    required this.onGalleryTap,
    required this.selectedFilterIndex,
    required this.onFilterSelected,
    required this.onModeChanged,
  });

  @override
  State<UploadBottomControls> createState() => _UploadBottomControlsState();
}

class _UploadBottomControlsState extends State<UploadBottomControls> {
  int _selectedModeIndex = 1; // Default to "Video"
  final List<String> _modes = ["Story", "Video", "Photo", "Template"];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.only(bottom: 30, top: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.2),
                Colors.black.withValues(alpha: 0.8),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Filter Selector Row (Premium Horizontal List)
              SizedBox(
                height: 85,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: FilterLibrary.presets.length,
                  itemBuilder: (context, index) {
                    final preset = FilterLibrary.presets[index];
                    final isSelected = widget.selectedFilterIndex == index;
                    return GestureDetector(
                      onTap: () {
                        HapticService.impactLight();
                        widget.onFilterSelected(index);
                      },
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 14),
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: isSelected ? 54 : 48,
                              height: isSelected ? 54 : 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: preset.previewColor,
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFFE2C55) : Colors.white.withValues(alpha: 0.2),
                                  width: isSelected ? 3 : 1.5,
                                ),
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: const Color(0xFFFE2C55).withValues(alpha: 0.4),
                                    blurRadius: 10,
                                  )
                                ] : [],
                              ),
                              child: isSelected 
                                  ? const Icon(CupertinoIcons.checkmark_alt, color: Colors.white, size: 22) 
                                  : null,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              preset.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // 2. Action Row (Effects, Record, Upload)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildActionIcon(CupertinoIcons.sparkles, "Effects"),
                    
                    // Premium Record Button
                    GestureDetector(
                      onTap: widget.onRecordTap,
                      child: SizedBox(
                        width: 90,
                        height: 90,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer Ring with Brand Gradient
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 4,
                                ),
                              ),
                            ),
                            // Gradient Indicator
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFFFE2C55), Color(0xFFFF4FB3)],
                              ).createShader(bounds),
                              child: Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                ),
                              ),
                            ),
                            // Inner Button
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOutBack,
                              width: widget.isRecording ? 32 : 70,
                              height: widget.isRecording ? 32 : 70,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFE2C55),
                                borderRadius: BorderRadius.circular(widget.isRecording ? 8 : 50),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFE2C55).withValues(alpha: 0.3),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    _buildActionIcon(CupertinoIcons.photo_on_rectangle, "Gallery", onTap: widget.onGalleryTap),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 3. Mode Selector (Premium X/TikTok Style)
              SizedBox(
                height: 35,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 150),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_modes.length, (index) {
                          final isSelected = _selectedModeIndex == index;
                          return GestureDetector(
                            onTap: () {
                              HapticService.impactLight();
                              setState(() => _selectedModeIndex = index);
                              widget.onModeChanged(index);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              child: Text(
                                _modes[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
                                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    // Active Indicator Dot
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFE2C55),
                          shape: BoxShape.circle,
                        ),
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
  }

  Widget _buildActionIcon(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              label, 
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
