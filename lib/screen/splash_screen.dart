import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../Layout/main_layout.dart';
import '../Layout/premium_theme_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  // এনিমেশন কন্ট্রোলার (Visualizer এর জন্য)
  late AnimationController _animationController;
  late Animation<double> _animation;

  // এন্ট্রেন্স এনিমেশনের জন্য (Vx টেক্সট এর জন্য)
  double _textOpacity = 0.0;
  double _textScale = 0.5;

  @override
  void initState() {
    super.initState();

    // ১. Visualizer এনিমেশন সেটআপ (লুপ চলবে)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // একপাক ঘুরতে সময়
    );

    _animation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    // এনিমেশন শুরু এবং লুপ করা
    _animationController.repeat();

    // ২. Vx টেক্সট এন্ট্রেন্স এনিমেশন
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _textOpacity = 1.0;
          _textScale = 1.0;
        });
      }
    });

    // ৩. Navigation logic with safety check (৩ সেকেন্ড পর)
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;

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
  void dispose() {
    _animationController.dispose(); // কন্ট্রোলার মেমোরি থেকে রিমুভ করা
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // থিম কালার গেট করা
    final accentColor = PremiumTheme.accentColor.value; 

    return Scaffold(
      backgroundColor: Colors.black, // টিকটক বা মিউজিক অ্যাপের জন্য ব্ল্যাক ব্যাকগ্রাউন্ড বেস্ট
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // === ১. প্লে স্টোর + মিউজিক স্টাইল বৃত্তাকার Visualizer ===
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation.value, // পুরো সার্কেলটি আস্তে আস্তে ঘুরবে
                  child: SizedBox(
                    width: 200, // Visualizer এর এরিয়া
                    height: 200,
                    child: CustomPaint(
                      painter: PlayStoreMusicVisualizerPainter(
                        color: accentColor,
                        // এনিমেশন ভ্যালু পাস করা হচ্ছে বারগুলোর আপ-ডাউনের জন্য
                        animValue: _animationController.value, 
                      ),
                    ),
                  ),
                );
              },
            ),

            // === ২. মাঝখানে Vx টেক্সট (Animated) ===
            AnimatedOpacity(
              duration: const Duration(milliseconds: 1000),
              opacity: _textOpacity,
              curve: Curves.easeOut,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 1200),
                scale: _textScale,
                curve: Curves.easeOutBack, // হালকা ইলাস্টিক ইফেক্ট
                child: Column(
                  mainAxisSize: MainAxisSize.min, // সেন্টারে রাখার জন্য
                  children: [
                    // মূল "Vx" টেক্সট
                    Text(
                      "Vx",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 60, // বড় সাইজ
                        fontWeight: FontWeight.bold,
                        letterSpacing: -2.0, // টিকটক স্টাইলে কাছাকাছি অক্ষর
                        fontFamily: 'BebasNeue', // যদি এই ফন্ট থাকে, নতুবা ডিফল্ট bold হবে
                        shadows: [
                          // টেক্সটের পিছনে হালকা গ্লো
                          Shadow(
                            color: accentColor.withOpacity(0.8),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),
                    // ছোট করে একটা সাব-টেক্সট (ঐচ্ছিক)
                    Text(
                      "SHORT VIDEO",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 4.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// === Custom Painter: মিউজিক ভিজ্যুয়ালাইজার সার্কেল তৈরির জন্য ===
class PlayStoreMusicVisualizerPainter extends CustomPainter {
  final Color color;
  final double animValue;

  PlayStoreMusicVisualizerPainter({required this.color, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 4.0 // বারগুলোর প্রস্থ
      ..strokeCap = StrokeCap.round; // বারের মাথা গোল হবে

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double baseRadius = size.width * 0.40; // মূল বৃত্তের ব্যাসার্ধ

    const int barCount = 40; // মোট কয়টি বার হবে

    for (int i = 0; i < barCount; i++) {
      // প্রতিটি বারের এঙ্গেল ক্যালকুলেশন
      final double angle = (i * 2 * math.pi / barCount);

      // মিউজিক ইফেক্ট তৈরির মূল লজিক (Sin wave ব্যবহার করে আপ-ডাউন)
      // animValue এবং i (index) ব্যবহার করে একেক বার একেক সময়ে আপ ডাউন করবে
      double waveEffect = math.sin((animValue * 2 * math.pi) + (i * 0.8));
      
      // waveEffect কে positive range এ আনা (০ থেকে ১)
      waveEffect = (waveEffect + 1) / 2;

      // বারের উচ্চতা (মিনিমাম ৫, ম্যাক্সিমাম ২৫)
      final double barHeight = 5 + (waveEffect * 20); 

      // বারের শুরু এবং শেষ পয়েন্ট (বৃত্তাকার পথে)
      // শুরু হবে baseRadius থেকে
      final double startX = centerX + baseRadius * math.cos(angle);
      final double startY = centerY + baseRadius * math.sin(angle);

      // শেষ হবে baseRadius + barHeight এ
      final double endX = centerX + (baseRadius + barHeight) * math.cos(angle);
      final double endY = centerY + (baseRadius + barHeight) * math.sin(angle);

      // লাইন ড্র করা
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant PlayStoreMusicVisualizerPainter oldDelegate) {
    // এনিমেশন চলছে তাই সবসময় রিপেইন্ট হবে
    return oldDelegate.animValue != animValue || oldDelegate.color != color;
  }
}
