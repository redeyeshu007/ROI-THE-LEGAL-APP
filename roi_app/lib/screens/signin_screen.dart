import 'dart:math';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_signup/screens/forget_passsword_screen.dart';
import 'package:login_signup/screens/homepage_screen.dart';
import 'package:login_signup/screens/signup_screen.dart';
import 'package:login_signup/screens/verify.dart';
import 'package:login_signup/screens/wrapper.dart';
import 'package:login_signup/theme/app_colors.dart';
import 'package:login_signup/widgets/dynamic_particles.dart';
import 'package:login_signup/widgets/falling_symbols.dart';
import 'package:login_signup/widgets/rgb_border_painter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Animated Sign-In — Premium Crystal Theme with RGB & Neon effects
// ─────────────────────────────────────────────────────────────────────────────

// ── Legal Symbol Particle
class _LegalParticle {
  final String symbol;
  final double x;        // 0..1 (relative screen width)
  final double y;        // starting y (can be above screen)
  final double size;
  final double speed;
  final double opacity;
  final double rotation;
  final double rotationSpeed;
  final Color color;

  _LegalParticle({
    required this.symbol,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
  });
}

class _ParticleSystem extends StatefulWidget {
  const _ParticleSystem();
  @override
  State<_ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<_ParticleSystem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final _rng = Random();
  late List<_LegalParticle> _particles;

  static const _symbols = ['⚖️', '📜', '🏛️', '⚔️', '🔏', '📋', '🗝️', '🪪', '⚖', '§', '¶', '🔖'];
  static const _colors = [
    Color(0xFF6C3AED),
    Color(0xFF8B5CF6),
    Color(0xFF4F46E5),
    Color(0xFFF59E0B),
    Color(0xFF059669),
    Color(0xFF7C3AED),
    Color(0xFF3B82F6),
  ];

  @override
  void initState() {
    super.initState();
    _particles = List.generate(22, (_) => _mkParticle(_rng.nextDouble()));
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_tick)
      ..repeat();
  }

  _LegalParticle _mkParticle(double startFraction) => _LegalParticle(
        symbol: _symbols[_rng.nextInt(_symbols.length)],
        x: _rng.nextDouble(),
        y: startFraction * 1.4 - 0.2,  // spread them from -0.2 to 1.2
        size: 16 + _rng.nextDouble() * 26,
        speed: 0.00008 + _rng.nextDouble() * 0.00014,
        opacity: 0.08 + _rng.nextDouble() * 0.22,
        rotation: _rng.nextDouble() * pi * 2,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 0.006,
        color: _colors[_rng.nextInt(_colors.length)],
      );

  void _tick() {
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < _particles.length; i++) {
        final p = _particles[i];
        final newY = p.y + p.speed;
        if (newY > 1.15) {
          _particles[i] = _mkParticle(-0.15);
        } else {
          _particles[i] = _LegalParticle(
            symbol: p.symbol,
            x: p.x,
            y: newY,
            size: p.size,
            speed: p.speed,
            opacity: p.opacity,
            rotation: p.rotation + p.rotationSpeed,
            rotationSpeed: p.rotationSpeed,
            color: p.color,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      return Stack(
        children: _particles.map((p) {
          return Positioned(
            left: p.x * box.maxWidth,
            top: p.y * box.maxHeight,
            child: Transform.rotate(
              angle: p.rotation,
              child: Opacity(
                opacity: p.opacity,
                child: Text(
                  p.symbol,
                  style: TextStyle(
                    fontSize: p.size,
                    color: p.symbol.length == 1 ? p.color : null,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RGB Neon Wrapper Widget
// ─────────────────────────────────────────────────────────────────────────────

class RGBNeonWrapper extends StatelessWidget {
  final Widget child;
  final double animationValue;
  final double borderRadius;
  final double strokeWidth;
  final bool hasGlow;

  const RGBNeonWrapper({
    super.key,
    required this.child,
    required this.animationValue,
    this.borderRadius = 16.0,
    this.strokeWidth = 1.5,
    this.hasGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = HSLColor.fromAHSL(1.0, (animationValue * 360), 0.7, 0.5).toColor();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: hasGlow ? [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ] : [],
      ),
      child: CustomPaint(
        painter: RGBBorderPainter(
          animationValue: animationValue,
          strokeWidth: strokeWidth,
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sign-In Screen
// ─────────────────────────────────────────────────────────────────────────────

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool isloading = false;
  String errorMessage = '';
  final _formSignInKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  // Entrance animations
  late AnimationController _entranceCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _logoScale;

  // Shimmer pulse for the button
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  // RGB Border animation
  late AnimationController _rgbCtrl;

  @override
  void initState() {
    super.initState();

    // email.text = 'Sriramgandhi@gmmail.com'; // Removed pre-fill as per request for "faded hint"

    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _fadeIn = CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.2, 1.0, curve: Curves.easeOut));
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)));
    _logoScale = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)));

    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _shimmerAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));

    _rgbCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    _entranceCtrl.dispose();
    _shimmerCtrl.dispose();
    _rgbCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formSignInKey.currentState!.validate()) {
      Get.snackbar(
        'validation_error'.tr,
        'please_check_fields'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
      );
      return;
    }

    setState(() { isloading = true; errorMessage = ''; });
    try {
      final String trimmedEmail = email.text.trim();
      
      debugPrint('Attempting login for: $trimmedEmail');
      
      UserCredential userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: trimmedEmail, password: password.text);
      
      if (userCred.user != null) {
        debugPrint('Sign-in successful: ${userCred.user!.uid}');
        if (!userCred.user!.emailVerified) {
          debugPrint('Email NOT verified, redirecting to verify page.');
          Get.to(() => const Verify());
        } else {
          Get.offAll(() => const Wrapper());
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FIREBASE AUTH ERROR: ${e.code} - ${e.message}');
      String msg = 'login_failed_err'.tr;
      if (e.code == 'user-not-found') msg = 'email_not_found_err'.tr;
      else if (e.code == 'wrong-password') msg = 'wrong_password_err'.tr;
      else if (e.code == 'invalid-email') msg = 'invalid_email_msg'.tr;
      else if (e.code == 'user-disabled') msg = 'account_disabled_err'.tr;
      else if (e.code == 'too-many-requests') msg = 'Too many attempts. Try again later.';
      else if (e.code == 'network-request-failed') msg = 'Network error. Please check your connection.';
      else msg = 'Error (${e.code}): ${e.message ?? e.toString()}';
      
      setState(() { errorMessage = msg; });
      
      Get.snackbar(
        'login_failed'.tr,
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
      );
    } catch (e) {
      debugPrint('SIGN IN ERROR: $e');
      setState(() { errorMessage = 'error_occurred'.trParams({'error': e.toString()}); });
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
    if (mounted) setState(() { isloading = false; });
  }

  Future<void> _googleSignIn() async {
    setState(() { isloading = true; errorMessage = ''; });
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
        serverClientId: '224150240249-edpp85q0a84tvak2gd9fi19s4kad8eq8.apps.googleusercontent.com',
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() { isloading = false; });
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential cred = await FirebaseAuth.instance.signInWithCredential(credential);
      if (cred.user != null) Get.offAll(() => const Wrapper());
    } catch (e) {
      debugPrint('GOOGLE SIGN IN ERROR: $e');
      setState(() { errorMessage = 'google_signin_failed'.trParams({'error': e.toString()}); });
    }
    if (mounted) setState(() { isloading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // ── 1. Animated Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF3F4F6), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ── 2. Floating Crystal Accents
          Positioned(
            top: -size.height * 0.12,
            left: -size.width * 0.15,
            child: _buildRadialGlow(size.width * 0.8, AppColors.primary.withOpacity(0.15)),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            right: -size.width * 0.1,
            child: _buildRadialGlow(size.width * 0.7, const Color(0xFFF59E0B).withOpacity(0.12)),
          ),

          // ── 3. Floating legal symbols
          const Positioned.fill(child: _ParticleSystem()),

          // ── 4. Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Logo entrance
                      ScaleTransition(
                        scale: _logoScale,
                        child: FadeTransition(
                          opacity: _fadeIn,
                          child: _buildLogo(),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Crystal Login Card
                      FadeTransition(
                        opacity: _fadeIn,
                        child: SlideTransition(
                          position: _slideUp,
                          child: _buildCard(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadialGlow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(children: [
      // Glowing logo container
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 40, spreadRadius: 2),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Image.asset('assets/images/roi_logo_premium.png', width: 64, height: 64),
            ),
          ),
        ),
      ),
      const SizedBox(height: 18),
      Text(
        'rules_of_india'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          foreground: Paint()
            ..shader = LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight, const Color(0xFF4F46E5)],
            ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
        ),
      ),
    ]);
  }

  Widget _buildCard() {
    return ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Form(
              key: _formSignInKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('welcome_back_signin'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w900, fontFamily: 'PlusJakartaSans')),
                  const SizedBox(height: 8),
                  Text('signin_journey_desc'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontFamily: 'Inter', height: 1.4, fontWeight: FontWeight.w500)),

                  const SizedBox(height: 32),

                  // Email
                  _buildFieldLabel('email_label'.tr),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'enter_email_err'.tr;
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'invalid_email_err'.tr;
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'sriramgandhi@gmail.com',
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.2), fontWeight: FontWeight.w400),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.5),
                      prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: Text(
                      'use_full_email_hint'.tr,
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary.withOpacity(0.7), fontWeight: FontWeight.w500),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Password
                  _buildFieldLabel('password_label'.tr),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: password,
                    obscureText: !_isPasswordVisible,
                    autofillHints: const [AutofillHints.password],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'enter_password_err'.tr;
                      if (value.length < 6) return 'password_length_err'.tr;
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'password_hint'.tr,
                      filled: true,
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.2), fontWeight: FontWeight.w400),
                      fillColor: Colors.white.withOpacity(0.5),
                      prefixIcon: const Icon(Icons.lock_person_rounded, size: 20, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 20),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Get.to(() => const ForgetPasswordScreen()),
                      child: Text('forgot_password_btn'.tr,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary)),
                    ),
                  ),

                  if (errorMessage.isNotEmpty) _buildError(),

                  const SizedBox(height: 24),

                  // ── Premium Sign-In Button
                  _buildSignInButton(),

                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 24),

                  // ── Neon Google Button
                  _buildNeonGoogleButton(),

                  const SizedBox(height: 32),
                  _buildSignUpLink(),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.error.withOpacity(0.3))),
      child: Text(errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildSignInButton() {
    if (isloading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (context, child) {
        return Container(
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                Color.lerp(AppColors.primary, Colors.white, 0.1 * _shimmerAnim.value)!,
                const Color(0xFF4F46E5),
              ],
            ),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: -2),
            ],
          ),
          child: ElevatedButton(
            onPressed: _signIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: Text('sign_in_label'.tr, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
          ),
        );
      },
    );
  }

  Widget _buildNeonGoogleButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 15, spreadRadius: 1),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: OutlinedButton.icon(
            onPressed: _googleSignIn,
            icon: Image.asset('assets/images/google_logo.png', width: 22, height: 22, errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata)),
            label: Text('continue_google'.tr, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary)),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.4),
              side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text('new_to_roi'.tr, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => Get.to(() => const SignUpScreen()),
          child: Text('create_account_btn'.tr,
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 14)),
        ),
      ]),
    );
  }

  Widget _buildFieldLabel(String label) => Text(label,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Inter'));

  Widget _buildDivider() => Row(children: [
    const Expanded(child: Divider(color: Colors.white24, thickness: 1.5)),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text('or_text'.tr, style: const TextStyle(color: AppColors.textHint, fontSize: 12, fontWeight: FontWeight.w800)),
    ),
    const Expanded(child: Divider(color: Colors.white24, thickness: 1.5)),
  ]);
}
