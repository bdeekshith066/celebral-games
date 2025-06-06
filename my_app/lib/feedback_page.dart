import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  final Map<String, int> categoryTotal;
  final Map<String, int> categoryCorrect;
  final Map<String, int> categoryIncorrect;

  const FeedbackPage({
    super.key,
    required this.categoryTotal,
    required this.categoryCorrect,
    required this.categoryIncorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Case breakdown",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          buildManualTable(),
                          const SizedBox(height: 30),
                          const Text(
                            "Your last 5 scores",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 25),
                          _buildScoreItem(
                            "Coffee Consumption in a Small Town",
                            "2 days ago",
                            237,
                          ),
                          _buildScoreItem(
                            "Golf Balls in the Country",
                            "4 days ago",
                            127,
                          ),
                          _buildScoreItem(
                            "Healthy Snacks in Germany",
                            "5 days ago",
                            320,
                          ),
                          _buildScoreItem(
                            "Fast Food Market",
                            "11 days ago",
                            297,
                          ),
                          _buildScoreItem(
                            "Football Sales Market in China",
                            "2 days ago",
                            337,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 20),
                  child: ElevatedButton(
                    onPressed:
                        () => Navigator.popUntil(
                          context,
                          (route) => route.isFirst,
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Go back to home screen"),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildManualTable() {
    final headers = ["Category", "Total", "Correct", "Incorrect"];
    final categories = ["Framework", "Calculations", "Brainstorming", "Others"];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        children: [
          _buildTableRow(headers, isHeader: true),
          ...categories.map((cat) {
            return _buildTableRow([
              cat,
              "${categoryTotal[cat] ?? 0}",
              "${categoryCorrect[cat] ?? 0}",
              "${categoryIncorrect[cat] ?? 0}",
            ]);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return Row(
      children: List.generate(cells.length, (i) {
        return Container(
          width: i == 0 ? 130 : 82,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color:
                    i == cells.length - 1 ? Colors.transparent : Colors.black,
                width: 1,
              ),
              bottom: const BorderSide(color: Colors.black, width: 1),
            ),
            color: isHeader ? const Color(0xFFE6E6E6) : const Color(0xFFF9F9F9),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          alignment: Alignment.centerLeft,
          child: Text(
            cells[i],
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildScoreItem(String title, String date, int score) {
    final isGood = score >= 200;
    final bgColor = isGood ? Colors.green : Colors.red;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$title\n$date",
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "$score",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
