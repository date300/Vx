import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HapticService {
  static const _channel = MethodChannel('com.example.vx/haptics');

  static Future<void> impactLight() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('impactLight');
    } on PlatformException catch (e) {
      print("Haptic failed: ${e.message}");
    }
  }

  static Future<void> impactMedium() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('impactMedium');
    } on PlatformException catch (e) {
      print("Haptic failed: ${e.message}");
    }
  }

  static Future<void> impactHeavy() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('impactHeavy');
    } on PlatformException catch (e) {
      print("Haptic failed: ${e.message}");
    }
  }
}
