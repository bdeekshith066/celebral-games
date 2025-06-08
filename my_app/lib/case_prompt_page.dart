import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'question_page.dart';
import 'strapi_service.dart';

class CasePromptPage extends StatefulWidget {
  final Map<String, dynamic> selectedCase;
  final String selectedCheerleader;
  final String selectedCheerleaderImage;

  const CasePromptPage({
    super.key,
    required this.selectedCase,
    required this.selectedCheerleader,
    required this.selectedCheerleaderImage,
  });

  @override
  State<CasePromptPage> createState() => _CasePromptPageState();
}

class _CasePromptPageState extends State<CasePromptPage> {
  String? promptImageUrl;
  bool isLoadingImage = true;

  @override
  void initState() {
    super.initState();
    loadPromptImage();
  }

  Future<void> loadPromptImage() async {
    final url = await StrapiService().fetchPromptImageUrl();
    if (!mounted) return;
    setState(() {
      promptImageUrl = url;
      isLoadingImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dynamic rawPrompt = widget.selectedCase['prompt'];
    String promptText = 'No prompt available.';
    if (rawPrompt is List && rawPrompt.isNotEmpty) {
      promptText = rawPrompt[0]['children'][0]['text'] ?? promptText;
    } else if (rawPrompt is String) {
      promptText = rawPrompt;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Case Prompt"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Case: ${widget.selectedCase['title'] ?? 'Untitled'}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Case Prompt Image (dynamic)
                  if (isLoadingImage)
                    const Center(child: CircularProgressIndicator())
                  else if (promptImageUrl != null &&
                      promptImageUrl!.endsWith('.svg'))
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: SvgPicture.network(
                        promptImageUrl!,
                        fit: BoxFit.cover,
                        placeholderBuilder:
                            (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                      ),
                    )
                  else if (promptImageUrl != null)
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.network(
                        promptImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) =>
                                const Center(child: Icon(Icons.broken_image)),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  const SizedBox(height: 20),

                  Text(
                    "Case prompt: $promptText",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom fixed section
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                children: [
                  // Cheerleader avatar
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 25),
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.black26),
                      ),
                      child:
                          widget.selectedCheerleaderImage.endsWith('.svg')
                              ? Padding(
                                padding: const EdgeInsets.all(8),
                                child: SvgPicture.network(
                                  widget.selectedCheerleaderImage,
                                  fit: BoxFit.contain,
                                  placeholderBuilder:
                                      (_) => const CircularProgressIndicator(),
                                ),
                              )
                              : ClipOval(
                                child: Image.network(
                                  widget.selectedCheerleaderImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                    ),
                  ),

                  // Proceed button
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await StrapiService().createPlaySession(
                          cheerleader: widget.selectedCheerleader,
                          caseTitle: widget.selectedCase['title'] ?? 'Untitled',
                          startedAt: DateTime.now(),
                          userEmail: "bdeekshith6@gmail.com",
                        );

                        if (!context.mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => QuestionsPage(
                                  selectedCase: widget.selectedCase,
                                  selectedCheerleader:
                                      widget.selectedCheerleader,
                                  selectedCheerleaderImage:
                                      widget.selectedCheerleaderImage,
                                ),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("❌ Failed to save session: $e"),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Proceed",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Timer box
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[350],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "400",
                          style: TextStyle(
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
}
