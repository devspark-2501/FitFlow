import 'package:flutter/material.dart';

class ActivityStats extends StatelessWidget {
  final Map<String, dynamic>? activity;

  const ActivityStats({super.size, this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatTile(
              'Workouts',
              activity?['workouts']?.toString() ?? '0',
              Icons.fitness_center_rounded,
              const Color(0xFF2563EB)
          ),
          _buildStatDivider(),
          _buildStatTile(
              'Calories',
              activity?['calories'] != null ? '${activity!['calories']} kcal' : '0 kcal',
              Icons.local_fire_department_rounded,
              const Color(0xFFF97316)
          ),
          _buildStatDivider(),
          _buildStatTile(
              'Water',
              activity?['water'] != null ? '${activity!['water']}L' : '0L',
              Icons.water_drop_rounded,
              const Color(0xFF0284C7)
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 36,
      width: 1,
      color: const Color(0xFFE2E8F0),
    );
  }
}