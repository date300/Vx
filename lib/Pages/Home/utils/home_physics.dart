import 'package:flutter/widgets.dart';
import '../../../Services/native_service.dart';

class NativeSpringSimulation extends Simulation {
  final double startPosition;
  final double targetPosition;
  final double velocity;
  final double stiffness;
  final double damping;
  final double mass;

  NativeSpringSimulation({
    required this.startPosition,
    required this.targetPosition,
    required this.velocity,
    this.stiffness = 300,
    this.damping = 35,
    this.mass = 1.0,
  });

  @override
  double x(double time) {
    // Use C++ to calculate the spring position at time 'time'
    // For now, we'll use a high-performance Dart implementation that mimics C++ precision
    // and can be offloaded to FFI if we add a 'calculate_spring_position' to the C++ side.
    final double distance = startPosition - targetPosition;
    return targetPosition + nativeService.calculateJigglePhysics(time, stiffness / 100, distance, damping / 10);
  }

  @override
  double dx(double time) {
    // Approximate velocity for smoothness
    return (x(time + 0.001) - x(time)) / 0.001;
  }

  @override
  bool isDone(double time) {
    return time > 1.5; // Simulations usually settle within 1.5s
  }
}

class UltraFastScrollPhysics extends PageScrollPhysics {
  const UltraFastScrollPhysics({super.parent});

  @override
  UltraFastScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return UltraFastScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 1.0,
        stiffness: 450, // Higher stiffness for "gaming" feel
        damping: 38,    // Balanced damping for responsiveness
      );

  double _getPage(ScrollMetrics position) => position.pixels / position.viewportDimension;
  double _getPixels(ScrollMetrics position, double page) => page * position.viewportDimension;

  double _getTargetPixels(ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    
    // Use C++ to determine if we should trigger an instant snap based on velocity and distance
    final double dragDistance = (position.pixels % position.viewportDimension).abs();
    const double threshold = 0.1;

    if (nativeService.shouldTriggerInstantSnap(velocity, dragDistance, threshold)) {
      if (velocity < 0) {
        page -= 0.5;
      } else {
        page += 0.5;
      }
    } else {
      if (velocity < -tolerance.velocity) {
        page -= 0.5;
      } else if (velocity > tolerance.velocity) {
        page += 0.5;
      }
    }

    return _getPixels(position, (page + (0.5 - threshold)).roundToDouble());
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    // Blend standard velocity with native C++ momentum for "Instant" feel
    final double nativeVelocity = nativeService.getNativeVelocity();
    final double blendedVelocity = (velocity.abs() > nativeVelocity.abs()) ? velocity : nativeVelocity;

    final Tolerance tolerance = toleranceFor(position);
    final double target = _getTargetPixels(position, tolerance, blendedVelocity);
    if (target != position.pixels) {
      // Return our C++-inspired simulation for that gaming feel
      return NativeSpringSimulation(
        startPosition: position.pixels,
        targetPosition: target,
        velocity: blendedVelocity,
        stiffness: 450,
        damping: 38,
      );
    }
    return null;
  }
}
