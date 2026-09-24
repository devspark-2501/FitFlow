import 'package:fitflow/components/home/progress_card.dart';
import 'package:flutter/material.dart';
import 'package:fitflow/components/progress/food_counter_card.dart';
import 'package:fitflow/components/progress/welcome_header.dart';
//import 'package:fitflow/components/progress/progress_card.dart';
import 'package:fitflow/services/food_db_service.dart';

class ProgressPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ProgressPage({super.key, this.userData});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  List<Map<String, dynamic>> _dailyLogs = [];
  double _totalCalories = 0;
  double _totalProtein = 0;
  double _totalFat = 0;
  double _totalCarbs = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserLogs();
  }

  void _fetchUserLogs() async {
    final user = widget.userData?['user'] as Map<String, dynamic>? ?? widget.userData ?? {};
    final userId = user['id']?.toString() ?? user['_id']?.toString();

    if (userId != null && userId.isNotEmpty) {
      final logs = await FoodDbService.getUserDailyFoodLogs(userId, DateTime.now());
      setState(() {
        _dailyLogs = logs;
        _calculateTotals();
      });
    }
  }

  void _calculateTotals() {
    double cal = 0, p = 0, f = 0, c = 0;
    for (var log in _dailyLogs) {
      cal += (log['calories'] as num? ?? 0).toDouble();
      p += (log['protein'] as num? ?? 0).toDouble();
      f += (log['fat'] as num? ?? 0).toDouble();
      c += (log['carbs'] as num? ?? 0).toDouble();
    }
    _totalCalories = cal;
    _totalProtein = p;
    _totalFat = f;
    _totalCarbs = c;
  }

  void _onFoodAdded(Map<String, dynamic> food) {
    setState(() {
      _dailyLogs.add({
        'foodName': food['name'] ?? food['foodName'],
        'calories': food['calories'],
        'protein': food['protein'],
        'fat': food['fat'],
        'carbs': food['carbs'],
      });
      _calculateTotals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = "${now.day}/${now.month}/${now.year}";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Nutrition & Progress",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WelcomeHeader(userData: widget.userData),
              const SizedBox(height: 20),

              // Dynamic Daily Summary Header with Date
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Daily Nutrition Summary",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            formattedDate,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _macroTile("Calories", "${_totalCalories.toStringAsFixed(0)} kcal"),
                        _macroTile("Protein", "${_totalProtein.toStringAsFixed(1)}g"),
                        _macroTile("Fat", "${_totalFat.toStringAsFixed(1)}g"),
                        _macroTile("Carbs", "${_totalCarbs.toStringAsFixed(1)}g"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // Interactive Weekly Activity Graph
              ProgressCard(
                userData: widget.userData,
                onTap: () {},
              ),

              const SizedBox(height: 24),
              FoodCounterCard(
                userData: widget.userData,
                onFoodAdded: _onFoodAdded,
              ),

              const SizedBox(height: 24),
              const Text(
                "Today's Logged Foods",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 10),

              _dailyLogs.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("No foods logged today. Search and add above!", style: TextStyle(color: Color(0xFF64748B))),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _dailyLogs.length,
                itemBuilder: (context, index) {
                  final item = _dailyLogs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text(
                        item['foodName'] ?? item['name'] ?? 'Food Item',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Cal: ${(item['calories'] as num).toStringAsFixed(0)} kcal | P: ${(item['protein'] as num).toStringAsFixed(1)}g | F: ${(item['fat'] as num).toStringAsFixed(1)}g | C: ${(item['carbs'] as num? ?? 0).toStringAsFixed(1)}g",
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _macroTile(String title, String val) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}