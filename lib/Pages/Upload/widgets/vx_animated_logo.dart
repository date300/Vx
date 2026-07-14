import 'package:flutter/material.dart';
import 'dart:math' as math;

class VxSmallAnimatedLogo extends StatefulWidget {
  const VxSmallAnimatedLogo({super.key});

  @override
  State<VxSmallAnimatedLogo> createState() => _VxSmallAnimatedLogoState();
}

class _VxSmallAnimatedLogoState extends State<VxSmallAnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: const [
                Colors.blueAccent,
                Colors.pinkAccent,
                Colors.blueAccent,
              ],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
          ),
          child: Center(
            child: Container(
              width: 41,
              height: 41,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  "Vx",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
