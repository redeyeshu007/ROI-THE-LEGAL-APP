import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_signup/theme/app_colors.dart';
import 'package:login_signup/widgets/quiz_template.dart';
import 'package:login_signup/screens/homepage_screen.dart';

class AIDailyQuizScreen extends StatefulWidget {
  const AIDailyQuizScreen({super.key});

  @override
  State<AIDailyQuizScreen> createState() => _AIDailyQuizScreenState();
}

class _AIDailyQuizScreenState extends State<AIDailyQuizScreen> {
  static const _kGroqKey = 'REPLACE_WITH_YOUR_GROQ_API_KEY';
  static const _kGroqUrl = 'https://api.groq.com/openai/v1/chat/completions';

  List<QuizQuestionData> _questions = [];
  bool _loading = true;
  int _currentIndex = 0;
  String? _selectedOption;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  Future<void> _generateQuiz() async {
    setState(() => _loading = true);
    
    final prompt = """
Generate 5 unique multiple-choice questions about the Indian Constitution and Law. 
Each question must be challenging and educational.
Format the output as a JSON array of objects.
Each object must have: 
"article": (the specific Article or Section name, e.g. "Article 21: Right to Life"),
"question": (the question text),
"options": (an array of exactly 4 strings),
"correctAnswer": (one of the strings from the options array).

STRICTLY RETURN ONLY THE JSON ARRAY. NO MARKDOWN, NO EXPLANATIONS.
""";

    try {
      final response = await http.post(
        Uri.parse(_kGroqUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_kGroqKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['choices'][0]['message']['content'];
        
        // Basic cleaning in case AI includes md blocks
        content = content.replaceAll('```json', '').replaceAll('```', '').trim();
        
        final List<dynamic> jsonList = jsonDecode(content);
        _questions = jsonList.map((q) => QuizQuestionData(
          article: q['article'],
          question: q['question'],
          options: List<String>.from(q['options']),
          correctAnswer: q['correctAnswer'],
        )).toList();
      }
    } catch (e) {
      debugPrint("Quiz Generation Error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onOptionSelected(String option) {
    if (_selectedOption != null) return;
    setState(() => _selectedOption = option);
    if (option == _questions[_currentIndex].correctAnswer) {
      _score++;
    }
  }

  void _nextQuestion() {
    if (_selectedOption == null) return;
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
      });
    } else {
      _showFinalScore();
    }
  }

  void _showFinalScore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'dailyQuizzesCompleted': FieldValue.increment(1),
        'totalQuizzesCompleted': FieldValue.increment(1),
        'xp': FieldValue.increment(_score * 5),
        'quizHistory': FieldValue.arrayUnion([{
          'chapter': 'AI Daily Quiz',
          'score': _score,
          'total': _questions.length,
          'date': DateTime.now().toIso8601String()
        }]),
      });
    }

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
              const Text("🏁 Daily Quiz Done!", style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'PlusJakartaSans')),
              const SizedBox(height: 12),
              Text("Score: $_score / ${_questions.length}\nYou've earned +${_score * 5} XP! 🏆", textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontFamily: 'Inter')),
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
                  child: const Text("Awesome!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                "AI is generating your questions...",
                style: TextStyle(color: AppColors.primary, fontFamily: 'Inter', fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Couldn't generate quiz. Try again?"),
              ElevatedButton(onPressed: _generateQuiz, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    return ThemedQuizScreen(
      title: 'AI Daily Legal Challenge',
      questions: _questions,
      currentIndex: _currentIndex,
      selectedOption: _selectedOption,
      onOptionSelected: _onOptionSelected,
      onNext: _nextQuestion,
      onPrevious: () {},
      onPlayAudio: () {},
      accentColor: const Color(0xFF6366F1),
      backgroundColor: const Color(0xFFEEF2FF),
    );
  }
}
