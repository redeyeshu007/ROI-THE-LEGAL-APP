import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_signup/screens/homepage_screen.dart';
import 'package:login_signup/screens/signin_screen.dart';
import 'package:login_signup/theme/app_colors.dart';
import 'package:login_signup/theme/app_colors.dart' show kPrimary, kPrimary2;
import 'package:login_signup/widgets/dynamic_particles.dart';
import 'package:login_signup/widgets/falling_symbols.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  void _signout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Get.offAll(() => const SignInScreen());
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        // Premium dynamic particles
        const DynamicParticlesBackground(opacity: 0.2),
        
        // Falling Indian civic symbols — unique entry-point feel
        const FallingSymbolsBackground(
          symbols: ['🇮🇳', '📖', '🔰', '⚖️', '🏀', '📜'],
          count: 12,
          opacity: 0.15,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with logo and logout
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Image.asset('assets/images/roi_logo_premium.png', width: 36, height: 36),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'rules_of_india'.tr,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'ai_legal_platform'.tr,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _signout(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.logout_rounded, color: AppColors.textSecondary, size: 16),
                            const SizedBox(width: 6),
                            Text('logout'.tr,
                                style: const TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 2),

                // Main Content
                Text(
                  'choose_language'.tr,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    color: AppColors.textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'select_learn_lang'.tr,
                  style: const TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary, fontSize: 15),
                ),

                const Spacer(),

                // English Option
                _LanguageCard(
                  title: 'English',
                  subtitle: 'Learn in English',
                  flag: '🇺🇸',
                  accentColor: AppColors.primary,
                  onTap: () {
                    Get.updateLocale(const Locale('en'));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomepageScreen()),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Hindi Option
                _LanguageCard(
                  title: 'हिन्दी',
                  subtitle: 'हिंदी में सीखें',
                  flag: '🇮🇳',
                  accentColor: const Color(0xFFF59E0B),
                  onTap: () {
                    Get.updateLocale(const Locale('hi'));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomepageScreen()),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Tamil Option
                _LanguageCard(
                  title: 'தமிழ்',
                  subtitle: 'தமிழில் கற்க',
                  flag: '🇮🇳',
                  accentColor: const Color(0xFF10B981),
                  onTap: () {
                    Get.updateLocale(const Locale('ta'));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomepageScreen()),
                    );
                  },
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _LanguageCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String flag;
  final Color accentColor;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.title,
    required this.subtitle,
    required this.flag,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends State<_LanguageCard> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500 + (100 * 1))) ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: 4).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedBuilder(
        animation: _floatAnim,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -_floatAnim.value),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _pressed ? widget.accentColor.withOpacity(0.5) : AppColors.border,
                  width: _pressed ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _pressed
                        ? widget.accentColor.withOpacity(0.2)
                        : widget.accentColor.withOpacity(0.05),
                    blurRadius: _pressed ? 20 : 12,
                    offset: _pressed ? const Offset(0, 4) : const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(widget.flag, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 3),
                        Text(widget.subtitle,
                            style: const TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.arrow_forward_rounded, color: widget.accentColor, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
