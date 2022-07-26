import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'circle_slider_gesture_recognizer.dart';
import 'circle_slider_painter.dart';
import 'helpers/math_helper.dart';

double angleToValue(double angle, double min, double max, double angleRange) {
  return percentageToValue(angleToPercentage(angle, angleRange), min, max);
}

double percentageToValue(double percentage, double min, double max) {
  return ((max - min) / 100) * percentage + min;
}

double angleToPercentage(double angle, double angleRange) {
  final step = (angleRange / 100).clamp(0, 100);

  return angle / step;
}

class CircleSlider extends StatefulWidget {
  final int maxValue;
  final int value;
  final Function(int value) onChanged;

  const CircleSlider({
    Key? key,
    required this.maxValue,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CircleSliderState createState() => _CircleSliderState();
}

class _CircleSliderState extends State<CircleSlider> {
  double size = 0.0;
  bool isDragging = false;
  final touchPadding = 16.0;

  void _notifyChange(Offset center, Offset localOffset) {
    final radians = MathHelper.coordinatesToRadians(center, localOffset);
    final currentValue = angleToValue(radians, 0, 100, math.pi * 2);
    final newValue =
        MathHelper.remap(currentValue, 0, 100, 0, widget.maxValue.toDouble())
            .round();
    widget.onChanged(newValue);
  }

  void _onPanDown(Offset details) {
    final box = context.findRenderObject()! as RenderBox;
    final localOffset = box.globalToLocal(details);
    final center = Offset(box.size.width / 2, box.size.height / 2);

    final isNearbyCircle = MathHelper.isPointAlongCircle(
        point: localOffset,
        center: center,
        radius: size / 2,
        touchArea: touchPadding);

    if (isNearbyCircle) {
      _notifyChange(center, localOffset);
      setState(() {
        isDragging = true;
      });
      HapticFeedback.mediumImpact();
    }
  }

  void _onPanUpdate(Offset details) {
    final box = context.findRenderObject()! as RenderBox;
    final localOffset = box.globalToLocal(details);
    final center = Offset(box.size.width / 2, box.size.height / 2);

    if (isDragging) {
      _notifyChange(center, localOffset);
      HapticFeedback.selectionClick();
    }
  }

  void _onPanEnd(Offset details) {
    if (isDragging) {
      setState(() {
        isDragging = false;
      });
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        size = MediaQuery.of(context).size.width * 0.75;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        CircleSliderGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<CircleSliderGestureRecognizer>(
          () => CircleSliderGestureRecognizer(
            onPanDown: _onPanDown,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
          ),
          (CircleSliderGestureRecognizer instance) {},
        ),
      },
      child: Stack(
        children: [
          CustomPaint(
            painter: CircleSliderPainter(
                widgetSize: size,
                value: MathHelper.remap(widget.value.toDouble(), 0,
                    widget.maxValue.toDouble(), 0, 100)),
            size: Size(size, size),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                '${widget.value}%',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF3B08A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
