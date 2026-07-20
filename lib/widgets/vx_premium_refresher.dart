import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Services/native_service.dart';
import '../Services/haptic_service.dart';

class VxPremiumRefresher extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color color;

  const VxPremiumRefresher({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color = Colors.pinkAccent,
  });

  @override
  State<VxPremiumRefresher> createState() => _VxPremiumRefresherState();
}

class _VxPremiumRefresherState extends State<VxPremiumRefresher>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  double _pullDistance = 0.0;
  bool _isRefreshing = false;
  bool _canRefresh = false;
  final double _threshold = 120.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onNotification(ScrollNotification notification) {
    if (_isRefreshing) return;

    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels < 0) {
        setState(() {
          _pullDistance = notification.metrics.pixels.abs();
          
          // Use C++ to calculate the elastic stretch progress
          final progress = nativeService.calculateLiquidStretch(_pullDistance, _threshold);
          
          if (progress >= 1.0 && !_canRefresh) {
            _canRefresh = true;
            HapticService.impactMedium();
          } else if (progress < 1.0 && _canRefresh) {
            _canRefresh = false;
          }
        });
      } else if (_pullDistance != 0) {
        setState(() => _pullDistance = 0);
      }
    } else if (notification is ScrollEndNotification) {
      final progress = nativeService.calculateLiquidStretch(_pullDistance, _threshold);
      if (progress >= 1.0) {
        _startRefresh();
      } else {
        setState(() {
          _pullDistance = 0;
          _canRefresh = false;
        });
      }
    }
  }

  Future<void> _startRefresh() async {
    setState(() {
      _isRefreshing = true;
      _pullDistance = _threshold;
    });
    
    HapticService.impactHeavy();
    
    await widget.onRefresh();
    
    // Minimal delay to let user see the "Success" state
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _pullDistance = 0;
        _canRefresh = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = nativeService.calculateLiquidStretch(_pullDistance, _threshold).clamp(0.0, 1.5);
    
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _onNotification(notification);
        return false;
      },
      child: Stack(
        children: [
          widget.child,
          if (_pullDistance > 0 || _isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                alignment: Alignment.center,
                child: _buildIndicator(progress),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIndicator(double progress) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final rippleSize = 40 + (progress * 20);
        final isMax = progress >= 1.0;
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Liquid Ripple Background
            if (isMax || _isRefreshing)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, val, child) {
                  return Container(
                    width: 40 + (60 * val),
                    height: 40 + (60 * val),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.color.withOpacity(0.4 * (1.0 - val)),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),
            
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3 * progress),
                    blurRadius: 10 * progress,
                    spreadRadius: 2 * progress,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _isRefreshing ? null : progress.clamp(0.0, 1.0),
                    valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                    strokeWidth: 3,
                  ),
                  if (!_isRefreshing)
                    Icon(
                      Icons.arrow_downward,
                      color: widget.color.withOpacity(progress),
                      size: 20 * progress.clamp(0.5, 1.0),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
