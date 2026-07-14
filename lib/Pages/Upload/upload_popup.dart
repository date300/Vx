import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:math' as math;
import '../../Services/native_service.dart';

// ==================== POPUP ENTRY POINT ====================
// যেকোনো জায়গা থেকে এভাবে কল করুন: showUploadPopup(context);
void showUploadPopup(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,      // বাইরে ট্যাপ করলে বন্ধ হবে
    barrierColor: Colors.black,     // ব্যাকগ্রাউন্ড কালো
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const VxUploadPopupContent();
    },
  );
}

// ==================== POPUP CONTENT WIDGET ====================
class VxUploadPopupContent extends StatefulWidget {
  const VxUploadPopupContent({super.key});

  @override
  State<VxUploadPopupContent> createState() => _VxUploadPopupContentState();
}

class _VxUploadPopupContentState extends State<VxUploadPopupContent>
    with TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isInitialized = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(
          cameras![0],
          ResolutionPreset.high,
        );
        await _controller!.initialize();
        if (!mounted) return;
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          SizedBox.expand(
            child: CameraPreview(_controller!),
          ),

          // Close Button (Popup বন্ধ করবে)
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(), // পপআপ বন্ধ
            ),
          ),

          // Vx Logo
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(child: VxSmallAnimatedLogo()),
          ),

          // Side Icons (Flip, Flash, etc.)
          Positioned(
            top: 60,
            right: 15,
            child: Column(
              children: [
                _buildSideIcon(CupertinoIcons.switch_camera, "Flip"),
                _buildSideIcon(CupertinoIcons.bolt_fill, "Flash"),
                _buildSideIcon(CupertinoIcons.speedometer, "Speed"),
                _buildSideIcon(Icons.filter_vintage_outlined, "Filters"),
                _buildSideIcon(CupertinoIcons.timer, "Timer"),
              ],
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Mode Selector
                const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Story", style: TextStyle(color: Colors.white54)),
                      SizedBox(width: 20),
                      Text("Video", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(width: 20),
                      Text("Photo", style: TextStyle(color: Colors.white54)),
                      SizedBox(width: 20),
                      Text("Template", style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Effects
                    _buildBottomAction(Icons.sentiment_satisfied_alt, "Effects"),

                    // Record Button
                    GestureDetector(
                      onTap: () {
                        setState(() => _isRecording = !_isRecording);
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 85,
                            height: 85,
                            decoration: const BoxDecoration(
                              color: Colors.white30,
                              shape: BoxShape.circle,
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: _isRecording ? 40 : 70,
                            height: _isRecording ? 40 : 70,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(_isRecording ? 8 : 50),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Upload
                    _buildBottomAction(CupertinoIcons.photo, "Upload"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideIcon(IconData icon, String label) {
    return Padding(
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
    );
  }

  Widget _buildBottomAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}

// ==================== ANIMATED LOGO ====================
class VxSmallAnimatedLogo extends StatefulWidget {
  const VxSmallAnimatedLogo({super.key});

  @override
  State<VxSmallAnimatedLogo> createState() => _VxSmallAnimatedLogoState();
}

class _VxSmallAnimatedLogoState extends State<VxSmallAnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Use C++ fast math for even smoother rotation values if needed
        // nativeService.fastLerp could be used for advanced easing
        return Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: const [
                Colors.blueAccent,
                Colors.pinkAccent,
                Colors.blueAccent,
              ],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
          ),
          child: Center(
            child: Container(
              width: 41,
              height: 41,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  "Vx",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
