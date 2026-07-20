import 'dart:typed_data';

// Mock types for Web to keep compiler happy
class Pointer<T> {
  dynamic get value => throw UnimplementedError();
  set value(dynamic val) => throw UnimplementedError();
  dynamic asTypedList(int length) {
    if (T == Uint8) return Uint8List(length);
    return [];
  }
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

  dynamic calculateSpringForce = (d, v, s, dam) => 0.0;
  dynamic calculateJigglePhysics = (t, f, a, dec) => 0.0;
  dynamic fastLerp = (a, b, t) => a + (b - a) * t;
  dynamic calculateBufferPriority = (v, i, c) => 0;
  dynamic nativeOptimizeMemory = () {};
  dynamic nativeEncryptData = (d, l, k, kl) {};
  
  void calculateVideoDimensionsWrapper(
    double videoWidth, double videoHeight, 
    double containerWidth, double containerHeight,
    void Function(double width, double height) onResult) {
    
    // Web fallback: simple aspect fill/fit calculation
    final videoAspect = videoWidth / videoHeight;
    final containerAspect = containerWidth / containerHeight;
    
    double outWidth, outHeight;
    
    if (videoAspect > containerAspect) {
      outWidth = containerWidth;
      outHeight = containerWidth / videoAspect;
    } else {
      outHeight = containerHeight;
      outWidth = containerHeight * videoAspect;
    }
    
    onResult(outWidth, outHeight);
  }

  dynamic generateMessageHash = (m, t) => 0;
  dynamic secureChatEncrypt = (d, l, sk) {};
  dynamic calculateSheetEasing = (t, d) => 0.0;
  dynamic calculateMaxPreload = (m, q) => 2;
  dynamic calculateGridItemSize = (sw, c, s, ow) {};
  dynamic shouldTriggerInstantSnap = (v, d, t) => false;
  dynamic applyNativeFilter = (b, w, h, id) {};
  dynamic trimVideo = (i, o, s, d) => -1;
  dynamic processTouchEvent = (id, a, x, y, t) {};
  dynamic getNativeScrollDelta = () => 0.0;
  dynamic getNativeVelocity = () => 0.0;
  dynamic setThreadPriority = (p) {};
  dynamic requestTurboBoost = (e) {};

  dynamic createVideoPlayer = () => Pointer();
  dynamic disposeVideoPlayer = (p) {};
  dynamic openVideo = (p, u) => false;
  dynamic playVideo = (p) {};
  dynamic pauseVideo = (p) {};
  dynamic seekVideo = (p, t) {};
  dynamic getVideoFrame = (p, b, w, h) => false;
  dynamic getVideoWidth = (p) => 0;
  dynamic getVideoHeight = (p) => 0;
  dynamic getVideoDuration = (p) => 0.0;
  dynamic extractVideoThumbnail = (p, u, b, w, h, t) => false;
  dynamic setCacheDirectory = (p) {};
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
