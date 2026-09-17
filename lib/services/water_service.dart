import 'dart:convert';
import 'package:http/http.dart' as http;

class WaterService {
  static const String baseUrl = 'http://127.0.0.1:5000/api/water';

  static String getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  static Future<bool> addWaterLog(String userId, int amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
          'date': getTodayDateString(),
        }),
      );
      final data = jsonDecode(response.body);
      return response.statusCode == 201 && data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> fetchTodayWaterLogs(String userId) async {
    try {
      final today = getTodayDateString();
      final response = await http.get(
        Uri.parse('$baseUrl/$userId/$today'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}