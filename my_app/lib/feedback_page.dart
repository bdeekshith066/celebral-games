import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  final String caseTitle;
  final String cheerleader;
  final int scoreTotal;
  final int scoreOutOf;

  const FeedbackPage({
    super.key,
    required this.caseTitle,
    required this.cheerleader,
    required this.scoreTotal,
    required this.scoreOutOf,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (scoreTotal / scoreOutOf).clamp(0, 1).toDouble();
    final int indicatorPos =
        (percentage * MediaQuery.of(context).size.width).toInt();
    final int passLinePos =
        (0.7 * MediaQuery.of(context).size.width).toInt(); // e.g., 70% pass

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Feedback'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Case: $caseTitle",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            const Text(
              "Score Summary",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your score is $scoreTotal out of $scoreOutOf.",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Cheerleader: $cheerleader",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Performance Indicator",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Stack(
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
                  left: indicatorPos.toDouble().clamp(
                    0,
                    MediaQuery.of(context).size.width - 30,
                  ),
                  top: -20,
                  child: const Icon(
                    Icons.arrow_drop_down,
                    size: 30,
                    color: Colors.brown,
                  ),
                ),
                Positioned(
                  left: passLinePos.toDouble(),
                  top: 0,
                  bottom: 0,
                  child: Container(width: 2, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [Text("Low"), Text("Medium"), Text("High")],
            ),

            const SizedBox(height: 50),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("View all hints for the case"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(
                  context,
                  (route) => route.isFirst,
                ); // Home screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Go back to home screen"),
            ),
          ],
        ),
      ),
    );
  }
}
