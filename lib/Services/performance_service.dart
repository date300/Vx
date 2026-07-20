import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'native_service.dart';

class PerformanceService {
  static const _channel = MethodChannel('com.example.vx/performance');
  
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  /// Gets memory information from the native Android system.
  /// Returns a map with 'availMem', 'totalMem', 'threshold', and 'lowMemory'.
  Future<Map<Object?, Object?>?> getMemoryInfo() async {
    if (kIsWeb) return null;
    try {
      final Map<Object?, Object?>? info = await _channel.invokeMethod('getMemoryInfo');
      return info;
    } on PlatformException catch (e) {
      print("Failed to get memory info: '${e.message}'.");
      return null;
    }
  }

  /// Clears the native application cache.
  Future<bool> clearNativeCache() async {
    if (kIsWeb) return false;
    try {
      final bool success = await _channel.invokeMethod('clearNativeCache');
      return success;
    } on PlatformException catch (e) {
      print("Failed to clear native cache: '${e.message}'.");
      return false;
    }
  }

  /// Suggests the native system to run garbage collection and uses C++ for low-level cleanup.
  Future<void> optimizeMemory() async {
    try {
      // Call C++ native optimization first (High speed)
      nativeService.nativeOptimizeMemory();
      
      // Then call platform specific optimization
      if (!kIsWeb) {
        await _channel.invokeMethod('optimizeMemory');
      }
    } on PlatformException catch (e) {
      print("Failed to optimize memory: '${e.message}'.");
    }
  }

  /// Sets the display refresh rate to high (90/120Hz) if supported.
  Future<void> setHighRefreshRate() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('setHighRefreshRate');
    } on PlatformException catch (e) {
      print("Failed to set high refresh rate: '${e.message}'.");
    }
  }

  /// Attempts to increase the touch sampling rate for ultra-responsive input.
  Future<void> enableTouchOverclocking() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('enableTouchOverclocking');
    } on PlatformException catch (e) {
      print("Failed to enable touch overclocking: '${e.message}'.");
    }
  }

  /// Activates Turbo Mode to maximize CPU/GPU performance for the active feed.
  Future<void> setTurboMode(bool enable) async {
    // Elevate C++ physics thread priority (0 = high, 19 = low)
    nativeService.setThreadPriority(enable ? 0 : 10);
    
    // Request native turbo boost
    nativeService.requestTurboBoost(enable);

    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('setTurboMode', {'enable': enable});
    } on PlatformException catch (e) {
      print("Failed to set turbo mode: '${e.message}'.");
    }
  }

  /// Optimizes GPU layers to ensure hardware acceleration is fully utilized.
  Future<void> optimizeGpuLayers() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('optimizeGpuLayers');
    } on PlatformException catch (e) {
      print("Failed to optimize GPU layers: '${e.message}'.");
    }
  }
}
