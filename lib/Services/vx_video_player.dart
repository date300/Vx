import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'native_service.dart';

class NativeVideoPlayer {
  final Pointer _playerHandle;
  int? textureId;
  static const MethodChannel _channel = MethodChannel('com.example.vx/video_texture');

  int width = 0;
  int height = 0;
  double duration = 0;
  bool isInitialized = false;

  NativeVideoPlayer() : _playerHandle = nativeService.createVideoPlayer();

  Future<void> initialize(String url) async {
    final urlPtr = url.toNativeUtf8();
    try {
      final success = nativeService.openVideo(_playerHandle, urlPtr);
      if (success) {
        width = nativeService.getVideoWidth(_playerHandle);
        height = nativeService.getVideoHeight(_playerHandle);
        duration = nativeService.getVideoDuration(_playerHandle);
        
        // Register texture on platform side
        textureId = await _channel.invokeMethod('createTexture', {
          'width': width,
          'height': height,
        });
        
        isInitialized = true;
      }
    } finally {
      calloc.free(urlPtr);
    }
  }

  void play() => nativeService.playVideo(_playerHandle);
  void pause() => nativeService.pauseVideo(_playerHandle);
  void seek(int ms) => nativeService.seekVideo(_playerHandle, ms);

  Future<Uint8List?> generateThumbnail(String url, int width, int height, int timeMs) async {
    final urlPtr = url.toNativeUtf8();
    final buffer = calloc<Uint8>(width * height * 4);
    try {
      final success = nativeService.extractVideoThumbnail(_playerHandle, urlPtr, buffer, width, height, timeMs);
      if (success) {
        return Uint8List.fromList(buffer.asTypedList(width * height * 4));
      }
      return null;
    } finally {
      calloc.free(urlPtr);
      calloc.free(buffer);
    }
  }

  bool updateFrame(Pointer<Uint8> buffer) {
    if (!isInitialized) return false;
    return nativeService.getVideoFrame(_playerHandle, buffer, width, height);
  }

  Future<void> dispose() async {
    if (textureId != null) {
      await _channel.invokeMethod('disposeTexture', {'textureId': textureId});
    }
    nativeService.disposeVideoPlayer(_playerHandle);
  }
}
