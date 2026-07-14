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
      await _channel.invokeMethod('optimizeMemory');
    } on PlatformException catch (e) {
      print("Failed to optimize memory: '${e.message}'.");
    }
  }
}
