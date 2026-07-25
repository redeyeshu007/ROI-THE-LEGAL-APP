import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_signup/screens/hindi/quizeasyhindi/contentsquizehindi.dart';

class QuizScreen3hindi extends StatefulWidget {
  const QuizScreen3hindi({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen3hindi> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<QuizQuestion>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _fetchQuestions();
  }

  Future<List<QuizQuestion>> _fetchQuestions() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('pt_3ehindi').get();
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return QuizQuestion(
          article: data['article'] as String? ?? 'लेख उपलब्ध नहीं है',
          question: data['question'] as String? ?? 'कोई प्रश्न उपलब्ध नहीं है',
          option: List<String>.from(data['option'] ?? []),
          correctAnswer:
              data['correctAnswer'] as String? ?? 'कोई सही उत्तर नहीं है',
          audioUrl: data['audioUrl'] as String? ?? '', // Fetch audio URL
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
        title: const Text('क्विज़'),
        backgroundColor: const Color.fromARGB(255, 171, 128, 245),
      ),
      body: FutureBuilder<List<QuizQuestion>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('त्रुटि: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('कोई प्रश्न उपलब्ध नहीं है।'));
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _playPauseAudio(String url) async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        _isPlaying = true;
      });
    }
  }

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
                    isCorrect ? 'सही उत्तर!' : 'गलत उत्तर!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isCorrect
                        ? 'शाबाश! यह सही उत्तर है।'
                        : 'अरे नहीं! सही उत्तर है ${widget.questions[_currentIndex].correctAnswer}.',
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
                        _isPlaying =
                            false; // Reset play state for next question
                        _audioPlayer
                            .stop(); // Stop audio when moving to next question
                      });
                    },
                    child: const Text('अगला'),
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
        _isPlaying = false;
        _audioPlayer.stop();
      });
    }
  }

  void _showFinalScore() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    const int easyQuizzesIncrement = 1;
    const int totalQuizzesIncrement = 1;

    final DocumentReference userDocRef =
        _firestore.collection('users').doc(userId);

    await userDocRef.update({
      'easyQuizzesCompleted': FieldValue.increment(easyQuizzesIncrement),
      'totalQuizzesCompleted': FieldValue.increment(totalQuizzesIncrement),
    });

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
                  'क्विज़ समाप्त!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'आपका स्कोर: $_score/${widget.questions.length}',
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
                      _isPlaying = false; // Reset play state for restarting
                      _audioPlayer.stop(); // Stop audio when restarting quiz
                    });
                  },
                  child: const Text('क्विज़ पुनः प्रारंभ करें'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const Contents1hindi(),
                      ),
                    );
                  },
                  child: const Text('बाहर निकलें'),
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
          'क्विज़ समाप्त!',
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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question.article,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      '             ऑडियो  : ',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    color: Colors.deepPurple,
                    onPressed: () => _playPauseAudio(question.audioUrl),
                  ),
                ],
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
                                  onTap: () {
                                    setState(() {
                                      _selectedOption = option;
                                    });
                                  },
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _previousQuestion,
                        child: const Text('पिछला'),
                      ),
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        child: const Text('अगला'),
                      ),
                    ],
                  ),
                ],
              ),
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
  final String audioUrl;

  QuizQuestion({
    required this.article,
    required this.question,
    required this.option,
    required this.correctAnswer,
    required this.audioUrl,
  });
}
