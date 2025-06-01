// This file contains the StrapiService class, which handles all API calls to the Strapi backend.
// It includes methods to fetch cases by category, fetch questions by case ID,s
// fetch cheerleaders, create play sessions, create case results, and fetch prompt images.
// The class uses the http package to make GET and POST requests to the Strapi API.ss
// The methods return the data in a structured format, making it easy to use in the Flutter app.

import 'dart:convert';

import 'package:http/http.dart' as http;

class StrapiService {
  final String baseUrl = 'http://192.168.217.106:1337';

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
    required String userEmail,
    int score = 0,
    bool completed = false,
    List<dynamic> selectedAnswers = const [],
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
          "user_email": userEmail,
          "total_score": score,
          "completed": completed,
          "selected_answer": selectedAnswers,
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

  Future<String?> fetchPromptImageUrl() async {
    final url = Uri.parse('$baseUrl/api/prompt-images?populate=pic');
    final response = await http.get(url);

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body)['data'];
    if (data == null || data.isEmpty) return null;

    final imageData = data[0]['attributes']['pic']['data'];
    if (imageData == null) return null;

    final imageUrl = imageData['attributes']['url'];
    return '$baseUrl$imageUrl';
  }

  Future<Map<String, dynamic>?> fetchPlaySession({
    required String caseTitle,
    required String userEmail,
  }) async {
    final url = Uri.parse(
      '$baseUrl/api/play-sessions?filters[case_title][\$eq]=$caseTitle&filters[user_email][\$eq]=$userEmail&populate=*',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      if (data.isNotEmpty) return data[0]['attributes'];
      return null;
    } else {
      throw Exception('Failed to fetch play session');
    }
  }

  Future<int?> getCaseIdByTitle(String title) async {
    final url = Uri.parse('$baseUrl/api/cases?filters[title][\$eq]=$title');
    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['data'].isNotEmpty) {
      return data['data'][0]['id'];
    }
    return null;
  }

  Future<void> updateCaseStatusAndScore({
    required String caseTitle,
    required int finalScore,
  }) async {
    // Step 1: Fetch the case by title
    final urlFetch = Uri.parse(
      '$baseUrl/api/cases?filters[title][\$eq]=$caseTitle',
    );

    final fetchResponse = await http.get(urlFetch);
    final data = jsonDecode(fetchResponse.body);

    if (fetchResponse.statusCode != 200 || data['data'].isEmpty) {
      throw Exception('❌ Failed to fetch case by title');
    }

    // Step 2: Extract the ID
    final int caseId = data['data'][0]['id'];

    // Step 3: Update score and status using PUT
    final updateUrl = Uri.parse('$baseUrl/api/cases/$caseId');
    final updateResponse = await http.put(
      updateUrl,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "data": {"score": finalScore, "case_status": "Completed"},
      }),
    );

    if (updateResponse.statusCode != 200) {
      throw Exception("❌ Failed to update case: ${updateResponse.body}");
    }
  }

  Future<void> saveCaseProgress({
    required String caseTitle,
    required String userEmail,
    required int score,
    required String status,
  }) async {
    final url = Uri.parse('$baseUrl/api/case-progresses'); // use correct plural
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "data": {
          "case_title": caseTitle,
          "user_email": userEmail,
          "score": score,
          "case_status": status,
        },
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("❌ Failed to save case progress: ${response.body}");
    }
  }

  Future<Map<String, dynamic>?> fetchCaseProgress({
    required String caseTitle,
    required String userEmail,
  }) async {
    final url = Uri.parse(
      '$baseUrl/api/case-progresses?filters[case_title][\$eq]=$caseTitle&filters[user_email][\$eq]=$userEmail',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      if (data != null && data.isNotEmpty) {
        return data[0]['attributes'];
      }
    }
    return null;
  }
}
