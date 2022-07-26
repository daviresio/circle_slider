import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'helpers/math_helper.dart';

const indicatorRadius = 20.0;

class CircleSliderPainter extends CustomPainter {
  final double widgetSize;
  final double value;

  CircleSliderPainter({required this.widgetSize, required this.value});

  final whiteCirclePainter = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSkeleton(canvas: canvas);

    _drawValueAndIndicators(canvas: canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _drawSkeleton({required Canvas canvas}) {
    const markSize = 4.0;

    final markArcPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = markSize;

    final externalArc = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = indicatorRadius * 2;

    final middleArc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = indicatorRadius
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(widgetSize, widgetSize),
        [
          const Color(0XFFFFEFE1),
          const Color(0XFFFCCFC2),
        ],
      );

    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = ui.PaintingStyle.fill;

    final backgroundOverlayPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(widgetSize, widgetSize),
        [
          const Color(0XFFFFFEFF),
          const Color(0XFFFFEEED),
        ],
      );

    canvas.drawArc(
      Offset.zero & Size(widgetSize, widgetSize),
      0,
      math.pi * 2,
      false,
      externalArc,
    );

    canvas.drawArc(
      const Offset(30, 30) & Size(widgetSize - 60, widgetSize - 60),
      0,
      math.pi * 2,
      false,
      middleArc,
    );

    canvas.drawArc(
      const Offset(-18, -18) & Size(widgetSize + 36, widgetSize + 36),
      0,
      math.pi * 2,
      false,
      markArcPaint,
    );

    canvas.drawCircle(Offset(widgetSize / 2, widgetSize / 2),
        widgetSize / 2 - indicatorRadius * 2, backgroundPaint);

    canvas.drawCircle(Offset(widgetSize / 2, widgetSize / 2),
        widgetSize / 2 - indicatorRadius * 2, backgroundOverlayPaint);
  }

  void _drawValueAndIndicators({required Canvas canvas}) {
    final path = Path();

    final parsedValue = MathHelper.remap(value, 0, 100, 0, math.pi * 2);

    path.addArc(
      Rect.fromLTWH(0, 0, widgetSize, widgetSize),
      -math.pi / 2,
      parsedValue,
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = indicatorRadius * 2
        ..shader = ui.Gradient.linear(
          Offset(widgetSize * .25, widgetSize),
          Offset(widgetSize, widgetSize * .25),
          [
            const Color(0XFFFCA479),
            const Color(0XFFFFDBBA),
          ],
        ),
    );

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) {
      _drawIndicatorCircle(
        canvas: canvas,
        position: Offset(widgetSize / 2 - indicatorRadius / 2, 0),
      );
      return;
    }
    final tangent = metrics.first.getTangentForOffset(metrics.first.length);

    _drawIndicatorCircle(
      canvas: canvas,
      position: tangent!.position,
    );
  }

  void _drawIndicatorCircle({
    required Canvas canvas,
    required Offset position,
  }) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawCircle(position, indicatorRadius * .75, shadowPaint);

    canvas.drawCircle(position, indicatorRadius, whiteCirclePainter);
  }
}
