import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class TikTokUploadPage extends StatefulWidget {
  const TikTokUploadPage({super.key});

  @override
  State<TikTokUploadPage> createState() => _TikTokUploadPageState();
}

class _TikTokUploadPageState extends State<TikTokUploadPage> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isInitialized = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // ক্যামেরা সেটআপ করার লজিক
  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _controller = CameraController(
        cameras![0], // পেছনের ক্যামেরা
        ResolutionPreset.high,
      );

      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
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
          // ১. লাইভ ক্যামেরা প্রিভিউ
          SizedBox.expand(
            child: CameraPreview(_controller!),
          ),

          // ২. উপরের কন্ট্রোল বাটন (Close & Music)
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.music_note, color: Colors.white, size: 18),
                      SizedBox(width: 5),
                      Text("Add Sound", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ৩. ডান পাশের সাইডবার (Filters, Flip, Speed)
          Positioned(
            top: 60,
            right: 15,
            child: Column(
              children: [
                _buildSideIcon(CupertinoIcons.switch_camera, "Flip"),
                _buildSideIcon(CupertinoIcons.bolt_fill, "Flash"),
                _buildSideIcon(CupertinoIcons.speedometer, "Speed"),
                _buildSideIcon(CupertinoIcons.wand_stars, "Filters"),
                _buildSideIcon(CupertinoIcons.timer, "Timer"),
              ],
            ),
          ),

          // ৪. নিচের রেকর্ড সেকশন (Record Button, Gallery, Effects)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // মোড সিলেকশন
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
                    _buildBottomAction(CupertinoIcons.face_smiling, "Effects"),

                    // মেইন রেকর্ড বাটন
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

                    // গ্যালারি বাটন
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

  // ডান পাশের ছোট আইকন তৈরির ফাংশন
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

  // নিচের গ্যালারি ও ইফেক্ট বাটন তৈরির ফাংশন
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
