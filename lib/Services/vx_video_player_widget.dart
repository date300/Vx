import 'dart:async';
import 'package:flutter/material.dart';
import 'vx_video_player.dart';
import 'native_service.dart';
import '../Pages/Upload/widgets/vx_premium_loader.dart';

class VxVideoPlayerWidget extends StatefulWidget {
  final String url;

  const VxVideoPlayerWidget({Key? key, required this.url}) : super(key: key);

  @override
  _VxVideoPlayerWidgetState createState() => _VxVideoPlayerWidgetState();
}

class _VxVideoPlayerWidgetState extends State<VxVideoPlayerWidget> {
  late NativeVideoPlayer _player;
  bool _isInitialized = false;
  Timer? _frameTimer;
  Pointer<Uint8>? _buffer;

  @override
  void initState() {
    super.initState();
    _player = NativeVideoPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _player.initialize(widget.url);
    if (mounted) {
      setState(() {
        _isInitialized = true;
        _buffer = calloc<Uint8>(_player.width * _player.height * 4);
      });
      _player.play();
      // Start frame update loop (ideally this should be driven by vsync or native side)
      _frameTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
        if (_player.updateFrame(_buffer!)) {
          // In a real implementation, you'd send this buffer to the Texture
          // For now, we trigger a rebuild to show progress
          setState(() {}); 
        }
      });
    }
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    if (_buffer != null) calloc.free(_buffer!);
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: VxPremiumLoader());
    }

    return AspectRatio(
      aspectRatio: _player.width / _player.height,
      child: Texture(textureId: _player.textureId!),
    );
  }
}
