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
        scaffoldBackgroundColor: Colors.black, // Pure OLED Black
        fontFamily: 'Inter',
      ),
      home: const MainLayout(), // এখানেই মূলত আমাদের নতুন ডিজাইনটা কানেক্ট করা হলো
    );
  }
}
