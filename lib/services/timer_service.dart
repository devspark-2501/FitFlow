import 'dart:convert';
import 'package:http/http.dart' as http;

class TimerService {
  static const String baseUrl = 'http://localhost:5000/api/timer'; // Adjust your API URL

  static Future<bool> saveTimerLog(String userId, Map<String, dynamic> logData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/log'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, ...logData}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchTimerHistory(String userId, String type) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/history/$userId?type=$type'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['logs'] ?? []);
      }
    } catch (_) {}
    return [];
  }
}