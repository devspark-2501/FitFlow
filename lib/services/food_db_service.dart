import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodDbService {
  static const String baseUrl = "https://your-backend-api.com/api"; // Replace with your server URL

  /// 1. Fetch real nutrition facts from Open Food Facts API (Free, No Key required)
  static Future<List<Map<String, dynamic>>> searchFoodNutrition(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(
      'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1&page_size=8',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List products = data['products'] ?? [];

        return products.map<Map<String, dynamic>>((p) {
          final nutriments = p['nutriments'] ?? {};
          return {
            'name': p['product_name'] ?? 'Unknown Food',
            'calories': (nutriments['energy-kcal_100g'] ?? nutriments['energy-kcal'] ?? 0).toDouble(),
            'protein': (nutriments['proteins_100g'] ?? nutriments['proteins'] ?? 0).toDouble(),
            'fat': (nutriments['fat_100g'] ?? nutriments['fat'] ?? 0).toDouble(),
            'carbs': (nutriments['carbohydrates_100g'] ?? nutriments['carbohydrates'] ?? 0).toDouble(),
          };
        }).toList();
      }
    } catch (e) {
      print("Error fetching food API: $e");
    }
    return [];
  }

  /// 2. Save logged food item for logged-in user to Backend Database
  static Future<bool> saveFoodLogToDb({
    required String userId,
    required String foodName,
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
    required DateTime date,
  }) async {
    final url = Uri.parse('$baseUrl/food-logs');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'foodName': foodName,
          'calories': calories,
          'protein': protein,
          'fat': fat,
          'carbs': carbs,
          'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Database save error: $e");
      return false;
    }
  }

  /// 3. Fetch specific user's logged daily foods from DB
  static Future<List<Map<String, dynamic>>> getUserDailyFoodLogs(String userId, DateTime date) async {
    final formattedDate = date.toIso8601String().split('T')[0];
    final url = Uri.parse('$baseUrl/food-logs?userId=$userId&date=$formattedDate');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      print("Error loading daily food logs: $e");
    }
    return [];
  }
}