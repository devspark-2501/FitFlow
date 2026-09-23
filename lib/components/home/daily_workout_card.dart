import 'package:flutter/material.dart';

class DailyWorkoutCard extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback onStartTap;

  const DailyWorkoutCard({
    super.key,
    this.userData,
    required this.onStartTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = userData?['user'] as Map<String, dynamic>? ?? userData ?? {};

    // Dynamic workout details or initial default state
    final String workoutTitle = user['todayWorkoutTitle'] ?? "Beginner Fitness Start";
    final String duration = user['todayWorkoutDuration'] ?? "N/A";
    final String calories = user['todayWorkoutKcal'] ?? "0 kcal";
    final String level = user['fitnessLevel'] ?? "Beginner";

    final int completedExercises = (user['completedExercises'] as num?)?.toInt() ?? 0;
    final int totalExercises = (user['totalExercises'] as num?)?.toInt() ?? 0;
    final double progress = totalExercises > 0 ? (completedExercises / totalExercises) : 0.0;

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
                onPressed: onStartTap,
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
          Text(
            totalExercises == 0
                ? "Start your first session to build your routine."
                : "Keep up the momentum for today's session.",
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _infoChip(Icons.timer_outlined, duration),
              const SizedBox(width: 16),
              _infoChip(Icons.local_fire_department_outlined, calories),
              const SizedBox(width: 16),
              _infoChip(Icons.bar_chart_rounded, level),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Progress", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(
                "$completedExercises / $totalExercises Completed",
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
              onPressed: onStartTap,
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