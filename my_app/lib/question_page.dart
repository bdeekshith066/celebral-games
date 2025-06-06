import 'dart:async';
import 'dart:math';

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
  int hintsViewed = 0;
  Stopwatch stopwatch = Stopwatch();
  Stopwatch questionStopwatch = Stopwatch();
  int remainingTime = 400;
  List<Map<String, dynamic>> selectedAnswers = [];
  bool viewOnlyMode = false;
  List<dynamic> savedSelectedAnswers = [];
  String cheerleaderMessage = "";
  Map<String, List<String>> cheerleaderTriggers = {};
  int correctStreak = 0;
  int incorrectStreak = 0;
  bool showMistakeNotification = false;
  late Timer countdownTimer;
  int lastQuestionElapsed = 0;
  String floatingNotification = "";
  bool showFloatingNotification = false;

  Map<String, int> categoryTotal = {
    "Framework": 0,
    "Calculations": 0,
    "Brainstorming": 0,
    "Others": 0,
  };

  Map<String, int> categoryCorrect = {
    "Framework": 0,
    "Calculations": 0,
    "Brainstorming": 0,
    "Others": 0,
  };

  Map<String, int> categoryIncorrect = {
    "Framework": 0,
    "Calculations": 0,
    "Brainstorming": 0,
    "Others": 0,
  };

  @override
  void initState() {
    super.initState();
    fetchQuestions();
    fetchBarnieTriggers(); // 👈 Add this
    stopwatch.start();
    questionStopwatch.start();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        remainingTime--;
        if (remainingTime <= 0) {
          timer.cancel();
          autoSubmitDueToTimeout();
        }
      });
    });
  }

  void showTemporaryNotification(String message) {
    setState(() {
      floatingNotification = message;
      showFloatingNotification = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => showFloatingNotification = false);
      }
    });
  }

  void autoSubmitDueToTimeout() {
    stopwatch.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => CaseResultsPage(
              selectedCase: widget.selectedCase,
              selectedCheerleader: widget.selectedCheerleader,
              selectedCheerleaderImage: widget.selectedCheerleaderImage,
              scoreTotal: 0,
              scoreOutOf: 400,
              categoryTotal: categoryTotal,
              categoryCorrect: categoryCorrect,
              categoryIncorrect: categoryIncorrect,
            ),
      ),
    );
  }

  void showCheerleaderMessage(String trigger) {
    final messages = cheerleaderTriggers[trigger];
    if (messages != null && messages.isNotEmpty) {
      setState(() {
        cheerleaderMessage = messages[Random().nextInt(messages.length)];
      });
    } else {
      setState(() {
        cheerleaderMessage = "";
      });
    }
  }

  void showTemporaryNotificationFromTrigger(String trigger) {
    final messages = cheerleaderTriggers[trigger];
    if (messages != null && messages.isNotEmpty) {
      final message = messages[Random().nextInt(messages.length)];
      setState(() {
        floatingNotification = message;
        showFloatingNotification = true;
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            floatingNotification = "";
            showFloatingNotification = false;
          });
        }
      });
    }
  }

  Future<void> fetchBarnieTriggers() async {
    try {
      final response = await StrapiService().fetchCheerleaderByName(
        "Barnie Sunders",
      );
      final messages = response['personaMessages'] ?? [];

      Map<String, List<String>> triggers = {};
      for (var msg in messages) {
        final trigger = msg['trigger'];
        final text = msg['messages'];
        if (trigger != null && text != null) {
          triggers.putIfAbsent(trigger, () => []).add(text);
        }
      }

      if (mounted) {
        setState(() {
          cheerleaderTriggers = triggers;
          showCheerleaderMessage("start"); // Show welcome message if exists
        });
      }
    } catch (e) {
      print("Error loading Barnie messages: $e");
    }
  }

  Future<void> nextOrSubmit() async {
    final currentQuestion = questions[currentQuestionIndex];
    final isCorrect = selectedAnswerIndex == currentQuestion['correct_option'];

    // Analyze time taken to answer the question
    int timeTaken = questionStopwatch.elapsed.inSeconds;
    questionStopwatch.reset();
    questionStopwatch.start();

    // Trigger floating notification

    if (timeTaken >= 20) {
      showTemporaryNotificationFromTrigger("slow_answer");
    } else if (timeTaken <= 5) {
      showTemporaryNotificationFromTrigger("fast_answer");
    }

    if (isCorrect) {
      correctStreak++;
      incorrectStreak = 0;
      if (correctStreak == 3) {
        showTemporaryNotificationFromTrigger("three_correct");
        correctStreak = 0;
      }
    } else {
      incorrectStreak++;
      correctStreak = 0;
      if (incorrectStreak == 3) {
        showTemporaryNotificationFromTrigger("third_incorrect_flow");
      }
    }

    // Score tracking per category
    final rawCategory =
        (currentQuestion['category'] ?? '').toString().toLowerCase().trim();
    final categoryKey = switch (rawCategory) {
      'framework' => 'Framework',
      'calculations' => 'Calculations',
      'brainstorming' => 'Brainstorming',
      _ => 'Others',
    };

    categoryTotal[categoryKey] = (categoryTotal[categoryKey] ?? 0) + 1;
    if (isCorrect) {
      categoryCorrect[categoryKey] = (categoryCorrect[categoryKey] ?? 0) + 1;
    } else {
      categoryIncorrect[categoryKey] =
          (categoryIncorrect[categoryKey] ?? 0) + 1;
    }

    // Save selected answer
    selectedAnswers.add({
      'question': currentQuestion['text'],
      'selected': selectedAnswerIndex,
      'correct': currentQuestion['correct_option'],
    });

    // Go to next question or submit
    if (currentQuestionIndex < questions.length - 2) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = null;
        showHintBox = false;
        showFullHint = false;
      });
    } else {
      stopwatch.stop();
      int totalTimeUsed = stopwatch.elapsed.inSeconds;
      int finalScore = 400 - totalTimeUsed - (5 * hintsViewed);

      await StrapiService().createPlaySession(
        cheerleader: widget.selectedCheerleader,
        caseTitle: widget.selectedCase['title'],
        startedAt: DateTime.now(),
        userEmail: "bdeekshith6@gmail.com",
        score: finalScore,
        completed: true,
        selectedAnswers: selectedAnswers,
      );

      await StrapiService().saveCaseProgress(
        caseTitle: widget.selectedCase['title'],
        userEmail: "bdeekshith6@gmail.com",
        score: finalScore,
        status: "Completed",
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => CaseResultsPage(
                selectedCase: widget.selectedCase,
                selectedCheerleader: widget.selectedCheerleader,
                selectedCheerleaderImage: widget.selectedCheerleaderImage,
                scoreTotal: finalScore,
                scoreOutOf: 400,
                categoryTotal: categoryTotal,
                categoryCorrect: categoryCorrect,
                categoryIncorrect: categoryIncorrect,
              ),
        ),
      );
    }
  }

  Future<void> fetchQuestions() async {
    final caseId = widget.selectedCase['id'];
    try {
      final data = await StrapiService().fetchQuestionsByCaseId(caseId);
      final session = await StrapiService().fetchPlaySession(
        caseTitle: widget.selectedCase['title'],
        userEmail: "bdeekshith6@gmail.com",
      );

      bool alreadyCompleted = session?['completed'] == true;

      if (!mounted) return;

      setState(() {
        questions = data;
        isLoading = false;
        viewOnlyMode = alreadyCompleted;
        savedSelectedAnswers = session?['selected_answer'] ?? [];
      });

      if (alreadyCompleted) {
        stopwatch.stop();
        countdownTimer.cancel();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error loading questions: $e')));
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showFullHint)
                    _expandedHint(current['hint'])
                  else if (showHintBox)
                    Align(
                      alignment: Alignment.centerRight,
                      child: _collapsedHint(),
                    )
                  else
                    Align(
                      alignment: Alignment.centerRight,
                      child: _hintButton(),
                    ),

                  const SizedBox(height: 15),

                  Text(
                    current['text'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

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
                        child: Text(
                          option,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(
                    height: 5,
                  ), // Adds space so content doesn't get hidden under fixed footer
                ],
              ),
            ),
          ),
          // 🔽 Fixed Notification Section
          Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  showFloatingNotification
                      ? Container(
                        key: ValueKey(floatingNotification),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          floatingNotification,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ),

          // 🔽 Fixed Cheerleader Section
          Container(
            width: double.infinity,
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 💬 Cheerleader Message Box
                Expanded(
                  child:
                      cheerleaderMessage.isNotEmpty
                          ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "💬 $cheerleaderMessage",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          )
                          : const SizedBox.shrink(),
                ),

                const SizedBox(width: 10),

                // 🎓 Cheerleader Name
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.selectedCheerleader,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 🖼 Cheerleader Image (SVG or PNG)
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child:
                      widget.selectedCheerleaderImage.endsWith(".svg")
                          ? SvgPicture.network(
                            widget.selectedCheerleaderImage,
                            width: 50,
                            height: 50,
                            placeholderBuilder:
                                (_) => const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                          )
                          : Image.network(
                            widget.selectedCheerleaderImage,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                ),
              ],
            ),
          ),

          // Fixed bottom: Button and timer
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed:
                        selectedAnswerIndex != null ? nextOrSubmit : null,
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
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "$remainingTime",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Seconds",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hintButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          showHintBox = true;
          hintsViewed++;
        });
      },
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
