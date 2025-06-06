import 'package:flutter/material.dart';

import 'cheerleader_page.dart';
import 'strapi_service.dart';

class CasesPage extends StatefulWidget {
  final String category;

  const CasesPage({super.key, required this.category});

  @override
  State<CasesPage> createState() => _CasesPageState();
}

class _CasesPageState extends State<CasesPage> {
  bool isLoading = true;
  int? selectedCaseId;
  Map<String, dynamic>? selectedCase;
  List<Map<String, dynamic>> cases = [];

  @override
  void initState() {
    super.initState();
    loadCases();
  }

  Future<void> loadCases() async {
    try {
      final result = await StrapiService().fetchCasesByCategory(
        widget.category,
      );

      if (result.isEmpty) {
        setState(() {
          cases = [];
          isLoading = false;
        });
        return;
      }

      final updatedCases = <Map<String, dynamic>>[];

      for (var caseItem in result) {
        final title = caseItem['title'] ?? '';

        final caseProgress = await StrapiService().fetchCaseProgress(
          caseTitle: title,
          userEmail: "bdeekshith6@gmail.com", // hardcoded for now
        );

        updatedCases.add({
          ...caseItem,
          'score': caseProgress?['score'] ?? 0,
          'case_status': caseProgress?['case_status'] ?? 'Not started',
        });
      }

      if (!mounted) return;
      setState(() {
        cases = updatedCases;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Failed to load cases: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cases: ${widget.category}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : cases.isEmpty
              ? const Center(
                child: Text(
                  "No cases available for this category.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      itemCount: cases.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final caseItem = cases[index];
                        final title = caseItem['title'] ?? '';
                        final score = caseItem['score'] ?? 0;
                        final status = caseItem['case_status'] ?? 'Not started';
                        final isSelected = selectedCaseId == caseItem['id'];

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedCaseId = caseItem['id'];
                              selectedCase = caseItem;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Colors.green[100]
                                      : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Colors.green
                                        : Colors.grey.shade300,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Case ${index + 1}: $title',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              status == 'Completed'
                                                  ? Colors.green
                                                  : (status == 'In progress'
                                                      ? Colors.orange
                                                      : Colors.black54),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "Score",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "$score",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: ElevatedButton(
            onPressed:
                selectedCase != null
                    ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  CheerleaderPage(selectedCase: selectedCase!),
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
            child: const Text("Start case", style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
