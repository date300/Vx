import 'package:flutter/material.dart';
import 'Layout/main_layout.dart';
import 'Layout/premium_theme_controller.dart'; // পাথটি আপনার প্রোজেক্ট অনুযায়ী চেক করে নিন

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
          title: 'SKYTHOR',
          
          // থিম মোড সেট করা (ডার্ক বা লাইট)
          themeMode: currentMode,

          // লাইট থিম কনফিগারেশন
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            fontFamily: 'Inter',
            scaffoldBackgroundColor: Colors.white,
          ),

          // ডার্ক থিম কনফিগারেশন (OLED Black)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            fontFamily: 'Inter',
          ),

          // এখানে 'const' সরিয়ে দেওয়া হয়েছে কারণ MainLayout ডাইনামিক ডাটা লিসেন করে
          home: MainLayout(), 
        );
      },
    );
  }
}
