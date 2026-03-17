import 'package:flutter/material.dart';
import 'Layout/main_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Premium App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, // Pure OLED Black ব্যাকগ্রাউন্ড
        fontFamily: 'Inter', // আপনার ফন্ট থাকলে এটি কাজ করবে
      ),
      home: const MainLayout(), 
    );
  }
}
