import 'package:flutter/widgets.dart';

class UltraFastScrollPhysics extends PageScrollPhysics {
  const UltraFastScrollPhysics({super.parent});

  @override
  UltraFastScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return UltraFastScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 0.8,
        stiffness: 180,
        damping: 24,
      );
}
