import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../Services/haptic_service.dart';
import '../../Services/native_service.dart';
import '../../Services/filter_library.dart';
import 'widgets/vx_animated_logo.dart';
import 'widgets/upload_side_actions.dart';
import 'widgets/upload_bottom_controls.dart';

// ==================== POPUP ENTRY POINT ====================
void showUploadPopup(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Upload",
    barrierColor: Colors.black,
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
  int _selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.off;
  int _selectedFilterIndex = 0;
  final ImagePicker _picker = ImagePicker();

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
          cameras![_selectedCameraIndex],
          ResolutionPreset.high,
          enableAudio: true,
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
      setState(() => _isRecording = false);
      debugPrint("Video recorded to: ${file.path}");
    } else {
      HapticService.impactMedium();
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  Future<void> _pickFromGallery() async {
    HapticService.impactLight();
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      debugPrint("Video picked: ${video.path}");
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
          // 9:16 Camera Preview (TikTok Style)
          SizedBox.expand(
            child: Center(
              child: Builder(
                builder: (context) {
                  final size = MediaQuery.of(context).size;
                  final outWidthPtr = calloc<Double>();
                  final outHeightPtr = calloc<Double>();

                  try {
                    // Use Native C++ to calculate standard 9:16 dimensions
                    nativeService.calculateVideoDimensions(
                      1080, 1920, // Target 9:16
                      size.width, size.height,
                      outWidthPtr, outHeightPtr,
                    );

                    return SizedBox(
                      width: outWidthPtr.value,
                      height: outHeightPtr.value,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(
                          FilterLibrary.presets[_selectedFilterIndex].matrix,
                        ),
                        child: CameraPreview(_controller!),
                      ),
                    );
                  } finally {
                    calloc.free(outWidthPtr);
                    calloc.free(outHeightPtr);
                  }
                },
              ),
            ),
          ),

          // Close Button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                HapticService.impactLight();
                Navigator.of(context).pop();
              },
            ),
          ),

          // Vx Logo
          const Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(child: VxSmallAnimatedLogo()),
          ),

          // Side Icons (Filters button removed here, moved to bottom)
          Positioned(
            top: 60,
            right: 15,
            child: UploadSideActions(
              flashMode: _flashMode,
              onToggleCamera: _toggleCamera,
              onToggleFlash: _toggleFlash,
            ),
          ),

          // Bottom Controls (Integrated TikTok Style)
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
