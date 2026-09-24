import 'package:fitflow/screens/auth/login_screen.dart';
import 'package:fitflow/screens/progress/progress_page.dart';
import 'package:flutter/material.dart';

class DailyWorkoutCard extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const DailyWorkoutCard({
    super.key,
    this.userData,
  });

  // Calculate Daily Calorie Requirement dynamically from user age and metrics
  double _calculateAgeBasedCalorieTarget(Map<String, dynamic> user) {
    final int age = (user['age'] as num?)?.toInt() ?? 22;
    final double weight = (user['weight'] as num?)?.toDouble() ?? 70.0;
    final double height = (user['height'] as num?)?.toDouble() ?? 175.0;
    final String gender = user['gender']?.toString().toLowerCase() ?? 'male';

    // Mifflin-St Jeor BMR Equation
    double bmr = (10 * weight) + (6.25 * height) - (5 * age);
    if (gender == 'female') {
      bmr -= 161;
    } else {
      bmr += 5;
    }

    // Multiply by light activity multiplier (1.375)
    return bmr * 1.375;
  }

  void _handleNavigation(BuildContext context) {
    final user = userData?['user'] as Map<String, dynamic>? ?? userData;

    // Direct guests to login
    if (userData == null || user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      // Direct logged-in user to ProgressPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProgressPage(userData: userData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = userData?['user'] as Map<String, dynamic>? ?? userData ?? {};

    final String workoutTitle = user['todayWorkoutTitle'] ?? "Beginner Fitness Start";
    final String duration = user['todayWorkoutDuration'] ?? "30 mins";
    final String level = user['fitnessLevel'] ?? "Beginner";

    final double consumedCalories = (user['todayWorkoutKcal'] as num?)?.toDouble() ?? 0.0;
    final double calorieTarget = _calculateAgeBasedCalorieTarget(user);

    // Calculate dynamic progress factor bounded between 0.0 and 1.0
    final double progress = (consumedCalories / calorieTarget).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.30),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.fitness_center_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      "TODAY'S WORKOUT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_outline, color: Colors.white70),
                onPressed: () => _handleNavigation(context),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            workoutTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Track daily targets aligned with your personal goal.",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _infoChip(Icons.timer_outlined, duration),
              const SizedBox(width: 16),
              _infoChip(Icons.local_fire_department_outlined, "${consumedCalories.toStringAsFixed(0)} / ${calorieTarget.toStringAsFixed(0)} kcal"),
              const SizedBox(width: 16),
              _infoChip(Icons.bar_chart_rounded, level),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Target Progress", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(
                "${(progress * 100).toStringAsFixed(0)}%",
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () => _handleNavigation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1D4ED8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 22),
                  SizedBox(width: 6),
                  Text("Start Workout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}