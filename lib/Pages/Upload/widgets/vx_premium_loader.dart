import 'package:flutter/material.dart';

class VxPremiumLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const VxPremiumLoader({
    super.key,
    this.size = 6.0, // Reduced default size
    this.color,
  });

  @override
  State<VxPremiumLoader> createState() => _VxPremiumLoaderState();
}

class _VxPremiumLoaderState extends State<VxPremiumLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    _startSequentialAnimation();
  }

  void _startSequentialAnimation() async {
    if (!mounted) return;
    
    while (mounted) {
      for (var i = 0; i < 3; i++) {
        if (!mounted) return;
        _controllers[i].forward();
        await Future.delayed(const Duration(milliseconds: 150));
      }
      await Future.delayed(const Duration(milliseconds: 100));
      for (var i = 0; i < 3; i++) {
        if (!mounted) return;
        _controllers[i].reverse();
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.color ?? Theme.of(context).primaryColor;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Opacity(
              opacity: _animations[index].value.clamp(0.2, 1.0),
              child: Transform.scale(
                scale: 0.6 + (_animations[index].value * 0.4),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: themeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (_animations[index].value > 0.5)
                        BoxShadow(
                          color: themeColor.withOpacity(0.2 * _animations[index].value),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
