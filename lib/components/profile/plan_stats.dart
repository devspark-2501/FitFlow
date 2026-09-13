import 'package:flutter/material.dart';

class PlanStats extends StatelessWidget {
  final Map<String, dynamic>? stats;

  const PlanStats({super.key, this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
          _buildStatItem("Active Plans", stats?['activePlans']?.toString() ?? "0", Icons.assignment_turned_in),
          Container(height: 30, width: 1, color: const Color(0xFFE2E8F0)),
          _buildStatItem("Followers", stats?['followers']?.toString() ?? "0", Icons.people_outline),
          Container(height: 30, width: 1, color: const Color(0xFFE2E8F0)),
          _buildStatItem("Following", stats?['following']?.toString() ?? "0", Icons.bookmark_border),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF2563EB)),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
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
}