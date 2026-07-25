import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:login_signup/quizeasy/contentsquize.dart';

class QuizScreen4A extends StatefulWidget {
  const QuizScreen4A({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen4A> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<QuizQuestion>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _fetchQuestions();
  }

  Future<List<QuizQuestion>> _fetchQuestions() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('pt_4a').get();
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return QuizQuestion(
          article: data['article'] as String? ?? 'No Article Provided',
          question: data['question'] as String? ?? 'No Question Provided',
          option: List<String>.from(data['option'] ?? []),
          correctAnswer:
              data['correctAnswer'] as String? ?? 'No Correct Answer',
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
      appBar: AppBar(
        title: const Text('Quiz'),
        backgroundColor: const Color.fromARGB(255, 171, 128, 245),
      ),
      body: FutureBuilder<List<QuizQuestion>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No questions available.'));
          } else {
            return QuizWidget(questions: snapshot.data!.take(10).toList());
          }
        },
      ),
    );
  }
}

class QuizWidget extends StatefulWidget {
  final List<QuizQuestion> questions;

  const QuizWidget({super.key, required this.questions});

  @override
  _QuizWidgetState createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  int _currentIndex = 0;
  String? _selectedOption;
  int _score = 0;

  void _nextQuestion() {
    if (_selectedOption == null) return;

    bool isCorrect =
        _selectedOption == widget.questions[_currentIndex].correctAnswer;
    if (isCorrect) {
      _score++;
    }

    if (_currentIndex < widget.questions.length - 1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isCorrect ? 'Correct!' : 'Wrong!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isCorrect
                        ? 'Good job! That\'s the right answer.'
                        : 'Oops! The correct answer is ${widget.questions[_currentIndex].correctAnswer}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _currentIndex++;
                        _selectedOption = null;
                      });
                    },
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      _showFinalScore();
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _selectedOption = null;
      });
    }
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Quiz Over!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Your Score: $_score/${widget.questions.length}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _currentIndex = 0;
                      _score = 0;
                      _selectedOption = null;
                    });
                  },
                  child: const Text('Restart Quiz'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const Contents1(),
                      ),
                    ); // Navigate to Content1 screen
                  },
                  child: const Text('Exit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.questions.length) {
      return const Center(
        child: Text(
          'Quiz Over!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      );
    }

    final question = widget.questions[_currentIndex];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple[100],
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                question.article,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: question.option
                        .map((option) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _selectedOption == option
                                        ? Colors.deepPurple
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(option),
                                  leading: Radio<String>(
                                    value: option,
                                    groupValue: _selectedOption,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedOption = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentIndex > 0)
                  ElevatedButton(
                    onPressed: _previousQuestion,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 172, 136, 234),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Previous'),
                  ),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 172, 136, 234),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuizQuestion {
  final String article;
  final String question;
  final List<String> option;
  final String correctAnswer;

  QuizQuestion({
    required this.article,
    required this.question,
    required this.option,
    required this.correctAnswer,
  });
}
