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

  const UploadBottomControls({
    super.key,
    required this.isRecording,
    required this.onRecordTap,
    required this.onGalleryTap,
    required this.selectedFilterIndex,
    required this.onFilterSelected,
  });

  @override
  State<UploadBottomControls> createState() => _UploadBottomControlsState();
}

class _UploadBottomControlsState extends State<UploadBottomControls> {
  int _selectedModeIndex = 1; // Default to "Video"
  final List<String> _modes = ["Story", "Video", "Photo", "Template"];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Action Row (Effects, Record, Upload)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionIcon(Icons.sentiment_satisfied_alt, "Effects"),
                
                // Record Button
                GestureDetector(
                  onTap: widget.onRecordTap,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: widget.isRecording ? 35 : 68,
                        height: widget.isRecording ? 35 : 68,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(widget.isRecording ? 8 : 50),
                        ),
                      ),
                    ],
                  ),
                ),

                _buildActionIcon(CupertinoIcons.photo, "Upload", onTap: widget.onGalleryTap),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // 2. Mode Selector (TikTok Style)
          SizedBox(
            height: 30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _modes.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Centered look
              itemBuilder: (context, index) {
                final isSelected = _selectedModeIndex == index;
                return GestureDetector(
                  onTap: () {
                    HapticService.impactLight();
                    setState(() => _selectedModeIndex = index);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      _modes[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // 3. Filter Selector Row (Always Visible)
          SizedBox(
            height: 75,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
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
                    width: 65,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: preset.previewColor,
                            border: Border.all(
                              color: isSelected ? Colors.redAccent : Colors.white24,
                              width: isSelected ? 3 : 1,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: Colors.redAccent.withValues(alpha: 0.5),
                                blurRadius: 8,
                              )
                            ] : [],
                          ),
                          child: isSelected 
                              ? const Icon(Icons.check, color: Colors.white, size: 20) 
                              : null,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          preset.name,
                          style: TextStyle(
                            color: isSelected ? Colors.redAccent : Colors.white70,
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
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
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}
