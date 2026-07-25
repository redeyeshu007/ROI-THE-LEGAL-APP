import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

enum _ObstacleType { car, pedestrian }

class _Obstacle {
  int lane; // 0, 1, 2
  double yProgress; // 0.0 (top) → 1.0 (bottom)
  final _ObstacleType type;

  _Obstacle({
    required this.lane,
    required this.type,
  }) : yProgress = 0.0;
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class LegalSurvivalRunnerScreen extends StatefulWidget {
  const LegalSurvivalRunnerScreen({super.key});

  @override
  State<LegalSurvivalRunnerScreen> createState() =>
      _LegalSurvivalRunnerScreenState();
}

class _LegalSurvivalRunnerScreenState extends State<LegalSurvivalRunnerScreen>
    with TickerProviderStateMixin {
  // Road & Frame Controller
  late AnimationController _gameController;
  
  // State
  int _carLane = 1;
  bool _gameOver = false;
  bool _gameStarted = false;
  double _score = 0;
  bool _isBraking = false;
  
  // Game Logic
  final List<_Obstacle> _obstacles = [];
  final Random _rng = Random();
  double _difficultySpeed = 0.005; // Base increment per frame
  double _elapsedTime = 0;
  
  // Events
  bool _isTrafficSignalActive = false;
  Color _signalColor = Colors.green;
  double _eventTimer = 0;
  bool _didBrakeForRed = false;
  bool _showSignalBanner = false;

  @override
  void initState() {
    super.initState();
    _gameController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _gameController.addListener(_gameLoop);
  }

  void _gameLoop() {
    if (!_gameStarted || _gameOver) return;

    setState(() {
      _elapsedTime += 0.016; // Approx 60fps increment
      _eventTimer += 0.016;

      // Difficulty Balancing: Increase speed every 15s
      double speedMultiplier = _isBraking ? 0.5 : 1.0;
      double currentSpeed = (0.006 + (_elapsedTime / 15) * 0.0015).clamp(0.006, 0.02);
      
      // Update Obstacles
      for (int i = _obstacles.length - 1; i >= 0; i--) {
        _obstacles[i].yProgress += currentSpeed * speedMultiplier;
        
        // Collision checks
        if (_obstacles[i].yProgress >= 0.75 && _obstacles[i].yProgress <= 0.88) {
          if (_obstacles[i].lane == _carLane) {
            if (_obstacles[i].type == _ObstacleType.pedestrian && _isBraking) {
              // Responsible driving: Avoided pedestrian
              _showFeedback("accident_avoided".tr, Colors.green);
            } else {
              _triggerGameOver(_obstacles[i].type);
            }
          }
        }

        // Cleanup and Scoring
        if (_obstacles[i].yProgress > 1.2) {
          _obstacles.removeAt(i);
          _score += 10;
        }
      }

      // Spawning Logic (Requirement: Only one active obstacle at a time)
      if (_obstacles.isEmpty && !_isTrafficSignalActive) {
        if (_rng.nextDouble() < 0.05) {
          _spawnObstacle();
        }
      }

      // Event Logic: Traffic Signal
      if (_eventTimer > 20 && !_isTrafficSignalActive) {
        _triggerTrafficEvent();
      }
    });
  }

  void _spawnObstacle() {
    bool isPedestrian = _rng.nextDouble() < 0.2;
    _obstacles.add(_Obstacle(
      lane: _rng.nextInt(3),
      type: isPedestrian ? _ObstacleType.pedestrian : _ObstacleType.car,
    ));
  }

  void _triggerTrafficEvent() {
    _isTrafficSignalActive = true;
    _didBrakeForRed = false;
    _signalColor = Colors.red;
    _showSignalBanner = true;
    
    // Check after 3 seconds if user braked
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || _gameOver) return;
      if (_isBraking) {
        _showFeedback("traffic_rules_followed".tr, Colors.green);
        setState(() {
          _isTrafficSignalActive = false;
          _showSignalBanner = false;
          _eventTimer = 0;
        });
      } else {
        _violateTrafficSignal();
      }
    });
  }

  void _violateTrafficSignal() {
    _gameOver = true;
    _gameController.stop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("traffic_violation_title".tr, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text(
          "traffic_violation_desc".tr,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restartGame();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: Text("retry".tr, style: const TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  void _showFeedback(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color.withOpacity(0.8),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _triggerGameOver(_ObstacleType reason) {
    if (_gameOver) return;
    _gameOver = true;
    _gameController.stop();
    setState(() {});
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _gameOver = false;
      _score = 0;
      _elapsedTime = 0;
      _eventTimer = 0;
      _obstacles.clear();
      _isTrafficSignalActive = false;
      _showSignalBanner = false;
    });
    _gameController.repeat();
  }

  void _restartGame() {
    _startGame();
  }

  void _moveLane(int delta) {
    if (_gameOver || !_gameStarted) return;
    setState(() {
      _carLane = (_carLane + delta).clamp(0, 2);
    });
  }

  @override
  void dispose() {
    _gameController.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < -300) _moveLane(-1);
          if (details.primaryVelocity! > 300) _moveLane(1);
        },
        onLongPressStart: (_) => setState(() => _isBraking = true),
        onLongPressEnd: (_) => setState(() => _isBraking = false),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              final laneW = w / 3;
              return RepaintBoundary(
                child: Stack(
                  children: [
                    // 1. Scrolling road
                    _buildRoad(w, h),
                    
                    // 2. Lane dividers
                    _buildLaneDividers(w, h),

                    // 3. Traffic Signal UI
                    if (_showSignalBanner) _buildTrafficSignalHUD(w),

                    // 4. Obstacles
                    ..._obstacles.map((o) => _buildObstacle(o, w, h, laneW)),

                    // 5. Car
                    _buildCar(w, h, laneW),

                    // 6. Score + Braking Indicator
                    _buildHUD(),

                    // 7. Overlays
                    if (!_gameStarted) _buildStartScreen(w),
                    if (_gameOver) _buildGameOverOverlay(w),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRoad(double w, double h) {
    return AnimatedBuilder(
      animation: _gameController,
      builder: (_, __) {
        final speed = _isBraking ? 0.5 : 1.0;
        final offset = (_gameController.value * speed * h) % h;
        return Stack(
          children: [
            Positioned(
              top: offset - h,
              left: 0,
              width: w,
              height: h * 2,
              child: _RoadPainterWidget(width: w, height: h * 2),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrafficSignalHUD(double w) {
    return Positioned(
      top: 60,
      left: (w - 120) / 2,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent, width: 2),
        ),
        child: Column(
          children: [
            Text("traffic_signal".tr, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            CircleAvatar(radius: 12, backgroundColor: _signalColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLaneDividers(double w, double h) {
    return Positioned.fill(
      child: Row(
        children: [
          const Spacer(),
          Container(width: 2, color: Colors.white10),
          const Spacer(),
          Container(width: 2, color: Colors.white10),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildObstacle(_Obstacle obs, double w, double h, double laneW) {
    final top = obs.yProgress * h;
    final left = obs.lane * laneW + (laneW - 60) / 2;
    return Positioned(
      top: top,
      left: left,
      child: obs.type == _ObstacleType.pedestrian 
        ? _PedestrianWidget() 
        : _ObstacleWidget(),
    );
  }

  Widget _buildCar(double w, double h, double laneW) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      top: h * 0.78,
      left: _carLane * laneW + (laneW - 64) / 2,
      child: Column(
        children: [
          if (_isBraking)
            Text("braking".tr, style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          _CarWidget(braking: _isBraking),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('game_score'.trParams({'score': _score.toInt().toString()}), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 20)),
          if (_isBraking)
            const Icon(Icons.flash_on, color: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildStartScreen(double w) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.swipe_left_alt_rounded, color: Colors.amber, size: 64),
            const SizedBox(height: 16),
            Text("game_title".tr, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 12),
            Text(
              "game_instructions".tr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
              child: Text("start_driving".tr, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay(double w) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.9),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.report_problem_rounded, color: Colors.redAccent, size: 80),
            const SizedBox(height: 20),
            Text("accident_occurred".tr, style: const TextStyle(color: Colors.redAccent, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _ipcBadge("IPC 279", "rash_driving_title".tr),
            const SizedBox(height: 10),
            _ipcBadge("IPC 304A", "negligence_title".tr),
            const SizedBox(height: 30),
            Text("${"game_score".trParams({'score': _score.toInt().toString()})}", style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _restartGame,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12)),
              child: Text("try_again".tr, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: Text("exit".tr, style: const TextStyle(color: Colors.white38))),
          ],
        ),
      ),
    );
  }

  Widget _ipcBadge(String section, String desc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.redAccent.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(section, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(desc, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Painters
// ─────────────────────────────────────────────────────────────────────────────

class _RoadPainterWidget extends StatelessWidget {
  final double width;
  final double height;
  const _RoadPainterWidget({required this.width, required this.height});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(width, height), painter: _RoadPainter());
  }
}

class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()..color = const Color(0xFF1A1A1A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), roadPaint);
    final dashPaint = Paint()..color = Colors.white24..strokeWidth = 3;
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(size.width / 3, y), Offset(size.width / 3, y + 35), dashPaint);
      canvas.drawLine(Offset(size.width * 2 / 3, y), Offset(size.width * 2 / 3, y + 35), dashPaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CarWidget extends StatelessWidget {
  final bool braking;
  const _CarWidget({this.braking = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 90,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: braking ? Colors.redAccent.withOpacity(0.6) : Colors.black45, blurRadius: braking ? 15 : 10, spreadRadius: 2),
        ],
      ),
      child: CustomPaint(painter: _CarPainter(braking: braking)),
    );
  }
}

class _CarPainter extends CustomPainter {
  final bool braking;
  _CarPainter({required this.braking});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.amber;
    final w = size.width;
    final h = size.height;
    
    // Body with depth
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8), const Radius.circular(10)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, h * 0.2, w * 0.7, h * 0.5), const Radius.circular(8)), Paint()..color = Colors.black26);
    
    // Windshield
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.2, h * 0.25, w * 0.6, h * 0.15), const Radius.circular(4)), Paint()..color = Colors.lightBlueAccent.withOpacity(0.6));
    
    // Taillights
    final tailPaint = Paint()..color = braking ? Colors.redAccent : Colors.red.withOpacity(0.4);
    canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.85, w * 0.2, h * 0.05), tailPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.65, h * 0.85, w * 0.2, h * 0.05), tailPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ObstacleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 85,
      decoration: const BoxDecoration(boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 8)]),
      child: CustomPaint(painter: _ObstaclePainter()),
    );
  }
}

class _ObstaclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey[400]!;
    final w = size.width;
    final h = size.height;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(8)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.7), const Radius.circular(6)), Paint()..color = Colors.redAccent);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PedestrianWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.directions_walk_rounded, color: Colors.white, size: 40);
  }
}
