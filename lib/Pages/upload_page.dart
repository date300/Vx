import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:math' as math;

// ক্লাসের নাম পরিবর্তন করে UploadPage রাখা হয়েছে যাতে main_layout.dart এ কোনো পরিবর্তন না লাগে
class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isInitialized = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // ক্যামেরা সেটআপ লজিক
  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(
          cameras![0], // ব্যাক ক্যামেরা
          ResolutionPreset.high,
        );

        await _controller!.initialize();
        if (!mounted) return;
        setState(() {
          _isInitialized = true;
        });
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
    // ক্যামেরা লোড না হওয়া পর্যন্ত একটি ব্ল্যাক স্ক্রিন বা লোডিং দেখাবে
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
          // ১. ফুল স্ক্রিন ক্যামেরা প্রিভিউ
          SizedBox.expand(
            child: CameraPreview(_controller!),
          ),

          // ২. উপরের কন্ট্রোল বাটন ও Vx লোগো
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // স্ক্রিনের উপরে মাঝখানে Vx অ্যানিমেটেড লোগো
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(child: VxSmallAnimatedLogo()),
          ),

          // ৩. ডান পাশের মেনু (Flip, Flash, Filters)
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

          // ৪. নিচের রেকর্ড এবং আপলোড সেকশন
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // মোড সিলেক্টর
                const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
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
                    // ইফেক্ট বাটন
                    _buildBottomAction(Icons.sentiment_satisfied_alt, "Effects"),

                    // মেইন রেকর্ড বাটন (অ্যানিমেটেড)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isRecording = !_isRecording;
                        });
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

                    // গ্যালারি থেকে আপলোড করার বাটন
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

  // সাইড আইকন তৈরির হেল্পার উইজেট
  Widget _buildSideIcon(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // নিচের একশন বাটন তৈরির হেল্পার উইজেট
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
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

// ছোট অ্যানিমেটেড Vx লোগো উইজেট
class VxSmallAnimatedLogo extends StatefulWidget {
  const VxSmallAnimatedLogo({super.key});

  @override
  State<VxSmallAnimatedLogo> createState() => _VxSmallAnimatedLogoState();
}

class _VxSmallAnimatedLogoState extends State<VxSmallAnimatedLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
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
        return Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: const [Colors.blueAccent, Colors.pinkAccent, Colors.blueAccent],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
          ),
          child: Center(
            child: Container(
              width: 41,
              height: 41,
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: const Center(
                child: Text("Vx", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        );
      },
    );
  }
}
