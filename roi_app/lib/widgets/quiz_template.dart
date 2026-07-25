import 'package:flutter/material.dart';
import 'package:login_signup/theme/app_colors.dart';

class QuizQuestionData {
  final String article;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? audioUrl;

  QuizQuestionData({
    required this.article,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.audioUrl,
  });
}

class ThemedQuizScreen extends StatefulWidget {
  final String title;
  final List<QuizQuestionData> questions;
  final int currentIndex;
  final String? selectedOption;
  final Function(String) onOptionSelected;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onPlayAudio;
  final bool isPlaying;
  final Color accentColor;
  final Color backgroundColor;

  const ThemedQuizScreen({
    super.key,
    required this.title,
    required this.questions,
    required this.currentIndex,
    required this.selectedOption,
    required this.onOptionSelected,
    required this.onNext,
    required this.onPrevious,
    required this.onPlayAudio,
    this.isPlaying = false,
    this.accentColor = AppColors.primary,
    this.backgroundColor = AppColors.primaryBg,
  });

  @override
  State<ThemedQuizScreen> createState() => _ThemedQuizScreenState();
}

class _ThemedQuizScreenState extends State<ThemedQuizScreen>
    with SingleTickerProviderStateMixin {
  bool _showWrongFlash = false;
  bool _answered = false;
  String? _localSelected;
  late AnimationController _flashCtrl;

  @override
  void initState() {
    super.initState();
    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flashCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flashCtrl.reverse();
      }
      if (status == AnimationStatus.dismissed && _showWrongFlash) {
        setState(() => _showWrongFlash = false);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ThemedQuizScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset state when question changes
    if (oldWidget.currentIndex != widget.currentIndex) {
      _answered = false;
      _localSelected = null;
      _showWrongFlash = false;
    }
  }

  @override
  void dispose() {
    _flashCtrl.dispose();
    super.dispose();
  }

  void _handleOptionTap(String option) {
    if (_answered) return; // Lock after answering
    setState(() {
      _localSelected = option;
      _answered = true;
    });
    widget.onOptionSelected(option);

    final isCorrect = option == widget.questions[widget.currentIndex].correctAnswer;
    if (!isCorrect) {
      setState(() => _showWrongFlash = true);
      _flashCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = widget.questions[widget.currentIndex];
    final progress = (widget.currentIndex + 1) / widget.questions.length;
    final labels = ['A', 'B', 'C', 'D'];
    final correctAnswer = question.correctAnswer;

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.backgroundColor, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // ── App Bar (compact) ──
                  _buildAppBar(context),

                  // ── Progress Bar ──
                  _buildProgressBar(progress),

                  // ── Main Content (Scrollable & Spaced) ──
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Article + Question card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: widget.accentColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.accentColor.withOpacity(0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question.article,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  question.question,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'PlusJakartaSans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Options (Spaced out) ──
                          ...List.generate(
                            question.options.length,
                            (i) {
                              final option = question.options[i];
                              final label = i < labels.length ? labels[i] : '';
                              final isSelected = _localSelected == option;
                              final isCorrectOption = option == correctAnswer;
                              final showAsCorrect = _answered && isCorrectOption;
                              final showAsWrong = _answered && isSelected && !isCorrectOption;

                              Color bgColor = Colors.white;
                              Color borderColor = Colors.black12;
                              Color textColor = AppColors.textPrimary;
                              Color labelBg = const Color(0xFFF3F4F6);
                              Color labelColor = const Color(0xFF6B7280);

                              if (showAsCorrect) {
                                bgColor = const Color(0xFFECFDF5);
                                borderColor = const Color(0xFF059669);
                                textColor = const Color(0xFF059669);
                                labelBg = const Color(0xFF059669);
                                labelColor = Colors.white;
                              } else if (showAsWrong) {
                                bgColor = const Color(0xFFFEF2F2);
                                borderColor = const Color(0xFFDC2626);
                                textColor = const Color(0xFFDC2626);
                                labelBg = const Color(0xFFDC2626);
                                labelColor = Colors.white;
                              } else if (isSelected) {
                                bgColor = widget.accentColor.withOpacity(0.08);
                                borderColor = widget.accentColor;
                                textColor = widget.accentColor;
                                labelBg = widget.accentColor;
                                labelColor = Colors.white;
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: GestureDetector(
                                  onTap: () => _handleOptionTap(option),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: borderColor, width: showAsCorrect || showAsWrong ? 2.5 : 1.5),
                                      boxShadow: isSelected ? [
                                        BoxShadow(color: widget.accentColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                                      ] : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: labelBg,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(
                                              label,
                                              style: TextStyle(
                                                fontFamily: 'PlusJakartaSans',
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16,
                                                color: labelColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            option,
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: isSelected || showAsCorrect || showAsWrong
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              fontSize: 15,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                        if (showAsCorrect)
                                          const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 24),
                                        if (showAsWrong)
                                          const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 24),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 8),

                          // ── Wrong Answer Banner ──
                          if (_answered && _localSelected != correctAnswer)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFDC2626).withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded, color: Color(0xFFDC2626), size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Correct Answer: $correctAnswer',
                                      style: const TextStyle(
                                        color: Color(0xFFDC2626),
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // ── Navigation (part of scroll) ──
                          _buildNavigationButtons(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Red Flash Overlay ──
          if (_showWrongFlash)
            AnimatedBuilder(
              animation: _flashCtrl,
              builder: (_, __) => IgnorePointer(
                child: Container(
                  color: Colors.red.withOpacity(0.15 * _flashCtrl.value),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: widget.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Q ${widget.currentIndex + 1}/${widget.questions.length}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: widget.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      height: 6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: progress * constraints.maxWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [widget.accentColor, widget.accentColor.withOpacity(0.7)]),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (widget.currentIndex > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onPrevious,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: widget.accentColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Previous',
                style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold, color: widget.accentColor, fontSize: 13),
              ),
            ),
          ),
        if (widget.currentIndex > 0) const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _answered ? widget.onNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.accentColor,
              disabledBackgroundColor: widget.accentColor.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 3,
            ),
            child: Text(
              _answered ? 'Next →' : 'Select an Answer',
              style: const TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
