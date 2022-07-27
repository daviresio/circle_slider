import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'circle_slider_gesture_recognizer.dart';
import 'circle_slider_painter.dart';
import 'helpers/math_helper.dart';

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
  State<CircleSlider> createState() => _CircleSliderState();
}

class _CircleSliderState extends State<CircleSlider> {
  double size = 0.0;
  bool isDragging = false;
  final touchPadding = 16.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        size = MediaQuery.of(context).size.width * 0.75;
      });
    });
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
    }
  }

  void _onPanUpdate(Offset details) {
    final box = context.findRenderObject()! as RenderBox;
    final localOffset = box.globalToLocal(details);
    final center = Offset(box.size.width / 2, box.size.height / 2);

    if (isDragging) {
      _notifyChange(center, localOffset);
    }
  }

  void _onPanEnd(Offset details) {
    if (isDragging) {
      setState(() {
        isDragging = false;
      });
    }
  }

  void _notifyChange(Offset center, Offset localOffset) {
    final radians = MathHelper.coordinatesToRadians(center, localOffset);
    final currentValue = MathHelper.angleToValue(radians, 0, 100, math.pi * 2);
    final newValue =
        MathHelper.remap(currentValue, 0, 100, 0, widget.maxValue.toDouble())
            .round();
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RawGestureDetector(
          gestures: <Type, GestureRecognizerFactory>{
            CircleSliderGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                CircleSliderGestureRecognizer>(
              () => CircleSliderGestureRecognizer(
                onPanDown: _onPanDown,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
              ),
              (CircleSliderGestureRecognizer instance) {},
            ),
          },
          child: CustomPaint(
            painter: CircleSliderPainter(
                widgetSize: size,
                value: MathHelper.remap(widget.value.toDouble(), 0,
                    widget.maxValue.toDouble(), 0, math.pi * 2)),
            size: Size(size, size),
          ),
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
    );
  }
}
