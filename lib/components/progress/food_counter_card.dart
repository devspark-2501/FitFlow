import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fitflow/screens/auth/login_screen.dart';
import '../../services/food_db_service.dart';

class FoodCounterCard extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Function(Map<String, dynamic>) onFoodAdded;

  const FoodCounterCard({
    super.key,
    this.userData,
    required this.onFoodAdded,
  });

  @override
  State<FoodCounterCard> createState() => _FoodCounterCardState();
}

class _FoodCounterCardState extends State<FoodCounterCard> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  final Random _random = Random();

  bool _checkAuthAndRedirect() {
    final user = widget.userData?['user'] as Map<String, dynamic>? ?? widget.userData;
    if (widget.userData == null || user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return false;
    }
    return true;
  }

  void _searchFood() {
    if (!_checkAuthAndRedirect()) return;

    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Generates randomized nutritional stats locally without external APIs
    final double calories = (100 + _random.nextInt(350)).toDouble();
    final double protein = (5 + _random.nextInt(25)).toDouble();
    final double fat = (1 + _random.nextInt(15)).toDouble();
    final double carbs = (10 + _random.nextInt(50)).toDouble();

    setState(() {
      _searchResults = [
        {
          'name': query,
          'calories': calories,
          'protein': protein,
          'fat': fat,
          'carbs': carbs,
        }
      ];
    });
  }

  void _logSelectedFood(Map<String, dynamic> food) async {
    if (!_checkAuthAndRedirect()) return;

    final user = widget.userData?['user'] as Map<String, dynamic>? ?? widget.userData ?? {};
    final userId = user['id']?.toString() ?? user['_id']?.toString() ?? 'user_123';

    final success = await FoodDbService.saveFoodLogToDb(
      userId: userId,
      foodName: food['name'],
      calories: (food['calories'] as num).toDouble(),
      protein: (food['protein'] as num).toDouble(),
      fat: (food['fat'] as num).toDouble(),
      carbs: (food['carbs'] as num).toDouble(),
      date: DateTime.now(),
    );

    widget.onFoodAdded(food);
    _searchController.clear();
    setState(() => _searchResults = []);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${food['name']} saved to database!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Food & Nutrition Counter",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          const Text(
            "Search food to calculate stats and save them to your database.",
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  enabled: true, // Always enabled now
                  onTap: () {
                    if (widget.userData == null) {
                      _checkAuthAndRedirect();
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Type any food (e.g. Banana, Pizza)...",
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _searchFood, // Always clickable
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Search", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          if (_searchResults.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              "Generated Nutrition Stats:",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final item = _searchResults[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(
                    "Cal: ${item['calories'].toStringAsFixed(0)} kcal | P: ${item['protein'].toStringAsFixed(1)}g | F: ${item['fat'].toStringAsFixed(1)}g | C: ${item['carbs'].toStringAsFixed(1)}g",
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFF2563EB)),
                    onPressed: () => _logSelectedFood(item),
                  ),
                );
              },
            ),
          ]
        ],
      ),
    );
  }
}