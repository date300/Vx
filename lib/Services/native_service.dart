import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

// Typedefs for C functions
typedef CalculateSpringForceC = Double Function(Double distance, Double velocity, Double stiffness, Double damping);
typedef CalculateSpringForceDart = double Function(double distance, double velocity, double stiffness, double damping);

typedef CalculateJigglePhysicsC = Double Function(Double time, Double frequency, Double amplitude, Double decay);
typedef CalculateJigglePhysicsDart = double Function(double time, double frequency, double amplitude, double decay);

typedef FastLerpC = Double Function(Double a, Double b, Double t);
typedef FastLerpDart = double Function(double a, double b, double t);

typedef CalculateBufferPriorityC = Int32 Function(Double scrollVelocity, Int32 videoIndex, Int32 currentIndex);
typedef CalculateBufferPriorityDart = int Function(double scrollVelocity, int videoIndex, int currentIndex);

typedef NativeOptimizeMemoryC = Void Function();
typedef NativeOptimizeMemoryDart = void Function();

typedef NativeEncryptDataC = Void Function(Pointer<Uint8> data, Int32 length, Pointer<Uint8> key, Int32 keyLength);
typedef NativeEncryptDataDart = void Function(Pointer<Uint8> data, int length, Pointer<Uint8> key, int keyLength);

typedef CalculateVideoDimensionsC = Void Function(
    Double videoWidth, Double videoHeight, 
    Double containerWidth, Double containerHeight,
    Pointer<Double> outWidth, Pointer<Double> outHeight);
typedef CalculateVideoDimensionsDart = void Function(
    double videoWidth, double videoHeight, 
    double containerWidth, double containerHeight,
    Pointer<Double> outWidth, Pointer<Double> outHeight);

typedef GenerateMessageHashC = Uint64 Function(Pointer<Utf8> message, Uint64 timestamp);
typedef GenerateMessageHashDart = int Function(Pointer<Utf8> message, int timestamp);

typedef SecureChatEncryptC = Void Function(Pointer<Uint8> data, Int32 length, Uint32 sessionKey);
typedef SecureChatEncryptDart = void Function(Pointer<Uint8> data, int length, int sessionKey);

typedef CalculateSheetEasingC = Double Function(Double time, Double duration);
typedef CalculateSheetEasingDart = double Function(double time, double duration);

typedef CalculateMaxPreloadC = Int32 Function(Int64 availableMemoryMB, Int32 videoQuality);
typedef CalculateMaxPreloadDart = int Function(int availableMemoryMB, int videoQuality);

typedef CalculateGridItemSizeC = Void Function(Double screenWidth, Int32 crossAxisCount, Double spacing, Pointer<Double> outWidth);
typedef CalculateGridItemSizeDart = void Function(double screenWidth, int crossAxisCount, double spacing, Pointer<Double> outWidth);

typedef ShouldTriggerInstantSnapC = Bool Function(Double velocity, Double dragDistance, Double threshold);
typedef ShouldTriggerInstantSnapDart = bool Function(double velocity, double dragDistance, double threshold);

// Typedefs for Video Player
typedef CreateVideoPlayerC = Pointer Function();
typedef CreateVideoPlayerDart = Pointer Function();

typedef DisposeVideoPlayerC = Void Function(Pointer player);
typedef DisposeVideoPlayerDart = void Function(Pointer player);

typedef OpenVideoC = Bool Function(Pointer player, Pointer<Utf8> url);
typedef OpenVideoDart = bool Function(Pointer player, Pointer<Utf8> url);

typedef PlayVideoC = Void Function(Pointer player);
typedef PlayVideoDart = void Function(Pointer player);

typedef PauseVideoC = Void Function(Pointer player);
typedef PauseVideoDart = void Function(Pointer player);

typedef SeekVideoC = Void Function(Pointer player, Int64 timestampMs);
typedef SeekVideoDart = void Function(Pointer player, int timestampMs);

typedef GetVideoFrameC = Bool Function(Pointer player, Pointer<Uint8> buffer, Int32 width, Int32 height);
typedef GetVideoFrameDart = bool Function(Pointer player, Pointer<Uint8> buffer, int width, int height);

typedef GetVideoWidthC = Int32 Function(Pointer player);
typedef GetVideoWidthDart = int Function(Pointer player);

typedef GetVideoHeightC = Int32 Function(Pointer player);
typedef GetVideoHeightDart = int Function(Pointer player);

typedef GetVideoDurationC = Double Function(Pointer player);
typedef GetVideoDurationDart = double Function(Pointer player);

typedef ExtractVideoThumbnailC = Bool Function(Pointer player, Pointer<Utf8> url, Pointer<Uint8> buffer, Int32 width, Int32 height, Int64 timeMs);
typedef ExtractVideoThumbnailDart = bool Function(Pointer player, Pointer<Utf8> url, Pointer<Uint8> buffer, int width, int height, int timeMs);

typedef ApplyNativeFilterC = Void Function(Pointer<Uint8> buffer, Int32 width, Int32 height, Int32 filterId);
typedef ApplyNativeFilterDart = void Function(Pointer<Uint8> buffer, int width, int height, int filterId);

class NativeService {
  static final NativeService _instance = NativeService._internal();
  factory NativeService() => _instance;
  NativeService._internal() {
    _init();
  }

  late DynamicLibrary _nativeLib;
  bool _libLoaded = false;
  
  // Dart functions bound to C
  late CalculateSpringForceDart calculateSpringForce;
  late CalculateJigglePhysicsDart calculateJigglePhysics;
  late FastLerpDart fastLerp;
  late CalculateBufferPriorityDart calculateBufferPriority;
  late NativeOptimizeMemoryDart nativeOptimizeMemory;
  late NativeEncryptDataDart nativeEncryptData;
  late CalculateVideoDimensionsDart calculateVideoDimensions;
  late GenerateMessageHashDart generateMessageHash;
  late SecureChatEncryptDart secureChatEncrypt;
  late CalculateSheetEasingDart calculateSheetEasing;
  late CalculateMaxPreloadDart calculateMaxPreload;
  late CalculateGridItemSizeDart calculateGridItemSize;
  late ShouldTriggerInstantSnapDart shouldTriggerInstantSnap;
  late ApplyNativeFilterDart applyNativeFilter;

  // Video Player bindings
  late CreateVideoPlayerDart createVideoPlayer;
  late DisposeVideoPlayerDart disposeVideoPlayer;
  late OpenVideoDart openVideo;
  late PlayVideoDart playVideo;
  late PauseVideoDart pauseVideo;
  late SeekVideoDart seekVideo;
  late GetVideoFrameDart getVideoFrame;
  late GetVideoWidthDart getVideoWidth;
  late GetVideoHeightDart getVideoHeight;
  late GetVideoDurationDart getVideoDuration;
  late ExtractVideoThumbnailDart extractVideoThumbnail;

  void _init() {
    try {
      if (Platform.isAndroid) {
        _nativeLib = DynamicLibrary.open('libvx_native.so');
      } else if (Platform.isIOS || Platform.isMacOS) {
        _nativeLib = DynamicLibrary.process();
      } else {
        _nativeLib = DynamicLibrary.open('vx_native.dll'); 
      }
      _libLoaded = true;
      _bindFunctions();
      debugPrint("Native Engine initialized successfully 🚀");
    } catch (e) {
      debugPrint("CRITICAL: Failed to load Native Engine: $e");
      _libLoaded = false;
      _bindFallbacks();
    }
  }

  void _bindFunctions() {
    if (!_libLoaded) return;

    try {
      calculateSpringForce = _nativeLib.lookup<NativeFunction<CalculateSpringForceC>>('calculate_spring_force').asFunction();
    } catch (_) {
      calculateSpringForce = (d, v, s, dam) => 0.0;
    }

    try {
      calculateJigglePhysics = _nativeLib.lookup<NativeFunction<CalculateJigglePhysicsC>>('calculate_jiggle_physics').asFunction();
    } catch (_) {
      calculateJigglePhysics = (t, f, a, dec) => 0.0;
    }

    try {
      fastLerp = _nativeLib.lookup<NativeFunction<FastLerpC>>('fast_lerp').asFunction();
    } catch (_) {
      fastLerp = (a, b, t) => a + (b - a) * t;
    }

    try {
      calculateBufferPriority = _nativeLib.lookup<NativeFunction<CalculateBufferPriorityC>>('calculate_buffer_priority').asFunction();
    } catch (_) {
      calculateBufferPriority = (v, i, c) => 0;
    }

    try {
      nativeOptimizeMemory = _nativeLib.lookup<NativeFunction<NativeOptimizeMemoryC>>('native_optimize_memory').asFunction();
    } catch (_) {
      nativeOptimizeMemory = () {};
    }

    try {
      nativeEncryptData = _nativeLib.lookup<NativeFunction<NativeEncryptDataC>>('native_encrypt_data').asFunction();
    } catch (_) {
      nativeEncryptData = (d, l, k, kl) {};
    }

    try {
      calculateVideoDimensions = _nativeLib.lookup<NativeFunction<CalculateVideoDimensionsC>>('calculate_video_dimensions').asFunction();
    } catch (_) {
      calculateVideoDimensions = (vw, vh, cw, ch, ow, oh) {};
    }

    try {
      generateMessageHash = _nativeLib.lookup<NativeFunction<GenerateMessageHashC>>('generate_message_hash').asFunction();
    } catch (_) {
      generateMessageHash = (m, t) => 0;
    }

    try {
      secureChatEncrypt = _nativeLib.lookup<NativeFunction<SecureChatEncryptC>>('secure_chat_encrypt').asFunction();
    } catch (_) {
      secureChatEncrypt = (d, l, sk) {};
    }

    try {
      calculateSheetEasing = _nativeLib.lookup<NativeFunction<CalculateSheetEasingC>>('calculate_sheet_easing').asFunction();
    } catch (_) {
      calculateSheetEasing = (t, d) => 0.0;
    }

    try {
      calculateMaxPreload = _nativeLib.lookup<NativeFunction<CalculateMaxPreloadC>>('calculate_max_preload').asFunction();
    } catch (_) {
      calculateMaxPreload = (m, q) => 2;
    }

    try {
      calculateGridItemSize = _nativeLib.lookup<NativeFunction<CalculateGridItemSizeC>>('calculate_grid_item_size').asFunction();
    } catch (_) {
      calculateGridItemSize = (sw, c, s, ow) {};
    }

    try {
      shouldTriggerInstantSnap = _nativeLib.lookup<NativeFunction<ShouldTriggerInstantSnapC>>('should_trigger_instant_snap').asFunction();
    } catch (_) {
      shouldTriggerInstantSnap = (v, d, t) => false;
    }

    try {
      applyNativeFilter = _nativeLib.lookup<NativeFunction<ApplyNativeFilterC>>('apply_native_filter').asFunction();
    } catch (_) {
      applyNativeFilter = (b, w, h, id) {};
    }

    // Video Player
    try {
      createVideoPlayer = _nativeLib.lookup<NativeFunction<CreateVideoPlayerC>>('create_video_player').asFunction();
    } catch (_) {
      createVideoPlayer = () => Pointer.fromAddress(0);
    }

    try {
      disposeVideoPlayer = _nativeLib.lookup<NativeFunction<DisposeVideoPlayerC>>('dispose_video_player').asFunction();
    } catch (_) {
      disposeVideoPlayer = (p) {};
    }

    try {
      openVideo = _nativeLib.lookup<NativeFunction<OpenVideoC>>('open_video').asFunction();
    } catch (_) {
      openVideo = (p, u) => false;
    }

    try {
      playVideo = _nativeLib.lookup<NativeFunction<PlayVideoC>>('play_video').asFunction();
    } catch (_) {
      playVideo = (p) {};
    }

    try {
      pauseVideo = _nativeLib.lookup<NativeFunction<PauseVideoC>>('pause_video').asFunction();
    } catch (_) {
      pauseVideo = (p) {};
    }

    try {
      seekVideo = _nativeLib.lookup<NativeFunction<SeekVideoC>>('seek_video').asFunction();
    } catch (_) {
      seekVideo = (p, t) {};
    }

    try {
      getVideoFrame = _nativeLib.lookup<NativeFunction<GetVideoFrameC>>('get_video_frame').asFunction();
    } catch (_) {
      getVideoFrame = (p, b, w, h) => false;
    }

    try {
      getVideoWidth = _nativeLib.lookup<NativeFunction<GetVideoWidthC>>('get_video_width').asFunction();
    } catch (_) {
      getVideoWidth = (p) => 0;
    }

    try {
      getVideoHeight = _nativeLib.lookup<NativeFunction<GetVideoHeightC>>('get_video_height').asFunction();
    } catch (_) {
      getVideoHeight = (p) => 0;
    }

    try {
      getVideoDuration = _nativeLib.lookup<NativeFunction<GetVideoDurationC>>('get_video_duration').asFunction();
    } catch (_) {
      getVideoDuration = (p) => 0.0;
    }

    try {
      extractVideoThumbnail = _nativeLib.lookup<NativeFunction<ExtractVideoThumbnailC>>('extract_video_thumbnail').asFunction();
    } catch (_) {
      extractVideoThumbnail = (p, u, b, w, h, t) => false;
    }
  }

  void _bindFallbacks() {
    calculateSpringForce = (d, v, s, dam) => 0.0;
    calculateJigglePhysics = (t, f, a, dec) => 0.0;
    fastLerp = (a, b, t) => a + (b - a) * t;
    calculateBufferPriority = (v, i, c) => 0;
    nativeOptimizeMemory = () {};
    nativeEncryptData = (d, l, k, kl) {};
    calculateVideoDimensions = (vw, vh, cw, ch, ow, oh) {};
    generateMessageHash = (m, t) => 0;
    secureChatEncrypt = (d, l, sk) {};
    calculateSheetEasing = (t, d) => 0.0;
    calculateMaxPreload = (m, q) => 2;
    calculateGridItemSize = (sw, c, s, ow) {};
    shouldTriggerInstantSnap = (v, d, t) => false;
    applyNativeFilter = (b, w, h, id) {};
    createVideoPlayer = () => Pointer.fromAddress(0);
    disposeVideoPlayer = (p) {};
    openVideo = (p, u) => false;
    playVideo = (p) {};
    pauseVideo = (p) {};
    seekVideo = (p, t) {};
    getVideoFrame = (p, b, w, h) => false;
    getVideoWidth = (p) => 0;
    getVideoHeight = (p) => 0;
    getVideoDuration = (p) => 0.0;
    extractVideoThumbnail = (p, u, b, w, h, t) => false;
  }

  /// Securely hashes a message for notifications/tamper-check
  int getMessageHash(String message, int timestamp) {
    final msgPtr = message.toNativeUtf8();
    try {
      return generateMessageHash(msgPtr, timestamp);
    } catch (e) {
      return 0;
    } finally {
      calloc.free(msgPtr);
    }
  }

  /// TikTok-style Jiggle Animation
  double getJiggleValue(double time, double frequency, double amplitude, double decay) {
    return calculateJigglePhysics(time, frequency, amplitude, decay);
  }

  /// High-speed encryption for cache
  Uint8List protectData(Uint8List data, String key) {
    final dataPtr = calloc<Uint8>(data.length);
    final keyBytes = Uint8List.fromList(key.codeUnits);
    final keyPtr = calloc<Uint8>(keyBytes.length);

    dataPtr.asTypedList(data.length).setAll(0, data);
    keyPtr.asTypedList(keyBytes.length).setAll(0, keyBytes);

    try {
      nativeEncryptData(dataPtr, data.length, keyPtr, keyBytes.length);
      return Uint8List.fromList(dataPtr.asTypedList(data.length));
    } catch (e) {
      return data;
    } finally {
      calloc.free(dataPtr);
      calloc.free(keyPtr);
    }
  }
}

// Global instance
final nativeService = NativeService();
