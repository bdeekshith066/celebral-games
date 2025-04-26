import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'case_prompt_page.dart';
import 'strapi_service.dart';

class CheerleaderPage extends StatefulWidget {
  final Map<String, dynamic> selectedCase;

  const CheerleaderPage({super.key, required this.selectedCase});

  @override
  State<CheerleaderPage> createState() => _CheerleaderPageState();
}

class _CheerleaderPageState extends State<CheerleaderPage> {
  List<Map<String, dynamic>> cheerleaders = [];
  String? selectedCheerleader;
  String? selectedCheerleaderImage; // ✅ ADD THIS
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCheerleaders();
  }

  Future<void> loadCheerleaders() async {
    try {
      final result = await StrapiService().fetchCheerleaders();
      if (!mounted) return;
      setState(() {
        cheerleaders = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to load cheerleaders: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose your Cheerleader"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select your case companion",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.9,
                            ),
                        itemCount: cheerleaders.length,
                        itemBuilder: (context, index) {
                          final cheerleader = cheerleaders[index];
                          final isSelected =
                              selectedCheerleader == cheerleader["name"];

                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedCheerleader = cheerleader["name"];
                                selectedCheerleaderImage =
                                    cheerleader["imageUrl"];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.green[200]
                                        : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  cheerleader["imageUrl"] != null
                                      ? SvgPicture.network(
                                        cheerleader["imageUrl"]!,
                                        height: 50,
                                        width: 50,
                                        placeholderBuilder:
                                            (context) =>
                                                const CircularProgressIndicator(),
                                      )
                                      : const Icon(Icons.person, size: 50),
                                  const SizedBox(height: 8),
                                  Text(
                                    cheerleader["name"]!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cheerleader["desc"]!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed:
                          selectedCheerleader != null
                              ? () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CasePromptPage(
                                          selectedCase: widget.selectedCase,
                                          selectedCheerleader:
                                              selectedCheerleader!,
                                          selectedCheerleaderImage:
                                              selectedCheerleaderImage!,
                                        ),
                                  ),
                                );
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Proceed to Case",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
    );
  }
}
