import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_signup/quizeasy/contentsquize.dart';
import 'package:login_signup/theme/app_colors.dart';
import 'package:login_signup/widgets/quiz_template.dart';
import 'package:get/get.dart';
import 'package:login_signup/screens/homepage_screen.dart';


class QuizScreen1 extends StatefulWidget {
  const QuizScreen1({super.key});

  @override
  State<QuizScreen1> createState() => _QuizScreen1State();
}

class _QuizScreen1State extends State<QuizScreen1> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<QuizQuestionData>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _fetchQuestions();
  }

  Future<List<QuizQuestionData>> _fetchQuestions() async {
    try {
      String collectionName = 'pt_2e';
      final lang = Get.locale?.languageCode;
      if (lang == 'hi') {
        collectionName = 'pt_2ehindi';
      }
      // Add more language logic as collections become available
      
      QuerySnapshot snapshot = await _firestore.collection(collectionName).get();
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return QuizQuestionData(
          article: data['article'] ?? 'No Article Provided',
          question: data['question'] ?? 'No Question Provided',
          options: List<String>.from(data['option'] ?? []),
          correctAnswer: data['correctAnswer'] ?? 'No Correct Answer',
          audioUrl: data['audioUrl'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<QuizQuestionData>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.textPrimary)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('video_unavailable'.tr, style: const TextStyle(color: AppColors.textPrimary)));
          } else {
            return QuizLogicWidget(questions: snapshot.data!.take(10).toList());
          }
        },
      ),
    );
  }
}

class QuizLogicWidget extends StatefulWidget {
  final List<QuizQuestionData> questions;
  const QuizLogicWidget({super.key, required this.questions});

  @override
  State<QuizLogicWidget> createState() => _QuizLogicWidgetState();
}

class _QuizLogicWidgetState extends State<QuizLogicWidget> {
  int _currentIndex = 0;
  String? _selectedOption;
  int _score = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playPauseAudio(String url) async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(UrlSource(url));
      setState(() => _isPlaying = true);
    }
  }

  void _onOptionSelected(String option) {
    if (_selectedOption != null) return;
    setState(() => _selectedOption = option);
    if (option == widget.questions[_currentIndex].correctAnswer) {
      _score++;
    }
  }

  void _nextQuestion() {
    if (_selectedOption == null) return;
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _isPlaying = false;
        _audioPlayer.stop();
      });
    } else {
      _showFinalScore();
    }
  }

  void _showFinalScore() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final historyEntry = {
      'chapter': 'Part I: Union and its Territory',
      'score': _score,
      'total': widget.questions.length,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(userId).update({
      'easyQuizzesCompleted': FieldValue.increment(1),
      'totalQuizzesCompleted': FieldValue.increment(1),
      'quizHistory': FieldValue.arrayUnion([historyEntry]),
      if (_score / widget.questions.length >= 0.7)
        'achievements': FieldValue.arrayUnion([{
          'id': 'part1_master',
          'title': 'Part I Master',
          'emoji': '🗺️',
          'date': DateTime.now().toIso8601String(),
        }]),
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("level_cleared".tr, style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'PlusJakartaSans')),
              const SizedBox(height: 12),
              Text("score_text".trParams({'score': _score.toString(), 'total': widget.questions.length.toString()}) + "\n" + "earned_xp".tr, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontFamily: 'Inter')),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomepageScreen()), (route) => false);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: Text("finish_lesson".tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemedQuizScreen(
      title: 'daily_quiz'.tr,
      questions: widget.questions,
      currentIndex: _currentIndex,
      selectedOption: _selectedOption,
      accentColor: AppColors.success,
      backgroundColor: AppColors.successBg,
      isPlaying: _isPlaying,
      onOptionSelected: _onOptionSelected,
      onNext: _nextQuestion,
      onPrevious: () {
        if (_currentIndex > 0) {
          setState(() {
            _currentIndex--;
            _selectedOption = null;
            _audioPlayer.stop();
            _isPlaying = false;
          });
        }
      },
      onPlayAudio: () => _playPauseAudio(widget.questions[_currentIndex].audioUrl ?? ''),
    );
  }
}

