import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'question_page.dart';
import 'strapi_service.dart';

class CasePromptPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final dynamic rawPrompt = selectedCase['prompt'];
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Case Title
            Text(
              "Case: ${selectedCase['title'] ?? 'Untitled'}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Prompt text
            Text(
              "Case prompt: $promptText",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            // Chat bubble + Cheerleader icon
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 70),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "Yet to be updated",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.black26),
                    ),
                    child:
                        selectedCheerleaderImage.endsWith('.svg')
                            ? Padding(
                              padding: const EdgeInsets.all(8),
                              child: SvgPicture.network(
                                selectedCheerleaderImage,
                                fit: BoxFit.contain,
                                placeholderBuilder:
                                    (_) => const CircularProgressIndicator(),
                              ),
                            )
                            : ClipOval(
                              child: Image.network(
                                selectedCheerleaderImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () async {
                try {
                  await StrapiService().createPlaySession(
                    cheerleader: selectedCheerleader,
                    caseTitle: selectedCase['title'] ?? 'Untitled',
                    startedAt: DateTime.now(),
                  );

                  if (!context.mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => QuestionsPage(
                            selectedCase: selectedCase,
                            selectedCheerleader: selectedCheerleader,
                            selectedCheerleaderImage: selectedCheerleaderImage,
                          ),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("❌ Failed to save session: $e")),
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
              child: const Text("Proceed", style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 20),

            // Timer UI
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "00",
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
            ),
          ],
        ),
      ),
    );
  }
}
