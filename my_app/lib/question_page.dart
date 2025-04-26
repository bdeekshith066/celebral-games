import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'case_results_page.dart';
import 'strapi_service.dart';

class QuestionsPage extends StatefulWidget {
  final Map<String, dynamic> selectedCase;
  final String selectedCheerleader;
  final String selectedCheerleaderImage;

  const QuestionsPage({
    super.key,
    required this.selectedCase,
    required this.selectedCheerleader,
    required this.selectedCheerleaderImage,
  });

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  List<dynamic> questions = [];
  int currentQuestionIndex = 0;
  int? selectedAnswerIndex;
  bool showHintBox = false;
  bool showFullHint = false;
  bool isLoading = true;
  int correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final caseId = widget.selectedCase['id'];
    try {
      final data = await StrapiService().fetchQuestionsByCaseId(caseId);
      if (!mounted) return;
      setState(() {
        questions = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error loading questions: $e')));
    }
  }

  void nextOrSubmit() {
    final currentQuestion = questions[currentQuestionIndex];
    final isCorrect = selectedAnswerIndex == currentQuestion['correct_option'];

    if (isCorrect) {
      correctAnswers++;
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = null;
        showHintBox = false;
        showFullHint = false;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => CaseResultsPage(
                selectedCase: widget.selectedCase,
                selectedCheerleader: widget.selectedCheerleader,
                selectedCheerleaderImage: widget.selectedCheerleaderImage,
                scoreTotal: correctAnswers,
                scoreOutOf: questions.length,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: Text("No questions found.")));
    }

    final current = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedCase['title'] ?? 'Case'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hint first
                if (showFullHint)
                  _expandedHint(current['hint'])
                else if (showHintBox)
                  Align(
                    alignment: Alignment.centerRight,
                    child: _collapsedHint(),
                  )
                else
                  Align(alignment: Alignment.centerRight, child: _hintButton()),

                const SizedBox(height: 20),

                Text(
                  current['text'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                ...List.generate(current['options'].length, (index) {
                  final option = current['options'][index];
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedAnswerIndex = index);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color:
                            selectedAnswerIndex == index
                                ? Colors.yellow[300]
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(option, style: const TextStyle(fontSize: 16)),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Cheerleader below options
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.selectedCheerleader,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (widget.selectedCheerleaderImage.endsWith(".svg"))
                      SvgPicture.network(
                        widget.selectedCheerleaderImage,
                        width: 50,
                        height: 50,
                        placeholderBuilder:
                            (_) => const CircularProgressIndicator(),
                      )
                    else
                      Image.network(
                        widget.selectedCheerleaderImage,
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                  ],
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: selectedAnswerIndex != null ? nextOrSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    currentQuestionIndex == questions.length - 1
                        ? "Submit"
                        : "Next",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hintButton() {
    return GestureDetector(
      onTap: () => setState(() => showHintBox = true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text("Hint", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _collapsedHint() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => showHintBox = false),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6),
              ),
            ),
            child: const Icon(Icons.close, color: Colors.redAccent, size: 18),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => showFullHint = true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: const Text(
              "Click again to view hint",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _expandedHint(String? hintText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Hint",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap:
                    () => setState(() {
                      showFullHint = false;
                      showHintBox = false;
                    }),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hintText ?? "No hint available.",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
