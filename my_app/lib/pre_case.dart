import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PreCasePage extends StatefulWidget {
  final String selectedCheerleader;

  const PreCasePage({super.key, required this.selectedCheerleader});

  @override
  PreCasePageState createState() => PreCasePageState(); // ✅ Update here
}

class PreCasePageState extends State<PreCasePage> {
  // ✅ Match class name here
  String cheerleaderMessage = "You're doing great! Keep going!";
  int seconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          seconds++;
        });
        _startTimer();
      }
    });
  }

  String _getCheerleaderImage(String name) {
    Map<String, String> cheerleaderImages = {
      "Barnie Sunders": "assets/images/barnie.svg",
      "Rude Van Pistolrooy": "assets/images/pistelrooy.svg",
      "Donaldine Trumpet": "assets/images/Donaldine.svg",
      "Uncle Bob": "assets/images/uncle_bob.svg",
      "Rocky Cervais": "assets/images/rocky.svg",
      "No cheerleader": "assets/images/rocky.svg",
    };

    return cheerleaderImages[name] ?? "assets/images/default.svg";
  }

  @override
  Widget build(BuildContext context) {
    String cheerleaderImage = _getCheerleaderImage(widget.selectedCheerleader);

    return Scaffold(
      appBar: AppBar(title: const Text("Case xxx")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage("assets/images/case_image.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              "Case prompt - xxxxxxx",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  margin: const EdgeInsets.only(left: 40),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    cheerleaderMessage,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                Positioned(
                  left: -5,
                  top: -10,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: ClipOval(
                      child: SvgPicture.asset(
                        cheerleaderImage,
                        height: 40,
                        width: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to next screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Proceed", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      seconds.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text("Seconds", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
