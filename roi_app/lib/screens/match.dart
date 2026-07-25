import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_signup/theme/app_colors.dart';
import 'package:login_signup/screens/dashpage.dart';
import 'package:get/get.dart';

class MatchGameScreen extends StatefulWidget {
  const MatchGameScreen({super.key});

  @override
  _MatchGameScreenState createState() => _MatchGameScreenState();
}

class _MatchGameScreenState extends State<MatchGameScreen> {
  List<String> laws = [];
  Map<String, String> descriptions = {};
  Map<String, String?> matched = {};
  Map<String, bool> isCorrect = {};
  List<String> availableLaws = [];
  bool showResult = false;
  DocumentSnapshot? currentMatchDocument;
  int currentMatchIndex = 0;
  List<DocumentSnapshot>? matchDocuments;

  @override
  void initState() {
    super.initState();
    fetchMatchData();
  }

  Future<void> fetchMatchData() async {
    try {
      String collectionName = 'matchData';
      final langCode = Get.locale?.languageCode;
      if (langCode == 'hi') collectionName = 'matchDataHindi';
      if (langCode == 'ta') collectionName = 'matchDataTamil';

      final snapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .orderBy(FieldPath.documentId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        matchDocuments = snapshot.docs;
        currentMatchDocument = matchDocuments![currentMatchIndex];
        setDataFromDocument(currentMatchDocument!);
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  void setDataFromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    laws = List<String>.from(data['laws']);
    descriptions = Map<String, String>.from(data['descriptions']);
    matched = {for (var law in laws) law: null};
    isCorrect = {for (var law in laws) law: false};
    availableLaws = List.from(laws);
    setState(() {});
  }

  void checkAnswers() {
    for (var law in laws) {
      isCorrect[law] = matched[law] == law;
    }
    setState(() => showResult = true);
  }

  void showCorrectAnswersDialog() {
    final incorrectAnswers = laws.where((law) => !isCorrect[law]!).toList();
    final correctAnswers = laws
        .where((law) => isCorrect[law]!)
        .map((law) => '$law: ${descriptions[law]}')
        .join('\n');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('results'.tr,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontFamily: 'PlusJakartaSans')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                const SizedBox(width: 6),
                Text('correct_answers_label'.tr, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontFamily: 'Inter')),
              ]),
              const SizedBox(height: 6),
              Text(correctAnswers.isEmpty ? 'none_text'.tr : correctAnswers,
                  style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter', fontSize: 13)),
              const SizedBox(height: 16),
              Row(children: [
                const Icon(Icons.cancel_rounded, color: AppColors.error, size: 16),
                const SizedBox(width: 6),
                Text('incorrect_answers_label'.tr, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error, fontFamily: 'Inter')),
              ]),
              const SizedBox(height: 6),
              Text(incorrectAnswers.isEmpty ? 'no_incorrect_ans'.tr : incorrectAnswers.join('\n'),
                  style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter', fontSize: 13)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () { Navigator.pop(context); nextMatch(); },
            child: Text('next_match_btn'.tr),
          ),
        ],
      ),
    );
  }

  void nextMatch() {
    if (matchDocuments == null) return;
    setState(() {
      matched = {for (var law in laws) law: null};
      isCorrect = {for (var law in laws) law: false};
      showResult = false;
    });

    if (currentMatchIndex < matchDocuments!.length - 1) {
      currentMatchIndex++;
      currentMatchDocument = matchDocuments![currentMatchIndex];
      setDataFromDocument(currentMatchDocument!);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('game_complete_title'.tr,
              style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold)),
          content: Text("completed_all_matches".tr,
              style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter')),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Dashpage()));
              },
              child: Text('return_to_dashboard'.tr),
            ),
          ],
        ),
      );
    }
  }

  void previousMatch() {
    if (matchDocuments == null || currentMatchIndex == 0) return;
    setState(() {
      currentMatchIndex--;
      currentMatchDocument = matchDocuments![currentMatchIndex];
      setDataFromDocument(currentMatchDocument!);
    });
  }

  @override
  Widget build(BuildContext context) {
    const kBg1 = Color(0xFFE0F2FE); // light sky
    const kBg2 = Color(0xFFF0F9FF);
    const kPrimary = Color(0xFF0284C7); // Sky Blue
    const kPrimary2 = Color(0xFF0EA5E9);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kBg1, kBg2, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            // ── Premium App Bar
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
              child: Row(children: [
                IconButton(
                  icon: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: kPrimary),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (b) => const LinearGradient(colors: [kPrimary, kPrimary2]).createShader(b),
                  child: Text('match_game_title'.tr, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w900, fontSize: 20)),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '${currentMatchIndex + 1} / ${matchDocuments?.length ?? 1}',
                    style: const TextStyle(color: kPrimary, fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ),
              ]),
            ),

            if (laws.isEmpty)
              const Expanded(child: Center(child: CircularProgressIndicator(color: kPrimary)))
            else ...[
              // ── Instruction Area
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kPrimary.withOpacity(0.1)),
                ),
                child: Row(children: [
                   const Text('💡', style: TextStyle(fontSize: 18)),
                   const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'match_instruction'.tr,
                        style: TextStyle(color: kPrimary.withOpacity(0.8), fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                ]),
              ),

              // ── Match List
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: descriptions.keys.length,
                  itemBuilder: (context, index) {
                    String law = descriptions.keys.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                          border: Border.all(color: kPrimary.withOpacity(0.08)),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(children: [
                          Expanded(
                            child: Text(
                              descriptions[law]!,
                              style: const TextStyle(color: Color(0xFF334155), fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w600, height: 1.4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          DragTarget<String>(
                            builder: (context, candidateData, _) {
                              final highlight = candidateData.isNotEmpty;
                              Color bgColor = Colors.white;
                              Color borderColor = kPrimary.withOpacity(0.15);
                              
                              if (showResult) {
                                final correct = isCorrect[law] == true;
                                bgColor = correct ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);
                                borderColor = correct ? const Color(0xFF10B981) : const Color(0xFFEF4444);
                              } else if (highlight) {
                                bgColor = kPrimary.withOpacity(0.05);
                                borderColor = kPrimary;
                              }

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 120, height: 50,
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor, width: (highlight || showResult) ? 2 : 1),
                                ),
                                child: Center(
                                    child: Text(
                                      matched[law] ?? 'drop_here'.tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: matched[law] != null ? const Color(0xFF0F172A) : Colors.black26,
                                        fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                ),
                              );
                            },
                            onAcceptWithDetails: (DragTargetDetails<String> details) {
                              setState(() {
                                matched[law] = details.data;
                                availableLaws.remove(details.data);
                              });
                            },
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ]),
        ),
      ),
      // ── Fixed Bottom Panel for Draggables & Controls
      bottomSheet: laws.isEmpty ? null : Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5))],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Draggable Area
          if (availableLaws.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Wrap(
                spacing: 10, runSpacing: 10,
                children: availableLaws.map((law) => Draggable<String>(
                  data: law,
                  feedback: Material(color: Colors.transparent, child: _DraggableCard(law: law, isDragging: true)),
                  childWhenDragging: Opacity(opacity: 0.3, child: _DraggableCard(law: law)),
                  child: _DraggableCard(law: law),
                )).toList(),
              ),
            ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(children: [
              IconButton(
                onPressed: previousMatch,
                icon: const Icon(Icons.arrow_back_rounded, color: kPrimary),
                style: IconButton.styleFrom(backgroundColor: kPrimary.withValues(alpha: 0.1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: showResult ? showCorrectAnswersDialog : checkAnswers,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [kPrimary, kPrimary2]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: kPrimary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Center(
                      child: Text(
                        showResult ? 'see_results_btn'.tr : 'check_answers_btn'.tr,
                        style: const TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: nextMatch,
                icon: const Icon(Icons.arrow_forward_rounded, color: kPrimary),
                style: IconButton.styleFrom(backgroundColor: kPrimary.withValues(alpha: 0.1)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _DraggableCard extends StatelessWidget {
  final String law;
  final bool isDragging;
  const _DraggableCard({required this.law, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: isDragging
            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Text(
        law,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
