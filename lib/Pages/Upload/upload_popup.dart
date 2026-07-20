import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../Services/haptic_service.dart';
import '../../Services/filter_library.dart';
import 'widgets/vx_animated_logo.dart';
import 'widgets/upload_side_actions.dart';
import 'widgets/upload_bottom_controls.dart';
import 'widgets/vx_premium_loader.dart';
import 'video_preview_screen.dart';
import 'sound_picker_page.dart';
import '../../Services/sound_service.dart';

// ==================== POPUP ENTRY POINT ====================
Future<void> showUploadPopup(BuildContext context, {String? initialSound}) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Upload",
    barrierColor: Colors.black,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) {
      return FadeTransition(
        opacity: animation,
        child: VxUploadPopupContent(initialSound: initialSound),
      );
    },
  );
}

// ==================== POPUP CONTENT WIDGET ====================
class VxUploadPopupContent extends StatefulWidget {
  final String? initialSound;
  const VxUploadPopupContent({super.key, this.initialSound});

  @override
  State<VxUploadPopupContent> createState() => _VxUploadPopupContentState();
}

class _VxUploadPopupContentState extends State<VxUploadPopupContent>
    with TickerProviderStateMixin {
  CameraController? _controller;
  VideoPlayerController? _audioController;
  List<CameraDescription>? cameras;
  bool _isInitialized = false;
  bool _isRecording = false;
  int _selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.off;
  int _selectedFilterIndex = 0;
  final ImagePicker _picker = ImagePicker();
  double _audioVolume = 1.0;
  String? _selectedSoundTitle;
  String? _selectedSoundUrl;

  @override
  void initState() {
    super.initState();
    _selectedSoundTitle = widget.initialSound;
    // For demo, we assume a default URL if initialSound is provided
    if (_selectedSoundTitle != null) {
      _selectedSoundUrl = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3";
    }
    _initializeCamera();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    if (_selectedSoundUrl != null) {
      try {
        await _audioController?.dispose();
        _audioController = VideoPlayerController.networkUrl(
          Uri.parse(_selectedSoundUrl!),
        );
        await _audioController!.initialize();
        _audioController!.setLooping(true);
        _audioController!.setVolume(_audioVolume);
      } catch (e) {
        debugPrint("Audio Error: $e");
      }
    }
  }

  void _openSoundPicker() async {
    HapticService.impactLight();
    final VxSound? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SoundPickerPage()),
    );

    if (result != null) {
      setState(() {
        _selectedSoundTitle = result.title;
        _selectedSoundUrl = result.url;
      });
      await _initializeAudio();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(
          cameras![_selectedCameraIndex],
          ResolutionPreset.high,
          enableAudio: true, // Keep true to record ambient sound + music if desired
          imageFormatGroup: ImageFormatGroup.jpeg,
        );
        await _controller!.initialize();
        await _controller!.setFlashMode(_flashMode);
        
        if (!mounted) return;
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  Future<void> _toggleCamera() async {
    if (cameras == null || cameras!.length < 2) return;
    
    HapticService.impactLight();
    _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras!.length;
    
    setState(() => _isInitialized = false);
    await _controller?.dispose();
    await _initializeCamera();
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_isInitialized) return;
    
    HapticService.impactLight();
    setState(() {
      _flashMode = (_flashMode == FlashMode.off) ? FlashMode.torch : FlashMode.off;
    });
    await _controller!.setFlashMode(_flashMode);
  }

  Future<void> _handleRecording() async {
    if (_controller == null || !_isInitialized) return;

    if (_isRecording) {
      HapticService.impactHeavy();
      final XFile file = await _controller!.stopVideoRecording();
      
      // Stop Music
      if (_audioController != null && _audioController!.value.isInitialized) {
        await _audioController!.pause();
        await _audioController!.seekTo(Duration.zero);
      }

      setState(() => _isRecording = false);
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPreviewScreen(videoPath: file.path),
          ),
        );
      }
    } else {
      HapticService.impactMedium();
      await _controller!.startVideoRecording();
      
      // Start Music
      if (_audioController != null && _audioController!.value.isInitialized) {
        await _audioController!.play();
      }

      setState(() => _isRecording = true);
    }
  }

  Future<void> _pickFromGallery() async {
    HapticService.impactLight();
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPreviewScreen(videoPath: video.path),
          ),
        );
      }
    }
  }

  void _onVolumeChanged(double value) {
    setState(() => _audioVolume = value);
    _audioController?.setVolume(value);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _audioController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: VxPremiumLoader(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 9:16 Camera Preview
          SizedBox.expand(
            child: Container(
              color: Colors.black,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.matrix(
                      FilterLibrary.presets[_selectedFilterIndex].matrix,
                    ),
                    child: CameraPreview(_controller!),
                  ),
                ),
              ),
            ),
          ),

          // Premium Close Button
          Positioned(
            top: 60,
            left: 20,
            child: GestureDetector(
              onTap: () {
                HapticService.impactLight();
                Navigator.of(context).pop();
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      CupertinoIcons.xmark, 
                      color: Colors.white, 
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Selected Sound Pill (TikTok Style)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _openSoundPicker,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.music_note_2, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _selectedSoundTitle ?? "Add Sound",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(CupertinoIcons.chevron_right, color: Colors.white.withValues(alpha: 0.5), size: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Side Icons (Premium Glassmorphism Container)
          Positioned(
            top: 70,
            right: 15,
            child: UploadSideActions(
              flashMode: _flashMode,
              onToggleCamera: _toggleCamera,
              onToggleFlash: _toggleFlash,
              hasSound: _selectedSoundTitle != null,
              volume: _audioVolume,
              onVolumeChanged: _onVolumeChanged,
            ),
          ),

          // Bottom Controls (Integrated High-Fidelity Style)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: UploadBottomControls(
              isRecording: _isRecording,
              onRecordTap: _handleRecording,
              onGalleryTap: _pickFromGallery,
              selectedFilterIndex: _selectedFilterIndex,
              onFilterSelected: (index) {
                setState(() => _selectedFilterIndex = index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
