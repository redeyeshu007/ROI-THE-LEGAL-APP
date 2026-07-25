import 'package:flutter/material.dart';
import 'package:login_signup/contents/contents.dart';
import 'package:login_signup/quizeasy/contentsquize.dart';
import 'package:login_signup/quizhard/contentsquizh.dart';
import 'package:login_signup/screens/match.dart';
import 'package:login_signup/mock_parliament/role_selection_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_signup/screens/ChatbotScreen.dart';
import 'package:login_signup/screens/NewsScreen.dart';
import 'package:login_signup/screens/language.dart';
import 'package:login_signup/theme/app_colors.dart';
import 'package:login_signup/widgets/falling_symbols.dart';
import 'package:login_signup/screens/legal_survival_runner.dart';
import 'package:login_signup/widgets/rgb_border_painter.dart';
import 'package:get/get.dart';


// ─────────────────────────────────────────────────────────────────────────────
// Gamified Dashboard — Byju's style with XP, emojis, gradient cards
// ─────────────────────────────────────────────────────────────────────────────
class Dashpage extends StatefulWidget {
  const Dashpage({super.key});

  @override
  State<Dashpage> createState() => _DashpageState();
}

class _DashpageState extends State<Dashpage> with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;
  late AnimationController rgbCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    rgbCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    rgbCtrl.dispose();
    super.dispose();
  }

  List<_Mod> get _modules => [
    _Mod(
      'content_library'.tr,
      'articles_chapters'.tr,
      '📜',
      const Color(0xFF3B82F6), const Color(0xFFEFF6FF),
      'start_reading_constitution'.tr,
      'chapters_count'.tr,
    ),
    _Mod(
      'easy_mode'.tr,
      'foundation_quizzes'.tr,
      '🌟',
      const Color(0xFF059669), const Color(0xFFECFDF5),
      'test_basic_knowledge'.tr,
      'questions_count'.tr,
    ),
    _Mod(
      'hard_mode'.tr,
      'advanced_challenges'.tr,
      '🔥',
      const Color(0xFFDC2626), const Color(0xFFFEF2F2),
      'challenge_yourself'.tr,
      'hard_mcqs_count'.tr,
    ),
    _Mod(
      'match_game'.tr,
      'drag_match_laws'.tr,
      '🎮',
      const Color(0xFF7C3AED), const Color(0xFFEDE9FE),
      'matching_game_desc'.tr,
      'multiple_rounds'.tr,
    ),
    _Mod(
      'mock_parliament'.tr,
      'debate_roleplay'.tr,
      '🏛️',
      const Color(0xFF0891B2), const Color(0xFFECFEFF),
      'parliament_sim_desc'.tr,
      'role_scenarios'.tr,
    ),
    _Mod(
      'survival_runner'.tr,
      'legal_driving_sim'.tr,
      '🚗',
      const Color(0xFFF59E0B), const Color(0xFFFFFBEB),
      'driving_sim_desc'.tr,
      'new_badge'.tr,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Stack(children: [
            // Falling learning symbols — unique to Learning Hub
            const FallingSymbolsBackground(
              symbols: ['📚', '🎓', '🌟', '✏️', '📝', '🏆'],
              count: 14,
              opacity: 0.28,
            ),
            Column(children: [
            // Custom App Bar
            Container(
              color: Colors.white.withOpacity(0.85),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5, // Increased flex
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('rules_of_india'.tr,
                            overflow: TextOverflow.visible,
                            softWrap: true, // Enabled wrapping
                            style: const TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w900, fontSize: 13)),
                        Text('ai_legal_learning'.tr,
                            overflow: TextOverflow.visible, // Changed from ellipsis
                            softWrap: true, // Enabled wrapping
                            style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 9)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _IconBtn(icon: Icons.smart_toy_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
                const SizedBox(width: 4),
                _IconBtn(icon: Icons.newspaper_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsScreen()))),
                const SizedBox(width: 4),
                _IconBtn(icon: Icons.logout_rounded, onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()));
                }),
              ]),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Hero banner with building illustration
                  _buildHero(),

                  // Section header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Row(children: [
                      Container(width: 4, height: 22, decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('choose_module'.tr, 
                            softWrap: true, // Enabled wrapping
                            style: const TextStyle(fontFamily: 'PlusJakartaSans', color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
                        Text('tap_to_begin'.tr, 
                            softWrap: true, // Enabled wrapping
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'Inter')),
                      ]),
                    ]),
                  ),

                  // Module cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: _modules.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _GamifiedModuleCard(mod: e.value, index: e.key, onTap: () => _navigate(context, e.key)),
                      )).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _floatAnim.value),
        child: child,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        constraints: const BoxConstraints(minHeight: 180),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(children: [
          // Background abstract shape
          Positioned(
            right: -30, top: -20,
            child: Container(
              width: 150, height: 150,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('mission'.tr, style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w800, letterSpacing: 1)),
              ),
              const SizedBox(height: 12),
              Text('legal_journey_starts'.tr,
                  softWrap: true,
                  style: const TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans', fontSize: 24, fontWeight: FontWeight.w900, height: 1.1)),
              const SizedBox(height: 14),
              Row(children: [
                _StatPill('395', 'articles'.tr),
                const SizedBox(width: 8),
                _StatPill('12', 'parts'.tr),
              ]),
            ]),
          ),
          // Clean ROI Indicator
          Positioned(
            right: 24, bottom: 24,
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('ROI', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'PlusJakartaSans')),
              Container(width: 40, height: 3, decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(2))),
            ]),
          ),
        ]),
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    final routes = [
      () => const ContentsScreen(),
      () => const Contents1(),
      () => const Contents2(),
      () => const MatchGameScreen(),
      () => const RoleSelectionScreen(),
      () => const LegalSurvivalRunnerScreen(),
    ];
    Navigator.push(context, MaterialPageRoute(builder: (_) => routes[index]()));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data Model
// ─────────────────────────────────────────────────────────────────────────────
class _Mod {
  final String title, subtitle, emoji, description, badge;
  final Color color, bgColor;
  const _Mod(this.title, this.subtitle, this.emoji, this.color, this.bgColor, this.description, this.badge);
}

// ─────────────────────────────────────────────────────────────────────────────
// Gamified Module Card
// ─────────────────────────────────────────────────────────────────────────────
class _GamifiedModuleCard extends StatefulWidget {
  final _Mod mod;
  final int index;
  final VoidCallback onTap;
  const _GamifiedModuleCard({required this.mod, required this.index, required this.onTap});
  @override
  State<_GamifiedModuleCard> createState() => _GamifiedModuleCardState();
}

class _GamifiedModuleCardState extends State<_GamifiedModuleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 130), lowerBound: 0.95, upperBound: 1.0)..value = 1.0;
    _scale = _ctrl;
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final m = widget.mod;
    final dashState = context.findAncestorStateOfType<_DashpageState>();

    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: () => _ctrl.forward(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scale, dashState?.rgbCtrl ?? _ctrl]),
        builder: (_, child) {
          return Transform.scale(
            scale: _scale.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: m.color.withOpacity(0.15)),
            boxShadow: [BoxShadow(color: m.color.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: IntrinsicHeight(
            child: Row(children: [
              // Color accent strip + emoji
              Container(
                width: 78,
                decoration: BoxDecoration(
                  color: m.bgColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 12),
                  Text(m.emoji, style: const TextStyle(fontSize: 30)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: m.color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text('LV ${widget.index + 1}',
                        style: TextStyle(color: m.color, fontSize: 9, fontFamily: 'Inter', fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 12),
                ]),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.title,
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w800, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(m.subtitle, softWrap: true, style: TextStyle(color: m.color, fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(m.description, softWrap: true, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter', fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),

              // Right badge + arrow
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: IntrinsicWidth(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: m.bgColor, borderRadius: BorderRadius.circular(10)),
                      child: Text(m.badge, softWrap: true, style: TextStyle(color: m.color, fontSize: 8, fontFamily: 'Inter', fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: m.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.arrow_forward_ios_rounded, color: m.color, size: 12),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, size: 18, color: AppColors.textSecondary),
    ),
  );
}

class _StatPill extends StatelessWidget {
  final String value, label;
  const _StatPill(this.value, this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
    child: Text('$value $label', style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
  );
}
