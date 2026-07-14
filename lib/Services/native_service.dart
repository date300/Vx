import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

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

typedef ShouldRotateCacheC = Bool Function(Int64 currentCacheSize, Int64 maxCacheSize, Int64 lastAccessTime, Int64 currentTime);
typedef ShouldRotateCacheDart = bool Function(int currentCacheSize, int maxCacheSize, int lastAccessTime, int currentTime);

typedef GenerateMessageHashC = Uint64 Function(Pointer<Utf8> message, Uint64 timestamp);
typedef GenerateMessageHashDart = int Function(Pointer<Utf8> message, int timestamp);

typedef SecureChatEncryptC = Void Function(Pointer<Uint8> data, Int32 length, Uint32 sessionKey);
typedef SecureChatEncryptDart = void Function(Pointer<Uint8> data, int length, int sessionKey);

typedef SyncAudioVideoTimestampC = Double Function(Double videoTime, Double audioTime, Double offset);
typedef SyncAudioVideoTimestampDart = double Function(double videoTime, double audioTime, double offset);

typedef CalculateCompressionRatioC = Float Function(Int64 originalSize, Int32 targetBitrate, Double duration);
typedef CalculateCompressionRatioDart = double Function(int originalSize, int targetBitrate, double duration);

typedef CalculateSheetEasingC = Double Function(Double time, Double duration);
typedef CalculateSheetEasingDart = double Function(double time, double duration);

typedef SortCommentsFastC = Void Function(Pointer<Int32> likeCounts, Int32 length);
typedef SortCommentsFastDart = void Function(Pointer<Int32> likeCounts, int length);

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

class NativeService {
  static final NativeService _instance = NativeService._internal();
  factory NativeService() => _instance;
  NativeService._internal() {
    _init();
  }

  late DynamicLibrary _nativeLib;
  
  // Dart functions bound to C
  late CalculateSpringForceDart calculateSpringForce;
  late CalculateJigglePhysicsDart calculateJigglePhysics;
  late FastLerpDart fastLerp;
  late CalculateBufferPriorityDart calculateBufferPriority;
  late NativeOptimizeMemoryDart nativeOptimizeMemory;
  late NativeEncryptDataDart nativeEncryptData;
  late CalculateVideoDimensionsDart calculateVideoDimensions;
  late ShouldRotateCacheDart shouldRotateCache;
  late GenerateMessageHashDart generateMessageHash;
  late SecureChatEncryptDart secureChatEncrypt;
  late SyncAudioVideoTimestampDart syncAudioVideoTimestamp;
  late CalculateCompressionRatioDart calculateCompressionRatio;
  late CalculateSheetEasingDart calculateSheetEasing;
  late SortCommentsFastDart sortCommentsFast;
  late CalculateMaxPreloadDart calculateMaxPreload;
  late CalculateGridItemSizeDart calculateGridItemSize;
  late ShouldTriggerInstantSnapDart shouldTriggerInstantSnap;

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
    if (Platform.isAndroid) {
      _nativeLib = DynamicLibrary.open('libvx_native.so');
    } else if (Platform.isIOS || Platform.isMacOS) {
      _nativeLib = DynamicLibrary.process();
    } else {
      _nativeLib = DynamicLibrary.open('vx_native.dll'); 
    }

    calculateSpringForce = _nativeLib
        .lookup<NativeFunction<CalculateSpringForceC>>('calculate_spring_force')
        .asFunction();

    calculateJigglePhysics = _nativeLib
        .lookup<NativeFunction<CalculateJigglePhysicsC>>('calculate_jiggle_physics')
        .asFunction();

    fastLerp = _nativeLib
        .lookup<NativeFunction<FastLerpC>>('fast_lerp')
        .asFunction();

    calculateBufferPriority = _nativeLib
        .lookup<NativeFunction<CalculateBufferPriorityC>>('calculate_buffer_priority')
        .asFunction();

    nativeOptimizeMemory = _nativeLib
        .lookup<NativeFunction<NativeOptimizeMemoryC>>('native_optimize_memory')
        .asFunction();

    nativeEncryptData = _nativeLib
        .lookup<NativeFunction<NativeEncryptDataC>>('native_encrypt_data')
        .asFunction();

    calculateVideoDimensions = _nativeLib
        .lookup<NativeFunction<CalculateVideoDimensionsC>>('calculate_video_dimensions')
        .asFunction();

    shouldRotateCache = _nativeLib
        .lookup<NativeFunction<ShouldRotateCacheC>>('should_rotate_cache')
        .asFunction();

    generateMessageHash = _nativeLib
        .lookup<NativeFunction<GenerateMessageHashC>>('generate_message_hash')
        .asFunction();

    secureChatEncrypt = _nativeLib
        .lookup<NativeFunction<SecureChatEncryptC>>('secure_chat_encrypt')
        .asFunction();

    syncAudioVideoTimestamp = _nativeLib
        .lookup<NativeFunction<SyncAudioVideoTimestampC>>('sync_audio_video_timestamp')
        .asFunction();

    calculateCompressionRatio = _nativeLib
        .lookup<NativeFunction<CalculateCompressionRatioC>>('calculate_compression_ratio')
        .asFunction();

    calculateSheetEasing = _nativeLib
        .lookup<NativeFunction<CalculateSheetEasingC>>('calculate_sheet_easing')
        .asFunction();

    sortCommentsFast = _nativeLib
        .lookup<NativeFunction<SortCommentsFastC>>('sort_comments_fast')
        .asFunction();

    calculateMaxPreload = _nativeLib
        .lookup<NativeFunction<CalculateMaxPreloadC>>('calculate_max_preload')
        .asFunction();

    calculateGridItemSize = _nativeLib
        .lookup<NativeFunction<CalculateGridItemSizeC>>('calculate_grid_item_size')
        .asFunction();

    shouldTriggerInstantSnap = _nativeLib
        .lookup<NativeFunction<ShouldTriggerInstantSnapC>>('should_trigger_instant_snap')
        .asFunction();

    // Video Player
    createVideoPlayer = _nativeLib
        .lookup<NativeFunction<CreateVideoPlayerC>>('create_video_player')
        .asFunction();

    disposeVideoPlayer = _nativeLib
        .lookup<NativeFunction<DisposeVideoPlayerC>>('dispose_video_player')
        .asFunction();

    openVideo = _nativeLib
        .lookup<NativeFunction<OpenVideoC>>('open_video')
        .asFunction();

    playVideo = _nativeLib
        .lookup<NativeFunction<PlayVideoC>>('play_video')
        .asFunction();

    pauseVideo = _nativeLib
        .lookup<NativeFunction<PauseVideoC>>('pause_video')
        .asFunction();

    seekVideo = _nativeLib
        .lookup<NativeFunction<SeekVideoC>>('seek_video')
        .asFunction();

    getVideoFrame = _nativeLib
        .lookup<NativeFunction<GetVideoFrameC>>('get_video_frame')
        .asFunction();

    getVideoWidth = _nativeLib
        .lookup<NativeFunction<GetVideoWidthC>>('get_video_width')
        .asFunction();

    getVideoHeight = _nativeLib
        .lookup<NativeFunction<GetVideoHeightC>>('get_video_height')
        .asFunction();

    getVideoDuration = _nativeLib
        .lookup<NativeFunction<GetVideoDurationC>>('get_video_duration')
        .asFunction();

    extractVideoThumbnail = _nativeLib
        .lookup<NativeFunction<ExtractVideoThumbnailC>>('extract_video_thumbnail')
        .asFunction();
  }

  /// Securely hashes a message for notifications/tamper-check
  int getMessageHash(String message, int timestamp) {
    final msgPtr = message.toNativeUtf8();
    try {
      return generateMessageHash(msgPtr, timestamp);
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

    nativeEncryptData(dataPtr, data.length, keyPtr, keyBytes.length);

    final result = Uint8List.fromList(dataPtr.asTypedList(data.length));
    
    calloc.free(dataPtr);
    calloc.free(keyPtr);
    return result;
  }
}

// Global instance
final nativeService = NativeService();
