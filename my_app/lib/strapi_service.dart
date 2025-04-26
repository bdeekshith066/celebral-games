import 'dart:convert';

import 'package:http/http.dart' as http;

class StrapiService {
  final String baseUrl = 'http://192.168.68.106:1337'; // 🔁 updated IP

  Future<List<Map<String, dynamic>>> fetchCasesByCategory(
    String categoryName,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/cases?filters[category][name][\$eq]=$categoryName&populate=*',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("❌ Failed to load cases (${response.statusCode})");
    }

    final decoded = jsonDecode(response.body);

    if (decoded['data'] == null || decoded['data'] is! List) {
      throw Exception("⚠️ Invalid response format");
    }

    final List<dynamic> data = decoded['data'];

    return data.map<Map<String, dynamic>>((item) {
      return {
        'id': item['id'],
        'title': item['title'] ?? 'Untitled',
        'score': item['score'] ?? 0,
        'case_status': item['case_status'] ?? 'Not started',
        'prompt': item['prompt'],
        'difficulty': item['difficulty'] ?? 'easy',
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchQuestionsByCaseId(int caseId) async {
    final url = Uri.parse(
      '$baseUrl/api/cases?populate=*&filters[id][\$eq]=$caseId',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final questions = data['data'][0]['question'];

      return List<Map<String, dynamic>>.from(
        questions.map((q) {
          return {
            'id': q['id'],
            'text': q['text'] ?? '',
            'options': List<String>.from(q['options'] ?? []),
            'correct_option': q['correct_option'] ?? 0,
            'hint': q['hint'] ?? '',
          };
        }),
      );
    } else {
      throw Exception('❌ Failed to load questions (${response.statusCode})');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCheerleaders() async {
    final url = Uri.parse('$baseUrl/api/cheerleaders?populate=image');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('❌ Failed to load cheerleaders');
    }

    final List data = jsonDecode(response.body)['data'];

    return data.map<Map<String, dynamic>>((item) {
      final imageData = item['image'];
      final imageUrl = imageData != null ? imageData['url'] : null;

      return {
        'name': item['name'] ?? 'Unnamed',
        'desc': item['description'] ?? 'No description',
        'imageUrl': imageUrl != null ? '$baseUrl$imageUrl' : null,
      };
    }).toList();
  }

  Future<void> createPlaySession({
    required String cheerleader,
    required String caseTitle,
    required DateTime startedAt,
  }) async {
    final url = Uri.parse('$baseUrl/api/play-sessions');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "data": {
          "cheerleader": cheerleader,
          "case_title": caseTitle,
          "started_at": startedAt.toIso8601String(),
        },
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create play session: ${response.body}");
    }
  }

  Future<void> createCaseResult({
    required String caseTitle,
    required String cheerleader,
    required int scoreTotal,
    required int scoreOutOf,
  }) async {
    final url = Uri.parse('$baseUrl/api/case-results');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "data": {
          "case_title": caseTitle,
          "cheerleader": cheerleader,
          "score_total": scoreTotal,
          "score_out_of": scoreOutOf,
        },
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create case result: ${response.body}");
    }
  }
}
