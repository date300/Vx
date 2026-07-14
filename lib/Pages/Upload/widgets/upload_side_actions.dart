import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class UploadSideActions extends StatelessWidget {
  final FlashMode flashMode;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleFlash;

  const UploadSideActions({
    super.key,
    required this.flashMode,
    required this.onToggleCamera,
    required this.onToggleFlash,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSideIcon(
          CupertinoIcons.switch_camera, 
          "Flip", 
          onTap: onToggleCamera
        ),
        _buildSideIcon(
          flashMode == FlashMode.off ? CupertinoIcons.bolt_slash_fill : CupertinoIcons.bolt_fill, 
          "Flash", 
          onTap: onToggleFlash
        ),
        _buildSideIcon(CupertinoIcons.speedometer, "Speed"),
        _buildSideIcon(CupertinoIcons.timer, "Timer"),
      ],
    );
  }

  Widget _buildSideIcon(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
