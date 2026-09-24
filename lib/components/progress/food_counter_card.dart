import 'package:flutter/material.dart';
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
  bool _isSearching = false;

  void _searchFood() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    final results = await FoodDbService.searchFoodNutrition(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _logSelectedFood(Map<String, dynamic> food) async {
    final user = widget.userData?['user'] as Map<String, dynamic>? ?? widget.userData ?? {};
    final userId = user['id']?.toString() ?? user['_id']?.toString();

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to save food logs.")),
      );
      return;
    }

    // Save to Database
    final success = await FoodDbService.saveFoodLogToDb(
      userId: userId,
      foodName: food['name'],
      calories: (food['calories'] as num).toDouble(),
      protein: (food['protein'] as num).toDouble(),
      fat: (food['fat'] as num).toDouble(),
      carbs: (food['carbs'] as num).toDouble(),
      date: DateTime.now(),
    );

    if (success) {
      widget.onFoodAdded(food);
      _searchController.clear();
      setState(() => _searchResults = []);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${food['name']} saved to database!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save food log to database.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = widget.userData != null;

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
            "Search food to automatically fetch and save calories, protein, and fat to your account.",
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  enabled: isLoggedIn,
                  decoration: InputDecoration(
                    hintText: isLoggedIn ? "e.g. Banana, Chicken Breast" : "Log in to search food",
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
                onPressed: isLoggedIn ? _searchFood : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSearching
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text("Search", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          if (_searchResults.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              "Select Food to Save:",
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
                    "Cal: ${item['calories'].toStringAsFixed(0)} kcal | P: ${item['protein']}g | F: ${item['fat']}g | C: ${item['carbs']}g",
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