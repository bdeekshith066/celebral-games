// This file contains the StrapiService class, which handles all API calls to the Strapi backend.
// It includes methods to fetch cases by category, fetch questions by case ID,s
// fetch cheerleaders, create play sessions, create case results, and fetch prompt images.
// The class uses the http package to make GET and POST requests to the Strapi API.ss
// The methods return the data in a structured format, making it easy to use in the Flutter app.
import 'dart:convert';

import 'package:http/http.dart' as http;

class StrapiService {
  final String baseUrl = 'https://playful-chicken-f4698d50ca.strapiapp.com';
  //final String baseUrl = 'http://192.168.19.106:1337';

  Future<List<Map<String, dynamic>>> fetchCasesByCategory(
    String categoryName,
  ) async {
    final encoded = Uri.encodeComponent(categoryName);
    final url = Uri.parse(
      '$baseUrl/api/cases?populate=category&filters[category][name][\$eq]=$encoded',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch cases');
    }

    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded['data'];

    return data.map<Map<String, dynamic>>((item) {
      final category = item['category']?['name'] ?? 'Unknown';
      final promptRaw = item['prompt'] ?? [];
      final promptText =
          promptRaw.isNotEmpty
              ? promptRaw[0]['children'][0]['text']
              : 'Prompt not available';

      return {
        'id': item['id'],
        'title': item['title'] ?? 'Untitled',
        'score': item['score'],
        'case_status': item['case_status'],
        'prompt': promptText,
        'difficulty': item['difficulty'],
        'category': category,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchQuestionsByCaseId(int caseId) async {
    final url = Uri.parse(
      '$baseUrl/api/cases?filters[id][\$eq]=$caseId&populate[question][populate]=incorrect_flows',
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
            'category': q['category'] ?? 'Others',
            'max_attempts': q['max_attempts'] ?? 2,
            'return_to_main_flow_on_completion':
                q['return_to_main_flow_on_completion'] ?? true,
            'incorrect_flows': List<Map<String, dynamic>>.from(
              (q['incorrect_flows'] ?? []).map(
                (flow) => {
                  'id': flow['id'],
                  'Title': flow['Title'] ?? '',
                  'options': List<String>.from(flow['options'] ?? []),
                  'correct_option': flow['correct_option'] ?? 0,
                  'hint': flow['hint'] ?? '',
                  'flow_order': flow['flow_order'] ?? 0,
                  'category': flow['category'] ?? 'Others',
                },
              ),
            ),
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
        'imageUrl': imageUrl,
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
    final urlFetch = Uri.parse(
      '$baseUrl/api/cases?filters[title][\$eq]=$caseTitle',
    );
    final fetchResponse = await http.get(urlFetch);
    final data = jsonDecode(fetchResponse.body);

    if (fetchResponse.statusCode != 200 || data['data'].isEmpty) {
      throw Exception('❌ Failed to fetch case by title');
    }

    final int caseId = data['data'][0]['id'];

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
    final url = Uri.parse('$baseUrl/api/case-progresses');
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

  Future<int> fetchCaseCountForCategory(String categoryName) async {
    final encodedCategory = Uri.encodeComponent(categoryName);
    final url = Uri.parse(
      '$baseUrl/api/cases?filters[category][name][\$eq]=$encodedCategory',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'].length;
    } else {
      throw Exception('❌ Failed to fetch case count for $categoryName');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllCheerleadersWithMessages() async {
    final url = Uri.parse(
      '$baseUrl/api/cheerleaders?populate=personaMessages,image',
    );
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('❌ Failed to load cheerleaders with messages');
    }

    final List data = jsonDecode(response.body)['data'];

    return data.map<Map<String, dynamic>>((item) {
      final imageData = item['image'];
      final imageUrl = imageData != null ? imageData['url'] : null;

      final messagesRaw = item['personaMessages'] ?? [];
      final messages = List<Map<String, dynamic>>.from(
        messagesRaw.map(
          (m) => {'trigger': m['trigger'] ?? '', 'message': m['message'] ?? ''},
        ),
      );

      return {
        'name': item['name'] ?? 'Unnamed',
        'desc': item['description'] ?? 'No description',
        'imageUrl': imageUrl != null ? '$baseUrl$imageUrl' : null,
        'personaMessages': messages,
      };
    }).toList();
  }

  Future<Map<String, List<String>>> fetchCheerleaderMessages(
    String cheerleaderName,
  ) async {
    final response = await http.get(
      Uri.parse(
        'http://your-strapi-url/api/cheerleaders?populate=personaMessage',
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final cheerleader = jsonData['data'].firstWhere(
        (c) => c['attributes']['name'] == cheerleaderName,
        orElse: () => null,
      );

      if (cheerleader == null) return {};

      final messagesList = cheerleader['attributes']['personaMessage'] as List;

      return {
        for (var m in messagesList)
          m['trigger']:
              (m['messages'] as String)
                  .split(',')
                  .map((s) => s.trim())
                  .toList(),
      };
    } else {
      throw Exception('Failed to load cheerleader messages');
    }
  }

  Future<Map<String, dynamic>> fetchCheerleaderByName(String name) async {
    final url = Uri.parse(
      "http://localhost:1337/api/cheerleaders?filters[name][\$eq]=$name&populate=personaMessages",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'].isNotEmpty ? data['data'][0]['attributes'] : {};
    } else {
      throw Exception("Failed to fetch cheerleader by name");
    }
  }

  Future<String?> fetchPromptImageUrl() async {
    final url = Uri.parse('$baseUrl/api/prompt-images?populate=pic');
    final response = await http.get(url);

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body)['data'];
    if (data == null || data.isEmpty) return null;

    final imageData = data[0]['pic'];
    if (imageData == null || imageData['url'] == null) return null;

    return imageData['url'].startsWith('http')
        ? imageData['url']
        : '$baseUrl${imageData['url']}';
  }
}
