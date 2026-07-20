// Mock types for Stub to keep compiler happy
class Pointer<T> {
  dynamic get value => throw UnimplementedError();
  set value(dynamic val) => throw UnimplementedError();
  dynamic asTypedList(int length) => throw UnimplementedError();
}

class Uint8 {}
class Double {}
class Int32 {}
class Int64 {}
class Uint32 {}
class Uint64 {}
class Void {}
class Bool {}
class Utf8 {}
class NativeFunction<T> {}
class DynamicLibrary {}

class NativeService {
  static final NativeService _instance = NativeService._internal();
  factory NativeService() => _instance;
  NativeService._internal();

  dynamic calculateSpringForce;
  dynamic calculateJigglePhysics;
  dynamic fastLerp;
  dynamic calculateBufferPriority;
  dynamic nativeOptimizeMemory;
  dynamic nativeEncryptData;
  dynamic calculateVideoDimensions;
  
  void calculateVideoDimensionsWrapper(
    double videoWidth, double videoHeight, 
    double containerWidth, double containerHeight,
    void Function(double width, double height) onResult) {
    throw UnimplementedError();
  }

  dynamic generateMessageHash;
  dynamic secureChatEncrypt;
  dynamic calculateSheetEasing;
  dynamic calculateLiquidStretch;
  dynamic calculateMaxPreload;
  dynamic calculateGridItemSize;
  dynamic shouldTriggerInstantSnap;
  dynamic applyNativeFilter;
  dynamic trimVideo;
  dynamic processTouchEvent;
  dynamic getNativeScrollDelta;
  dynamic getNativeVelocity;
  dynamic shouldTriggerHaptic;
  dynamic setThreadPriority;
  dynamic requestTurboBoost;

  dynamic createVideoPlayer;
  dynamic disposeVideoPlayer;
  dynamic openVideo;
  dynamic playVideo;
  dynamic pauseVideo;
  dynamic seekVideo;
  dynamic getVideoFrame;
  dynamic getVideoWidth;
  dynamic getVideoHeight;
  dynamic getVideoDuration;
  dynamic extractVideoThumbnail;
  dynamic setCacheDirectory;
}

final nativeService = NativeService();

// Mock calloc/free
class Calloc {
  Pointer<T> call<T extends Object>([int count = 1]) => Pointer<T>();
  void free(Pointer ptr) {}
}
final calloc = Calloc();

extension StringUtf8Pointer on String {
  Pointer<Utf8> toNativeUtf8() => Pointer<Utf8>();
}
