import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ReactiveTextBackground extends StatefulWidget {
  final int count;
  final double opacity;
  const ReactiveTextBackground({super.key, this.count = 12, this.opacity = 0.05});

  @override
  State<ReactiveTextBackground> createState() => _ReactiveTextBackgroundState();
}

class _ReactiveTextBackgroundState extends State<ReactiveTextBackground>
    with TickerProviderStateMixin {
  final List<_GlassFragment> _fragments = [];
  final Random _rng = Random();
  late AnimationController _mainCtrl;

  final List<String> _words = ['LAW', 'JUSTICE', 'ROI', 'COURT', 'LIBERTY', 'RIGHTS', 'ETHICS', 'CONSTITUTION', 'RULES'];

  @override
  void initState() {
    super.initState();
    _mainCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    
    for (int i = 0; i < widget.count; i++) {
      _fragments.add(_GlassFragment(
        text: _words[_rng.nextInt(_words.length)],
        x: _rng.nextDouble(),
        y: _rng.nextDouble() * -1, // Start above
        speed: 0.005 + _rng.nextDouble() * 0.01, // Faster falling
        rotationSpeed: (_rng.nextDouble() - 0.5) * 0.15, // More chaotic rotation
        fontSize: 10 + _rng.nextDouble() * 25,
        tilt: _rng.nextDouble() * 0.5,
      ));
    }
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainCtrl,
      builder: (context, _) {
        for (var f in _fragments) {
          f.y += f.speed;
          f.rotation += f.rotationSpeed;
          // Add a bit of jitter
          f.x += (_rng.nextDouble() - 0.5) * 0.002;
          
          if (f.y > 1.2) {
            f.y = -0.2;
            f.x = _rng.nextDouble();
            f.speed = 0.005 + _rng.nextDouble() * 0.01;
          }
        }
        return CustomPaint(
          painter: _GlassPainter(_fragments, widget.opacity),
          size: Size.infinite,
        );
      },
    );
  }
}

class _GlassFragment {
  String text;
  double x, y, speed, rotation, rotationSpeed, fontSize, tilt;
  _GlassFragment({
    required this.text,
    required this.x,
    required this.y,
    required this.speed,
    required this.rotationSpeed,
    required this.fontSize,
    required this.tilt,
    this.rotation = 0,
  });
}

class _GlassPainter extends CustomPainter {
  final List<_GlassFragment> fragments;
  final double opacity;
  _GlassPainter(this.fragments, this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    for (var f in fragments) {
      final textSpan = TextSpan(
        text: f.text,
        style: TextStyle(
          color: Colors.white.withOpacity(opacity),
          fontSize: f.fontSize,
          fontWeight: FontWeight.w900,
          fontFamily: 'PlusJakartaSans',
          letterSpacing: 2,
          fontStyle: FontStyle.italic,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      final pos = Offset(f.x * size.width, f.y * size.height);
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(f.rotation);
      canvas.skew(f.tilt, 0); // Add a "shard" skew effect
      
      // Draw a subtle "glow" or shadow for glass feel
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
