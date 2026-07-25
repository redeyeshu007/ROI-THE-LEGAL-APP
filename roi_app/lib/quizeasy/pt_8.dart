import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_signup/quizeasy/contentsquize.dart';
import 'package:login_signup/theme/app_colors.dart';
import 'package:login_signup/widgets/quiz_template.dart';
import 'package:login_signup/screens/homepage_screen.dart';


class QuizScreen8 extends StatefulWidget {
  const QuizScreen8({super.key});

  @override
  State<QuizScreen8> createState() => _QuizScreen8State();
}

class _QuizScreen8State extends State<QuizScreen8> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<QuizQuestionData>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _fetchQuestions();
  }

  Future<List<QuizQuestionData>> _fetchQuestions() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('pt_8e').get();
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return QuizQuestionData(
          article: data['article'] ?? 'No Article Provided',
          question: data['question'] ?? 'No Question Provided',
          options: List<String>.from(data['option'] ?? []),
          correctAnswer: data['correctAnswer'] ?? 'No Correct Answer',
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
            return const Center(child: Text('No questions available.', style: TextStyle(color: AppColors.textPrimary)));
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _nextQuestion() {
    if (_selectedOption == null) return;
    bool isCorrect = _selectedOption == widget.questions[_currentIndex].correctAnswer;
    if (isCorrect) _score++;
    _showFeedbackDialog(isCorrect);
  }

  void _showFeedbackDialog(bool isCorrect) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _gamifiedDialog(
        title: isCorrect ? "✅ Correct!" : "❌ Oops!",
        content: isCorrect ? "Superb! You're making real progress! 🚀" : "The correct answer is:\n${widget.questions[_currentIndex].correctAnswer}",
        color: isCorrect ? AppColors.success : AppColors.error,
        buttonText: _currentIndex < widget.questions.length - 1 ? "Next Question" : "See Final Score",
        onNext: () {
          Navigator.pop(context);
          if (_currentIndex < widget.questions.length - 1) {
            setState(() {
              _currentIndex++;
              _selectedOption = null;
            });
          } else {
            _showFinalScore();
          }
        },
      ),
    );
  }

  void _showFinalScore() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await _firestore.collection('users').doc(userId).update({
      'easyQuizzesCompleted': FieldValue.increment(1),
      'totalQuizzesCompleted': FieldValue.increment(1),
      'quizHistory': FieldValue.arrayUnion([{'chapter': 'Quiz', 'score': _score, 'date': DateTime.now().toIso8601String()}]),

    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _gamifiedDialog(
        title: "🏁 Lesson Complete!",
        content: "Score: $_score / ${widget.questions.length}\nYou've earned +10 XP! 🏆",
        color: AppColors.primary,
        buttonText: "Finish",
        onNext: () {
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomepageScreen()), (route) => false);
        },
      ),
    );
  }

  Widget _gamifiedDialog({required String title, required String content, required Color color, required String buttonText, required VoidCallback onNext}) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'PlusJakartaSans')),
            const SizedBox(height: 12),
            Text(content, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontFamily: 'Inter')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(onPressed: onNext, style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text(buttonText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemedQuizScreen(
      title: 'Part VIII: Union Territories Quiz',
      questions: widget.questions,
      currentIndex: _currentIndex,
      selectedOption: _selectedOption,
      accentColor: AppColors.success,
      backgroundColor: AppColors.successBg,
      onOptionSelected: (opt) => setState(() => _selectedOption = opt),
      onNext: _nextQuestion,
      onPrevious: () { if (_currentIndex > 0) setState(() { _currentIndex--; _selectedOption = null; }); },
      onPlayAudio: () {},
    );
  }
}
