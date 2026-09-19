import 'package:fitflow/components/water/hydration_calculator.dart';
import 'package:fitflow/components/water/water_tracker.dart';
import 'package:fitflow/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterPage extends StatefulWidget {
  const WaterPage({super.key});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  int? dailyGoalMl;
  bool isGoalSet = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedGoal();
  }

  Future<void> _loadSavedGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGoal = prefs.getInt('water_daily_goal');

    if (mounted) {
      setState(() {
        if (savedGoal != null && savedGoal > 0) {
          dailyGoalMl = savedGoal;
          isGoalSet = true;
        }
        isLoading = false;
      });
    }
  }

  Future<void> _onGoalCalculated(int calculatedGoal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_daily_goal', calculatedGoal);

    if (mounted) {
      setState(() {
        dailyGoalMl = calculatedGoal;
        isGoalSet = true;
      });
    }
  }

  Future<void> _resetGoal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('water_daily_goal');

    if (mounted) {
      setState(() {
        dailyGoalMl = null;
        isGoalSet = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blueAccent;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hydration Tracker'),
        elevation: 0,
        actions: [
          if (isGoalSet)
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              tooltip: 'Recalculate Goal',
              onPressed: _resetGoal,
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Welcome Banner Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      primaryColor.withBlue(255).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'HYDRATION & WELLNESS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Stay Hydrated Today',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isGoalSet
                          ? 'Track your daily intake to maintain energy levels and optimal body performance.'
                          : 'Calculate your personal daily water goal based on your age, weight, and activity.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Dynamic View: Calculator or Tracker
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isGoalSet && dailyGoalMl != null
                    ? WaterTracker(
                  key: ValueKey('Tracker_$dailyGoalMl'),
                  dailyGoalMl: dailyGoalMl!,
                  onResetGoal: _resetGoal,
                )
                    : HydrationCalculator(
                  key: const ValueKey('Calculator'),
                  onCalculate: _onGoalCalculated,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}