import 'package:flutter/material.dart';

class ActivityStats extends StatelessWidget {
  const ActivityStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatTile('Workouts', '12', Icons.fitness_center_rounded, const Color(0xFF38BDF8)),
          _buildStatDivider(),
          _buildStatTile('Calories', '3.4k', Icons.local_fire_department_rounded, const Color(0xFFF97316)),
          _buildStatDivider(),
          _buildStatTile('Water', '2.5L', Icons.water_drop_rounded, const Color(0xFF06B6D4)),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.15),
    );
  }
}