import 'package:flutter/material.dart';

class PremiumTheme {
  // গ্লোবাল অ্যাকসেন্ট কালার (ডিফল্ট: Electric Blue)
  static ValueNotifier<Color> accentColor = ValueNotifier(const Color(0xFF00E5FF));

  // ইউজার কালার চেঞ্জ করতে চাইলে এই ফাংশন কল করবে
  static void changeAccentColor(Color newColor) {
    accentColor.value = newColor;
  }
}
