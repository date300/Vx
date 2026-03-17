import 'package:flutter/material.dart';
import 'screen/splash_screen.dart'; // স্প্ল্যাশ স্ক্রিন ইমপোর্ট করা হলো
import 'Layout/premium_theme_controller.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // এখানে ValueListenableBuilder থিম মোড (Dark/Light) লিসেন করবে
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: PremiumTheme.themeMode,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SKYTHOR', // আপনার অ্যাপের প্রিমিয়াম নাম

          // থিম মোড সেট করা (ডার্ক বা লাইট)
          themeMode: currentMode,

          // লাইট থিম কনফিগারেশন
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.blue, // primarySwatch এর বদলে primaryColor ব্যবহার করা ভালো
            fontFamily: 'Inter',
            scaffoldBackgroundColor: Colors.white,
          ),

          // ডার্ক থিম কনফিগারেশন (OLED Black)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black, // ট্রু ব্ল্যাক
            fontFamily: 'Inter',
          ),

          // অ্যাপ ওপেন হলে প্রথমে আপনার ইউটিউবের মতো স্প্ল্যাশ অ্যানিমেশন আসবে
          home: const SplashScreen(), 
        );
      },
    );
  }
}
