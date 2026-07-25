import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_signup/quizeasy/contentsquize.dart';
import 'package:login_signup/theme/app_colors.dart';
import 'package:login_signup/widgets/quiz_template.dart';
import 'package:login_signup/screens/homepage_screen.dart';


class QuizScreen7 extends StatefulWidget {
  const QuizScreen7({super.key});

  @override
  State<QuizScreen7> createState() => _QuizScreen7State();
}

class _QuizScreen7State extends State<QuizScreen7> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<QuizQuestionData>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _fetchQuestions();
  }

  Future<List<QuizQuestionData>> _fetchQuestions() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('pt_7e').get();
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

  void _onOptionSelected(String option) {
    if (_selectedOption != null) return; // Already answered
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
      });
    } else {
      _showFinalScore();
    }
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("🏁 Quiz Cleared!", style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'PlusJakartaSans')),
              const SizedBox(height: 12),
              Text("Score: $_score / ${widget.questions.length}\nYou've earned +10 XP! 🏆", textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontFamily: 'Inter')),
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
                  child: const Text("Finish", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      title: 'Part VII: The States Quiz',
      questions: widget.questions,
      currentIndex: _currentIndex,
      selectedOption: _selectedOption,
      accentColor: AppColors.success,
      backgroundColor: AppColors.successBg,
      onOptionSelected: _onOptionSelected,
      onNext: _nextQuestion,
      onPrevious: () { if (_currentIndex > 0) setState(() { _currentIndex--; _selectedOption = null; }); },
      onPlayAudio: () {},
    );
  }
}

