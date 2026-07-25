import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_signup/quizeasy/contentsquize.dart';
import 'package:login_signup/theme/app_colors.dart';
import 'package:login_signup/widgets/quiz_template.dart';
import 'package:login_signup/widgets/gamified_quiz_dialogs.dart';
import 'package:login_signup/screens/homepage_screen.dart';


class QuizScreenS7h extends StatefulWidget {
  const QuizScreenS7h({super.key});

  @override
  State<QuizScreenS7h> createState() => _QuizScreenS7hState();
}

class _QuizScreenS7hState extends State<QuizScreenS7h> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<QuizQuestionData>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _fetchQuestions();
  }

  Future<List<QuizQuestionData>> _fetchQuestions() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('pt-2c').get();
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
      debugPrint('Error fetching questions: $e');
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
            return const Center(child: CircularProgressIndicator(color: AppColors.error));
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GamifiedQuizDialog(
        isCorrect: isCorrect,
        correctAnswer: widget.questions[_currentIndex].correctAnswer,
        accentColor: AppColors.error,
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
      'hardQuizzesCompleted': FieldValue.increment(1),
      'totalQuizzesCompleted': FieldValue.increment(1),
      'quizHistory': FieldValue.arrayUnion([{'chapter': 'Quiz', 'score': _score, 'date': DateTime.now().toIso8601String()}]),

    });

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuizCompletionDialog(
        score: _score,
        totalQuestions: widget.questions.length,
        accentColor: AppColors.error,
        onRestart: () {
          Navigator.pop(context);
          setState(() {
            _currentIndex = 0;
            _score = 0;
            _selectedOption = null;
          });
        },
        onExit: () {
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomepageScreen()), (route) => false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemedQuizScreen(
      title: 'Schedule VII - Hard Mode',
      questions: widget.questions,
      currentIndex: _currentIndex,
      selectedOption: _selectedOption,
      accentColor: AppColors.error,
      backgroundColor: AppColors.errorBg,
      onOptionSelected: (opt) => setState(() => _selectedOption = opt),
      onNext: _nextQuestion,
      onPrevious: () {
        if (_currentIndex > 0) {
          setState(() {
            _currentIndex--;
            _selectedOption = null;
          });
        }
      },
      onPlayAudio: () {},
    );
  }
}
