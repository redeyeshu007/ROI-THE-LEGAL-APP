import 'dart:math' as math;
import 'package:flutter/material.dart';

class CircularBrandText extends StatefulWidget {
  final String text;
  final double radius;
  final TextStyle style;
  final Duration duration;

  const CircularBrandText({
    super.key,
    this.text = "AI POWERED LEGAL SYSTEM • ",
    this.radius = 40,
    this.style = const TextStyle(
      fontSize: 8,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      letterSpacing: 2,
      fontFamily: 'PlusJakartaSans',
    ),
    this.duration = const Duration(seconds: 15),
  });

  @override
  State<CircularBrandText> createState() => _CircularBrandTextState();
}

class _CircularBrandTextState extends State<CircularBrandText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
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
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: CustomPaint(
            size: Size(widget.radius * 2, widget.radius * 2),
            painter: _CircularTextPainter(
              text: widget.text,
              radius: widget.radius,
              style: widget.style,
            ),
          ),
        );
      },
    );
  }
}

class _CircularTextPainter extends CustomPainter {
  final String text;
  final double radius;
  final TextStyle style;

  _CircularTextPainter({
    required this.text,
    required this.radius,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final double angularSpacing = (2 * math.pi) / text.length;

    for (int i = 0; i < text.length; i++) {
      final double angle = i * angularSpacing;
      
      textPainter.text = TextSpan(text: text[i], style: style);
      textPainter.layout();

      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + math.pi / 2);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
