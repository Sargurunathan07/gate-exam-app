import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProgressApiService {
  static const String _baseUrl = 'http://localhost:8080';

  static Future<void> syncLocalProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final completedTopics =
        prefs.getStringList('gate_completed_topics') ?? [];

    final sessionsJson = prefs.getString('gate_study_sessions');
    final studySessions = <Map<String, dynamic>>[];

    if (sessionsJson != null) {
      final decoded = jsonDecode(sessionsJson) as List<dynamic>;
      studySessions.addAll(
        decoded.map((item) => Map<String, dynamic>.from(item as Map)),
      );
    }

    final response = await http
        .put(
          Uri.parse('$_baseUrl/api/progress'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'completedTopics': completedTopics,
            'studySessions': studySessions,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Could not save progress: ${response.statusCode}');
    }
  }
}
