import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_signup/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:login_signup/quizeasy/pt_3.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

class VideoPlayerScreen3 extends StatefulWidget {
  const VideoPlayerScreen3({super.key});

  @override
  _VideoPlayerScreen3State createState() => _VideoPlayerScreen3State();
}

class _VideoPlayerScreen3State extends State<VideoPlayerScreen3>
    with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isVideoReady = false;
  bool _hasVideoError = false;
  bool _isRedirecting = false;
  int _redirectCountdown = 10;
  Timer? _progressTimer;
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  // TTS for localized audio
  final FlutterTts _tts = FlutterTts();
  bool _isTtsActive = false;

  final String _videoId = 'pt_3';
  String get _videoTitle => 'lesson_3_title'.tr;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _initVideo();
  }

  Future<void> _initTts() async {
    final lang = Get.locale?.languageCode ?? 'en';
    if (lang != 'en') {
      _isTtsActive = true;
      String ttsLang = 'en-US';
      if (lang == 'ta') ttsLang = 'ta-IN';
      if (lang == 'hi') ttsLang = 'hi-IN';
      await _tts.setLanguage(ttsLang);
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      _videoController.setVolume(0.0);
      // Speak ONLY the lesson title
      await _tts.speak(_videoTitle);
    }
  }

  Future<void> _initVideo() async {
    // Always use the base English video
    const String assetPath = 'assets/videos/3.mp4';
    _videoController = VideoPlayerController.asset(assetPath);
    try {
      await _videoController.initialize();
    } catch (e) {
      if (mounted) setState(() => _hasVideoError = true);
      return;
    }

    try {
      // Load saved progress
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(userId).collection('video_progress').doc(_videoId).get();
        if (doc.exists) {
          final position = doc.data()?['position'] ?? 0;
          if (position > 0 && position < _videoController.value.duration.inMilliseconds - 2000) {
            _videoController.seekTo(Duration(milliseconds: position));
          }
        }
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        allowFullScreen: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          backgroundColor: Colors.grey.shade300,
          bufferedColor: AppColors.primary.withOpacity(0.3),
        ),
      );

      _videoController.addListener(() {
        if (_videoController.value.position >= _videoController.value.duration && !_isRedirecting) {
          _startRedirectLoop();
        }
      });

      if (mounted) {
        setState(() => _isVideoReady = true);
        _progressTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
          _saveProgress();
        });
        _initTts(); // Start TTS narration for non-English
      }
    } catch (e) {
      if (mounted) setState(() => _hasVideoError = true);
    }
  }

  void _startRedirectLoop() {
    setState(() => _isRedirecting = true);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isRedirecting) return false;
      setState(() {
        _redirectCountdown--;
      });
      if (_redirectCountdown <= 0) {
        _enterQuiz();
        return false;
      }
      return true;
    });
  }

  void _enterQuiz() {
    _isRedirecting = false;
    _videoController.pause();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const QuizScreen3()),
    );
  }

  void _saveProgress() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || !_isVideoReady) return;

    final pos = _videoController.value.position.inMilliseconds;
    final total = _videoController.value.duration.inMilliseconds;
    final isDone = pos >= total - 2000;

    await FirebaseFirestore.instance.collection('users').doc(userId).collection('video_progress').doc(_videoId).set({
      'videoId': _videoId,
      'title': _videoTitle,
      'position': isDone ? 0 : pos,
      'duration': total,
      'lastUpdated': FieldValue.serverTimestamp(),
      'route': '/part3',
    }, SetOptions(merge: true));
  }

  void _showDescriptionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('lesson_details'.tr, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold)),
          content: const Text(
            'In this lesson, we cover Fundamental Rights (Part III), which are the basic human rights of all citizens, protected by the Constitution.',
            style: TextStyle(fontFamily: 'Inter'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('got_it'.tr, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _saveProgress();
    _floatCtrl.dispose();
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Custom AppBar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.primary),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _videoTitle,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                      onPressed: _showDescriptionDialog,
                    ),
                  ],
                ),
              ),

              // ── Content ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(children: [
                    // Floating Video Box
                    AnimatedBuilder(
                      animation: _floatAnim,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _floatAnim.value),
                        child: child,
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 15)),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _buildVideoPlayer(),
                      ),
                    ),
                    
                    const SizedBox(height: 32),

                  // ── Premium Horizontal Overview ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               const Text('CHAPTER OVERVIEW',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                      letterSpacing: 1.2)),
                              const SizedBox(height: 6),
                              Text(
                                'lesson_3_overview'.tr,
                                style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                    height: 1.4,
                                    fontWeight: FontWeight.w600),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.withOpacity(0.2),
                        ),
                        const SizedBox(width: 12),
                        // Stats Vertical
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPremiumChip(Icons.timer_rounded, 
                                _isVideoReady ? '${_videoController.value.duration.inMinutes}m' : '...'),
                            const SizedBox(height: 8),
                            _buildPremiumChip(Icons.menu_book_rounded, '12-35 Arg'),
                          ],
                        ),
                      ],
                    ),
                  ),

                    const SizedBox(height: 32),

                    // Key Terms section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('key_terms'.tr, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 12),
                        const Text('Equality, Freedom, Justice, Liberty, Legal Remedies.', 
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
                      ]),
                    ),

                    const SizedBox(height: 32),

                    // CTA
                    SizedBox(
                      width: double.infinity, height: 62,
                      child: ElevatedButton(
                        onPressed: _enterQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 10,
                          shadowColor: AppColors.primary.withOpacity(0.4),
                        ),
                        child: Text('take_quiz'.tr, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_hasVideoError) {
      return Container(
        color: AppColors.primaryBg,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.textSecondary, size: 40),
              const SizedBox(height: 8),
              Text('video_unavailable'.tr, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter', fontSize: 13)),
            ],
          ),
        ),
      );
    }

    if (!_isVideoReady || _chewieController == null) {
      return Container(
        color: Colors.black12,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Stack(
      children: [
        Chewie(controller: _chewieController!),
        if (_isRedirecting)
          Container(
            color: Colors.black.withOpacity(0.8),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('lesson_complete'.tr, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'PlusJakartaSans')),
                  const SizedBox(height: 12),
                  Text('starting_quiz'.trParams({'count': _redirectCountdown.toString()}), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _enterQuiz,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: Text('start_now_btn'.tr, style: const TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isRedirecting = false),
                    child: Text('cancel'.tr, style: const TextStyle(color: Colors.white60)),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPremiumChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ]),
    );
  }

  Widget _buildStatCard(String title, String val, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(children: [
        Icon(icon, size: 20, color: AppColors.primary.withOpacity(0.7)),
        const SizedBox(height: 8),
        Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'PlusJakartaSans')),
        Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
