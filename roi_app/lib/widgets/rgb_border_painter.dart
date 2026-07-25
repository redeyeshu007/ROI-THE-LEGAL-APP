import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class RGBBorderPainter extends CustomPainter {
  final double animationValue;
  final double strokeWidth;
  final double borderRadius;

  RGBBorderPainter({
    required this.animationValue,
    this.strokeWidth = 2.0,
    this.borderRadius = 24.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // ── Glow effect (blur)
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    // Create a rotating gradient for the RGB effect
    const colors = [
      Color(0xFFFF0000), // Red
      Color(0xFFFF00FF), // Magenta
      Color(0xFF0000FF), // Blue
      Color(0xFF00FFFF), // Cyan
      Color(0xFF00FF00), // Green
      Color(0xFFFFFF00), // Yellow
      Color(0xFFFF0000), // Red again to loop
    ];

    final sweepGradient = SweepGradient(
      colors: colors,
      transform: GradientRotation(animationValue * 2 * math.pi),
    );

    paint.shader = sweepGradient.createShader(rect);
    glowPaint.shader = sweepGradient.createShader(rect);

    // Draw glow first, then the main border
    canvas.drawRRect(rRect, glowPaint);
    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(RGBBorderPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}
