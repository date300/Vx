import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ← নতুন
import 'screen/splash_screen.dart';
import 'Layout/premium_theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ← নতুন

  // TikTok-style true full screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: PremiumTheme.themeMode,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SKYTHOR',
          themeMode: currentMode,

          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.blue,
            fontFamily: 'Inter',
            scaffoldBackgroundColor: Colors.white,
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            fontFamily: 'Inter',
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}
