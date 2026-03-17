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

  @override
  void initState() {
    super.initState();
    
    // অ্যাপ ওপেন হওয়ার ১০০ মিলি-সেকেন্ড পর অ্যানিমেশন শুরু হবে
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });

    // ৩ সেকেন্ড পর মেইন পেজে নেভিগেট করবে (স্মুথ ফেড ট্রানজিশন সহ)
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainLayout(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800), // ট্রানজিশনের সময়কাল
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // একদম ডিপ প্রিমিয়াম ব্ল্যাক ব্যাকগ্রাউন্ড
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 1500), // ফেড ইন অ্যানিমেশনের সময়
          opacity: _opacity,
          curve: Curves.easeIn,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 1500), // স্কেল অ্যানিমেশনের সময়
            scale: _scale,
            curve: Curves.easeOutBack, // একটু পপ হয়ে তারপর সেটেল হবে
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // এখানে আপনার লোগো বসবে। আপাতত একটি আইকন দিচ্ছি।
                // আপনার নিজের লোগো বসাতে চাইলে Image.asset('assets/your_logo.png') ব্যবহার করতে হবে।
                ValueListenableBuilder<Color>(
                  valueListenable: PremiumTheme.accentColor,
                  builder: (context, accentColor, child) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.play_circle_fill, // ইউটিউবের মত প্লে আইকন
                        size: 100,
                        color: accentColor,
                      ),
                    );
                  }
                ),
                const SizedBox(height: 20),
                
                // অ্যাপের নাম
                const Text(
                  "V X", // আপনার ফোল্ডারের নাম অনুযায়ী দিলাম
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10.0, // প্রিমিয়াম লুকের জন্য একটু স্পেসিং
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
