import 'package:flutter/material.dart';

import 'categories_page.dart';

class GameplayPage extends StatelessWidget {
  const GameplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gameplay'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Gameplay",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _gameplayItem(
                        "Standard case questions",
                        "You will see regular (and surprise) case questions based on the case prompt chosen",
                        Icons.looks_one,
                      ),
                      _gameplayItem(
                        "Objective answers (beta version)",
                        "Choose answers from 4 options provided for a fast casing experience. No going back!",
                        Icons.looks_two,
                      ),
                      _gameplayItem(
                        "Avoid rabbit holes",
                        "Each question has possible incorrect routes where you can be lost - really think before you answer",
                        Icons.looks_3,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Scoring Explanation",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _scoringItem(
                        "Your score",
                        "Your total score will be a combination of time left (in seconds) + rabbit taken (negative)",
                        Icons.person,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 32.0),
                        child: Column(
                          children: [
                            _scoringItem(
                              "Remaining time",
                              "Out of the possible 250 seconds, if you complete the case in 200 seconds, you score 40 in category 1",
                              Icons.verified_user,
                            ),
                            _scoringItem(
                              "Rabbit hole",
                              "For each rabbit hole visited, 10 points will be deducted, in addition to seconds wasted",
                              Icons.verified_user,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoriesPage(),
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
                      "Progress to category selection",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _gameplayItem(String title, String subtitle, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }

  Widget _scoringItem(String title, String subtitle, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }
}
