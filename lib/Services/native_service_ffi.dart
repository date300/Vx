import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

export 'dart:ffi' hide Size;
export 'package:ffi/ffi.dart';

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

typedef CalculateLiquidStretchC = Double Function(Double pullDistance, Double threshold);
typedef CalculateLiquidStretchDart = double Function(double pullDistance, double threshold);

typedef CalculateMaxPreloadC = Int32 Function(Int64 availableMemoryMB, Int32 videoQuality);
typedef CalculateMaxPreloadDart = int Function(int availableMemoryMB, int videoQuality);

typedef CalculateGridItemSizeC = Void Function(Double screenWidth, Int32 crossAxisCount, Double spacing, Pointer<Double> outWidth);
typedef CalculateGridItemSizeDart = void Function(double screenWidth, int crossAxisCount, double spacing, Pointer<Double> outWidth);

typedef ShouldTriggerInstantSnapC = Bool Function(Double velocity, Double dragDistance, Double threshold);
typedef ShouldTriggerInstantSnapDart = bool Function(double velocity, double dragDistance, double threshold);

typedef TrimVideoC = Int32 Function(Pointer<Utf8> inputPath, Pointer<Utf8> outputPath, Double startTime, Double duration);
typedef TrimVideoDart = int Function(Pointer<Utf8> inputPath, Pointer<Utf8> outputPath, double startTime, double duration);

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

typedef SetCacheDirectoryC = Void Function(Pointer<Utf8> path);
typedef SetCacheDirectoryDart = void Function(Pointer<Utf8> path);

typedef ProcessTouchEventC = Void Function(Int32 pointerId, Int32 action, Double x, Double y, Int64 timestampMs);
typedef ProcessTouchEventDart = void Function(int pointerId, int action, double x, double y, int timestampMs);

typedef GetNativeScrollDeltaC = Double Function();
typedef GetNativeScrollDeltaDart = double Function();

typedef GetNativeScrollDeltaXC = Double Function();
typedef GetNativeScrollDeltaXDart = double Function();

typedef GetNativeVelocityC = Double Function();
typedef GetNativeVelocityDart = double Function();

typedef ShouldTriggerHapticC = Bool Function(Double currentPixels, Double viewportDimension);
typedef ShouldTriggerHapticDart = bool Function(double currentPixels, double viewportDimension);

typedef SetThreadPriorityC = Void Function(Int32 priority);
typedef SetThreadPriorityDart = void Function(int priority);

typedef RequestTurboBoostC = Void Function(Bool enable);
typedef RequestTurboBoostDart = void Function(bool enable);

class NativeService {
  static final NativeService _instance = NativeService._internal();
  factory NativeService() => _instance;
  NativeService._internal() {
    _init();
  }

  late DynamicLibrary _nativeLib;
  bool _libLoaded = false;
  
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
  late CalculateLiquidStretchDart calculateLiquidStretch;
  late CalculateMaxPreloadDart calculateMaxPreload;
  late CalculateGridItemSizeDart calculateGridItemSize;
  late ShouldTriggerInstantSnapDart shouldTriggerInstantSnap;
  late ApplyNativeFilterDart applyNativeFilter;
  late TrimVideoDart trimVideo;
  late ProcessTouchEventDart processTouchEvent;
  late GetNativeScrollDeltaDart getNativeScrollDelta;
  late GetNativeScrollDeltaXDart getNativeScrollDeltaX;
  late GetNativeVelocityDart getNativeVelocity;
  late ShouldTriggerHapticDart shouldTriggerHaptic;
  late SetThreadPriorityDart setThreadPriority;
  late RequestTurboBoostDart requestTurboBoost;

  void calculateVideoDimensionsWrapper(
    double videoWidth, double videoHeight, 
    double containerWidth, double containerHeight,
    void Function(double width, double height) onResult) {
    
    final outWidthPtr = calloc<Double>();
    final outHeightPtr = calloc<Double>();
    try {
      calculateVideoDimensions(
        videoWidth,
        videoHeight,
        containerWidth,
        containerHeight,
        outWidthPtr,
        outHeightPtr,
      );
      onResult(outWidthPtr.value, outHeightPtr.value);
    } finally {
      calloc.free(outWidthPtr);
      calloc.free(outHeightPtr);
    }
  }

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
  late SetCacheDirectoryDart setCacheDirectory;

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

    calculateSpringForce = _nativeLib.lookup<NativeFunction<CalculateSpringForceC>>('calculate_spring_force').asFunction();
    calculateJigglePhysics = _nativeLib.lookup<NativeFunction<CalculateJigglePhysicsC>>('calculate_jiggle_physics').asFunction();
    fastLerp = _nativeLib.lookup<NativeFunction<FastLerpC>>('fast_lerp').asFunction();
    calculateBufferPriority = _nativeLib.lookup<NativeFunction<CalculateBufferPriorityC>>('calculate_buffer_priority').asFunction();
    nativeOptimizeMemory = _nativeLib.lookup<NativeFunction<NativeOptimizeMemoryC>>('native_optimize_memory').asFunction();
    nativeEncryptData = _nativeLib.lookup<NativeFunction<NativeEncryptDataC>>('native_encrypt_data').asFunction();
    calculateVideoDimensions = _nativeLib.lookup<NativeFunction<CalculateVideoDimensionsC>>('calculate_video_dimensions').asFunction();
    generateMessageHash = _nativeLib.lookup<NativeFunction<GenerateMessageHashC>>('generate_message_hash').asFunction();
    secureChatEncrypt = _nativeLib.lookup<NativeFunction<SecureChatEncryptC>>('secure_chat_encrypt').asFunction();
    calculateSheetEasing = _nativeLib.lookup<NativeFunction<CalculateSheetEasingC>>('calculate_sheet_easing').asFunction();
    calculateLiquidStretch = _nativeLib.lookup<NativeFunction<CalculateLiquidStretchC>>('calculate_liquid_stretch').asFunction();
    calculateMaxPreload = _nativeLib.lookup<NativeFunction<CalculateMaxPreloadC>>('calculate_max_preload').asFunction();
    calculateGridItemSize = _nativeLib.lookup<NativeFunction<CalculateGridItemSizeC>>('calculate_grid_item_size').asFunction();
    shouldTriggerInstantSnap = _nativeLib.lookup<NativeFunction<ShouldTriggerInstantSnapC>>('should_trigger_instant_snap').asFunction();
    applyNativeFilter = _nativeLib.lookup<NativeFunction<ApplyNativeFilterC>>('apply_native_filter').asFunction();
    trimVideo = _nativeLib.lookup<NativeFunction<TrimVideoC>>('trim_video').asFunction();
    processTouchEvent = _nativeLib.lookup<NativeFunction<ProcessTouchEventC>>('process_touch_event').asFunction();
    getNativeScrollDelta = _nativeLib.lookup<NativeFunction<GetNativeScrollDeltaC>>('get_native_scroll_delta').asFunction();
    getNativeScrollDeltaX = _nativeLib.lookup<NativeFunction<GetNativeScrollDeltaXC>>('get_native_scroll_delta_x').asFunction();
    getNativeVelocity = _nativeLib.lookup<NativeFunction<GetNativeVelocityC>>('get_native_velocity').asFunction();
    shouldTriggerHaptic = _nativeLib.lookup<NativeFunction<ShouldTriggerHapticC>>('should_trigger_haptic').asFunction();
    setThreadPriority = _nativeLib.lookup<NativeFunction<SetThreadPriorityC>>('set_thread_priority').asFunction();
    requestTurboBoost = _nativeLib.lookup<NativeFunction<RequestTurboBoostC>>('request_turbo_boost').asFunction();

    createVideoPlayer = _nativeLib.lookup<NativeFunction<CreateVideoPlayerC>>('create_video_player').asFunction();
    disposeVideoPlayer = _nativeLib.lookup<NativeFunction<DisposeVideoPlayerC>>('dispose_video_player').asFunction();
    openVideo = _nativeLib.lookup<NativeFunction<OpenVideoC>>('open_video').asFunction();
    playVideo = _nativeLib.lookup<NativeFunction<PlayVideoC>>('play_video').asFunction();
    pauseVideo = _nativeLib.lookup<NativeFunction<PauseVideoC>>('pause_video').asFunction();
    seekVideo = _nativeLib.lookup<NativeFunction<SeekVideoC>>('seek_video').asFunction();
    getVideoFrame = _nativeLib.lookup<NativeFunction<GetVideoFrameC>>('get_video_frame').asFunction();
    getVideoWidth = _nativeLib.lookup<NativeFunction<GetVideoWidthC>>('get_video_width').asFunction();
    getVideoHeight = _nativeLib.lookup<NativeFunction<GetVideoHeightC>>('get_video_height').asFunction();
    getVideoDuration = _nativeLib.lookup<NativeFunction<GetVideoDurationC>>('get_video_duration').asFunction();
    extractVideoThumbnail = _nativeLib.lookup<NativeFunction<ExtractVideoThumbnailC>>('extract_video_thumbnail').asFunction();
    setCacheDirectory = _nativeLib.lookup<NativeFunction<SetCacheDirectoryC>>('set_cache_directory').asFunction();
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
    calculateLiquidStretch = (p, t) => (p / t).clamp(0.0, 1.0);
    calculateMaxPreload = (m, q) => 2;
    calculateGridItemSize = (sw, c, s, ow) {};
    shouldTriggerInstantSnap = (v, d, t) => false;
    applyNativeFilter = (b, w, h, id) {};
    trimVideo = (i, o, s, d) => -1;
    processTouchEvent = (id, a, x, y, t) {};
    getNativeScrollDelta = () => 0.0;
    getNativeScrollDeltaX = () => 0.0;
    getNativeVelocity = () => 0.0;
    shouldTriggerHaptic = (p, v) => false;
    setThreadPriority = (p) {};
    requestTurboBoost = (e) {};
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
    setCacheDirectory = (p) {};
  }
}

final nativeService = NativeService();
