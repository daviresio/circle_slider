import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class MathHelper {
  static double remap(
    double value,
    double start1,
    double stop1,
    double start2,
    double stop2,
  ) {
    final outgoing =
        start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1));

    return outgoing;
  }

  static double coordinatesToRadians(Offset center, Offset coords) {
    final a = coords.dx - center.dx;
    final b = coords.dy - center.dy;
    return radiansNormalized(math.atan2(b, a));
  }

  static double radiansNormalized(double radians) {
    var n = radians + math.pi / 2;

    if (n < 0) {
      n = n + 2 * math.pi;
    }

    return n;
  }

  static bool isPointAlongCircle({
    required Offset point,
    required Offset center,
    required double radius,
    required double touchArea,
  }) {
    final dx = math.pow(point.dx - center.dx, 2);
    final dy = math.pow(point.dy - center.dy, 2);
    final distance = math.sqrt(dx + dy);
    return (distance - radius).abs() < touchArea;
  }
}
