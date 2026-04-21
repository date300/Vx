import 'package:flutter/material.dart';
import 'dart:async';
import '../Layout/main_layout.dart';
import '../Layout/premium_theme_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _scale = 0.8;
  bool _startShine = false; // shine sweep trigger

  @override
  void initState() {
    super.initState();

    // Logo pop animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
        });
      }
    });

    // Shine sweep শুরু হবে logo pop-এর পর (প্রিমিয়াম টাইমিং)
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _startShine = true);
    });

    // ৩ সেকেন্ড পর মেইন পেজে যাবে
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainLayout(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 1500),
          opacity: _opacity,
          curve: Curves.easeIn,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 1500),
            scale: _scale,
            curve: Curves.easeOutBack, // iOS elastic pop
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // === Vx LOGO + LIQUID GLASS SHINE + GLOW ===
                ValueListenableBuilder<Color>(
                  valueListenable: PremiumTheme.accentColor,
                  builder: (context, accentColor, child) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.35),
                            blurRadius: 50,
                            spreadRadius: 15,
                          ),
                          BoxShadow(
                            color: accentColor.withOpacity(0.15),
                            blurRadius: 80,
                            spreadRadius: 25,
                          ),
                        ],
                      ),
                      child: ClipRect(
                        child: SizedBox(
                          width: 160,
                          height: 160,
                          child: Stack(
                            children: [
                              // আসল লোগো
                              Center(
                                child: Image.asset(
                                  'assets/vx_logo.png',
                                  width: 160,
                                ),
                              ),

                              // === Premium Shine Sweep (Video-like effect) ===
                              if (_startShine)
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: -200.0, end: 320.0),
                                  duration: const Duration(milliseconds: 1100),
                                  curve: Curves.fastOutSlowIn,
                                  builder: (context, value, child) {
                                    return Positioned(
                                      left: value,
                                      top: 0,
                                      child: Container(
                                        width: 65,
                                        height: 160,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              accentColor.withOpacity(0.85),
                                              Colors.transparent,
                                            ],
                                            stops: const [0.0, 0.5, 1.0],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // অ্যাপ নাম (চাইলে ডিলিট করুন)
                const Text(
                  "V X",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
