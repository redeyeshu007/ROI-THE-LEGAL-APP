import 'package:flutter/material.dart';
import 'package:login_signup/widgets/rgb_border_painter.dart';
import 'package:login_signup/contents/pt_1.dart';
import 'package:login_signup/contents/pt_10.dart';
import 'package:login_signup/contents/pt_11.dart';
import 'package:login_signup/contents/pt_12.dart';
import 'package:login_signup/contents/pt_13.dart';
import 'package:login_signup/contents/pt_14.dart';
import 'package:login_signup/contents/pt_14A.dart';
import 'package:login_signup/contents/pt_15.dart';
import 'package:login_signup/contents/pt_16.dart';
import 'package:login_signup/contents/pt_17.dart';
import 'package:login_signup/contents/pt_18.dart';
import 'package:login_signup/contents/pt_19.dart';
import 'package:login_signup/contents/pt_2.dart';
import 'package:login_signup/contents/pt_20.dart';
import 'package:login_signup/contents/pt_21.dart';
import 'package:login_signup/contents/pt_22.dart';
import 'package:login_signup/contents/pt_3.dart';
import 'package:login_signup/contents/pt_4.dart';
import 'package:login_signup/contents/pt_4A.dart';
import 'package:login_signup/contents/pt_5.dart';
import 'package:login_signup/contents/pt_6.dart';
import 'package:login_signup/contents/pt_7.dart';
import 'package:login_signup/contents/pt_8.dart';
import 'package:login_signup/contents/pt_9.dart';
import 'package:login_signup/contents/s1.dart';
import 'package:login_signup/contents/s10.dart';
import 'package:login_signup/contents/s11.dart';
import 'package:login_signup/contents/s12.dart';
import 'package:login_signup/contents/s2.dart';
import 'package:login_signup/contents/s3.dart';
import 'package:login_signup/contents/s4.dart';
import 'package:login_signup/contents/s5.dart';
import 'package:login_signup/contents/s6.dart';
import 'package:login_signup/contents/s7.dart';
import 'package:login_signup/contents/s8.dart';
import 'package:login_signup/contents/s9.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Videos & Articles — Gradient Light Theme (Byju's style)
// ─────────────────────────────────────────────────────────────────────────────

// Color palette — light purple gradient
const _kPurple   = Color(0xFF6C3AED);
const _kPurple2  = Color(0xFF8B5CF6);
const _kBg1      = Color(0xFFEDE9FE); // light lavender
const _kBg2      = Color(0xFFF8F7FF);
const _kCard     = Color(0xFFFFFFFF);
const _kText     = Color(0xFF1E293B);
const _kSub      = Color(0xFF64748B);

class ContentsScreen extends StatefulWidget {
  const ContentsScreen({super.key});
  @override
  State<ContentsScreen> createState() => _ContentsScreenState();
}

class _ContentsScreenState extends State<ContentsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late List<AnimationController> cardControllers;
  late AnimationController rgbCtrl;

  final List<Map<String, dynamic>> _contents = [
    {'title': 'Part I: Union and its Territory',             'route': '/part1',      'emoji': '🗺️', 'cat': 'Parts'},
    {'title': 'Part II: Citizenship',                       'route': '/part2',      'emoji': '🪪', 'cat': 'Parts'},
    {'title': 'Part III: Fundamental Rights',               'route': '/part3',      'emoji': '⚖️', 'cat': 'Parts'},
    {'title': 'Part IV: Directive Principles',              'route': '/part4',      'emoji': '📋', 'cat': 'Parts'},
    {'title': 'Part IV-A: Fundamental Duties',              'route': '/part4A',     'emoji': '🤝', 'cat': 'Parts'},
    {'title': 'Part V: The Union',                          'route': '/part5',      'emoji': '🏛️', 'cat': 'Parts'},
    {'title': 'Part VI: The States',                        'route': '/part6',      'emoji': '🏢', 'cat': 'Parts'},
    {'title': 'Part VII: States in B-Part (repealed)',      'route': '/part7',      'emoji': '📜', 'cat': 'Parts'},
    {'title': 'Part VIII: The Union Territories',           'route': '/part8',      'emoji': '📍', 'cat': 'Parts'},
    {'title': 'Part IX: The Panchayats',                    'route': '/part9',      'emoji': '🌾', 'cat': 'Parts'},
    {'title': 'Part IX-A: The Municipalities',              'route': '/part9A',     'emoji': '🏘️', 'cat': 'Parts'},
    {'title': 'Part X: Scheduled & Tribal Areas',           'route': '/part10',     'emoji': '🌳', 'cat': 'Parts'},
    {'title': 'Part XI: Union & State Relations',           'route': '/part11',     'emoji': '🔗', 'cat': 'Parts'},
    {'title': 'Part XII: Finance, Property & Suits',        'route': '/part12',     'emoji': '💰', 'cat': 'Parts'},
    {'title': 'Part XIII: Trade and Commerce',              'route': '/part13',     'emoji': '🤝', 'cat': 'Parts'},
    {'title': 'Part XIV: Services under Union & States',    'route': '/part14',     'emoji': '👔', 'cat': 'Parts'},
    {'title': 'Part XIV-A: Tribunals',                      'route': '/part14A',    'emoji': '⚖️', 'cat': 'Parts'},
    {'title': 'Part XV: Elections',                         'route': '/part15',     'emoji': '🗳️', 'cat': 'Parts'},
    {'title': 'Part XVI: Special Provisions for Classes',   'route': '/part16',     'emoji': '🌟', 'cat': 'Parts'},
    {'title': 'Part XVII: Official Language',               'route': '/part17',     'emoji': '🗣️', 'cat': 'Parts'},
    {'title': 'Part XVIII: Emergency Provisions',           'route': '/part18',     'emoji': '🚨', 'cat': 'Parts'},
    {'title': 'Part XIX: Miscellaneous',                    'route': '/part19',     'emoji': '📌', 'cat': 'Parts'},
    {'title': 'Part XX: Amendment of Constitution',         'route': '/part20',     'emoji': '✏️', 'cat': 'Parts'},
    {'title': 'Part XXI: Transitional Provisions',          'route': '/part21',     'emoji': '🔄', 'cat': 'Parts'},
    {'title': 'Part XXII: Short Title and Repeal',          'route': '/part22',     'emoji': '🏁', 'cat': 'Parts'},
    {'title': 'Schedule I: Territories of India',           'route': '/schedule1',  'emoji': '🗺️', 'cat': 'Schedules'},
    {'title': 'Schedule II: Oaths and Affirmations',        'route': '/schedule2',  'emoji': '✋', 'cat': 'Schedules'},
    {'title': 'Schedule III: Forms of Oaths',               'route': '/schedule3',  'emoji': '📝', 'cat': 'Schedules'},
    {'title': 'Schedule IV: Rajya Sabha Seats',             'route': '/schedule4',  'emoji': '🏛️', 'cat': 'Schedules'},
    {'title': 'Schedule V: Scheduled Areas',                'route': '/schedule5',  'emoji': '📍', 'cat': 'Schedules'},
    {'title': 'Schedule VI: Tribal Areas',                  'route': '/schedule6',  'emoji': '🌿', 'cat': 'Schedules'},
    {'title': 'Schedule VII: Distribution of Powers',       'route': '/schedule7',  'emoji': '⚡', 'cat': 'Schedules'},
    {'title': 'Schedule VIII: Languages',                   'route': '/schedule8',  'emoji': '💬', 'cat': 'Schedules'},
    {'title': 'Schedule IX: Acquisition of Estates',        'route': '/schedule9',  'emoji': '🏠', 'cat': 'Schedules'},
    {'title': 'Schedule X: Anti-defection Act',             'route': '/schedule10', 'emoji': '🚫', 'cat': 'Schedules'},
    {'title': 'Schedule XI: Panchayats',                    'route': '/schedule11', 'emoji': '🌾', 'cat': 'Schedules'},
    {'title': 'Schedule XII: Municipalities',               'route': '/schedule12', 'emoji': '🏙️', 'cat': 'Schedules'},
  ];

  String _selectedCat = 'Parts';
  late AnimationController _orbCtrl;
  late Animation<double> _floatOffset;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    
    _orbCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat(reverse: true);
    _floatOffset = Tween<double>(begin: -6.0, end: 6.0).animate(CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut));

    rgbCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();

    cardControllers = List.generate(_contents.length,
        (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 400)));
    _animateCards();
  }

  void _animateCards() async {
    for (var i = 0; i < cardControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 25));
      if (mounted) cardControllers[i].forward();
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _orbCtrl.dispose();
    rgbCtrl.dispose();
    for (final c in cardControllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_kBg1, _kBg2, Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            // ── App Bar
            _buildAppBar(context),
            _buildSplitHero(),
            _buildCategoryFilter(),
            // ── List
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Navigator(
                  initialRoute: '/',
                  onGenerateRoute: (settings) {
                    WidgetBuilder? builder;
                    switch (settings.name) {
                      case '/part1':    builder = (_) => const VideoPlayerScreen1();   break;
                      case '/part2':    builder = (_) => const VideoPlayerScreen2();   break;
                      case '/part3':    builder = (_) => const VideoPlayerScreen3();   break;
                      case '/part4':    builder = (_) => const VideoPlayerScreen4();   break;
                      case '/part4A':   builder = (_) => const VideoPlayerScreen4A();  break;
                      case '/part5':    builder = (_) => const VideoPlayerScreen5();   break;
                      case '/part6':    builder = (_) => const VideoPlayerScreen6();   break;
                      case '/part7':    builder = (_) => const VideoPlayerScreen7();   break;
                      case '/part8':    builder = (_) => const VideoPlayerScreen8();   break;
                      case '/part9':    builder = (_) => const VideoPlayerScreen9();   break;
                      case '/part10':   builder = (_) => const VideoPlayerScreen10();  break;
                      case '/part11':   builder = (_) => const VideoPlayerScreen11();  break;
                      case '/part12':   builder = (_) => const VideoPlayerScreen12();  break;
                      case '/part13':   builder = (_) => const VideoPlayerScreen13();  break;
                      case '/part14':   builder = (_) => const VideoPlayerScreen14();  break;
                      case '/part14A':  builder = (_) => const VideoPlayerScreen14A(); break;
                      case '/part15':   builder = (_) => const VideoPlayerScreen15();  break;
                      case '/part16':   builder = (_) => const VideoPlayerScreen16();  break;
                      case '/part17':   builder = (_) => const VideoPlayerScreen17();  break;
                      case '/part18':   builder = (_) => const VideoPlayerScreen18();  break;
                      case '/part19':   builder = (_) => const VideoPlayerScreen19();  break;
                      case '/part20':   builder = (_) => const VideoPlayerScreen20();  break;
                      case '/part21':   builder = (_) => const VideoPlayerScreen21();  break;
                      case '/part22':   builder = (_) => const VideoPlayerScreen22();  break;
                      case '/schedule1': builder = (_) => const VideoPlayerScreenS1(); break;
                      case '/schedule2': builder = (_) => const VideoPlayerScreenS2(); break;
                      case '/schedule3': builder = (_) => const VideoPlayerScreenS3(); break;
                      case '/schedule4': builder = (_) => const VideoPlayerScreenS4(); break;
                      case '/schedule5': builder = (_) => const VideoPlayerScreenS5(); break;
                      case '/schedule6': builder = (_) => const VideoPlayerScreenS6(); break;
                      case '/schedule7': builder = (_) => const VideoPlayerScreenS7(); break;
                      case '/schedule8': builder = (_) => const VideoPlayerScreenS8(); break;
                      case '/schedule9': builder = (_) => const VideoPlayerScreenS9(); break;
                      case '/schedule10':builder = (_) => const VideoPlayerScreenS10();break;
                      case '/schedule11':builder = (_) => const VideoPlayerScreenS11();break;
                      case '/schedule12':builder = (_) => const VideoPlayerScreenS12();break;
                      default:
                        return MaterialPageRoute(
                          builder: (_) => _buildList(),
                        );
                    }
                    return MaterialPageRoute(builder: builder!);
                  },
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
      child: Row(children: [
        IconButton(
          icon: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: _kPurple),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 4),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (b) => const LinearGradient(colors: [_kPurple, _kPurple2]).createShader(b),
          child: const Text('Videos & Articles',
              style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w900, fontSize: 20)),
        ),
      ]),
    );
  }

  Widget _buildSplitHero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_kPurple, _kPurple2], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: _kPurple.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(children: [
        // Left: Info
        Expanded(
          flex: 6,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('LEARN BY WATCHING', style: TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w800, letterSpacing: 1.2)),
            const SizedBox(height: 6),
            const Text('Expert\nLessons 📖', style: TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w900, fontSize: 22, height: 1.1)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Text('📺 37 Topics Covered', style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 10)),
            ),
          ]),
        ),
        // Right: Floating Orb / Logo
        Expanded(
          flex: 4,
          child: AnimatedBuilder(
            animation: _floatOffset,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _floatOffset.value),
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: const Center(child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 40)),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildCategoryFilter() {
    final cats = ['Parts', 'Schedules'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Row(children: cats.map((c) {
        final sel = _selectedCat == c;
        return GestureDetector(
          onTap: () => setState(() => _selectedCat = c),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? _kPurple : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sel ? _kPurple : _kPurple.withOpacity(0.2)),
              boxShadow: sel ? [BoxShadow(color: _kPurple.withOpacity(0.3), blurRadius: 10)] : [],
            ),
            child: Text(c, style: TextStyle(color: sel ? Colors.white : _kText.withOpacity(0.6), fontWeight: sel ? FontWeight.w800 : FontWeight.w600, fontSize: 13)),
          ),
        );
      }).toList()),
    );
  }

  Widget _buildList() {
    final filtered = _contents.where((i) => i['cat'] == _selectedCat).toList();
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final ctrl = cardControllers[index % cardControllers.length];
        final anim = CurvedAnimation(parent: ctrl, curve: Curves.easeOut);
        
        return AnimatedBuilder(
          animation: Listenable.merge([anim, rgbCtrl]),
          builder: (_, child) {
            final double slideX = 40 * (1 - anim.value);
            return Transform.translate(
              offset: Offset(slideX, 0),
              child: Opacity(
                opacity: anim.value.clamp(0.0, 1.0),
                child: CustomPaint(
                  painter: RGBBorderPainter(
                    animationValue: rgbCtrl.value,
                    strokeWidth: 0.6,
                    borderRadius: 14.0,
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: Container(
            height: 64,
            margin: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: _kCard,
              borderRadius: BorderRadius.circular(14),
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.pushNamed(context, item['route']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _kPurple.withOpacity(0.1)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(children: [
                    Text(item['emoji']!, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Container(width: 3, height: 22, decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_kPurple, _kPurple2], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      borderRadius: BorderRadius.circular(2),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: Text(item['title']!, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _kText, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w600))),
                    const Icon(Icons.play_circle_filled_rounded, color: _kPurple, size: 22),
                  ]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Sub-screen builder is auto — the Navigator handles routing above.
}
