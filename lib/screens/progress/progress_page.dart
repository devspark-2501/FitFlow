import 'package:fitflow/components/progress/food_counter_card.dart';
import 'package:fitflow/components/progress/welcome_header.dart';
import 'package:fitflow/services/food_db_service.dart';
import 'package:flutter/material.dart';
// import '../components/progress/welcome_header.dart';
// import '../components/progress/food_counter_card.dart';
// import '../services/food_db_service.dart';

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
      _dailyLogs.add(food);
      _calculateTotals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WelcomeHeader(userData: widget.userData),
              const SizedBox(height: 20),

              // Dynamic Daily Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _macroTile("Calories", "${_totalCalories.toStringAsFixed(0)} kcal"),
                    _macroTile("Protein", "${_totalProtein.toStringAsFixed(1)}g"),
                    _macroTile("Fat", "${_totalFat.toStringAsFixed(1)}g"),
                    _macroTile("Carbs", "${_totalCarbs.toStringAsFixed(1)}g"),
                  ],
                ),
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
                    child: ListTile(
                      title: Text(item['foodName'] ?? item['name'] ?? 'Food Item'),
                      subtitle: Text("Cal: ${item['calories']} kcal | P: ${item['protein']}g | F: ${item['fat']}g"),
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