import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'feedback_page.dart';

class CaseResultsPage extends StatelessWidget {
  final Map<String, dynamic> selectedCase;
  final String selectedCheerleader;
  final int scoreTotal;
  final int scoreOutOf;
  final String selectedCheerleaderImage;

  const CaseResultsPage({
    super.key,
    required this.selectedCase,
    required this.selectedCheerleader,
    required this.scoreTotal,
    required this.scoreOutOf,
    required this.selectedCheerleaderImage,
  });

  @override
  Widget build(BuildContext context) {
    double barWidth = MediaQuery.of(context).size.width - 40;
    double scoreRatio = scoreTotal / scoreOutOf;
    double arrowPosition = barWidth * scoreRatio;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Case Results"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🎉 Great job! Here's your result:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Score Summary Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Case: ${selectedCase['title']}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Cheerleader: $selectedCheerleader",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Your score: $scoreTotal / $scoreOutOf",
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Score Indicator Bar
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 20,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.red, Colors.yellow, Colors.green],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Positioned(
                  left: arrowPosition.clamp(0, barWidth - 20),
                  top: -24,
                  child: const Icon(
                    Icons.arrow_drop_down,
                    size: 36,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Low", style: TextStyle(fontWeight: FontWeight.w500)),
                Text("High", style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),

            const SizedBox(height: 50),

            // Cheerleader avatar and name
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      selectedCheerleader,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  selectedCheerleaderImage.endsWith('.svg')
                      ? SvgPicture.network(
                        selectedCheerleaderImage,
                        width: 55,
                        height: 55,
                      )
                      : ClipOval(
                        child: Image.network(
                          selectedCheerleaderImage,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                        ),
                      ),
                ],
              ),
            ),

            const Spacer(),

            // Share Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => FeedbackPage(
                            caseTitle: selectedCase['title'],
                            cheerleader: selectedCheerleader,
                            scoreTotal: scoreTotal,
                            scoreOutOf: scoreOutOf,
                          ),
                    ),
                  );
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
                  "Share score",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                "You can share your results on LinkedIn or other platforms. Your score will be private.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
