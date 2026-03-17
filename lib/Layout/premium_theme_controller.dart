import 'package:flutter/material.dart';

class PremiumTheme {
  // ১. গ্লোবাল অ্যাকসেন্ট কালার (ডিফল্ট: Electric Blue)
  static ValueNotifier<Color> accentColor = ValueNotifier(const Color(0xFF00E5FF));

  // ২. থিম মোড (Dark/Light/White) - আপনার প্রিমিয়াম লুকের জন্য ডিফল্ট Dark রাখা হয়েছে
  static ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.dark);

  // ইউজার কালার চেঞ্জ করতে চাইলে এই ফাংশন কল করবে
  static void changeAccentColor(Color newColor) {
    accentColor.value = newColor;
  }

  // ইউজার ডার্ক বা হোয়াইট মোড সিলেক্ট করলে এই ফাংশন কল করবে
  static void changeThemeMode(ThemeMode newMode) {
    themeMode.value = newMode;
  }
}

