import 'dart:convert';
import 'package:fitflow/screens/water/water_page.dart';
import 'package:fitflow/services/water_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityStats extends StatefulWidget {
  final Map<String, dynamic>? activity;

  const ActivityStats({super.key, this.activity});

  @override
  State<ActivityStats> createState() => _ActivityStatsState();
}

class _ActivityStatsState extends State<ActivityStats> {
  double _todayWaterLiters = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTodayWater();
  }

  Future<void> _loadTodayWater() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('userData');

    if (userString != null) {
      final userData = jsonDecode(userString);
      final userId = userData['_id'] ?? userData['id'];

      if (userId != null) {
        final data = await WaterService.fetchTodayWaterLogs(userId);
        if (data != null && data['success'] == true && mounted) {
          final int totalMl = data['totalIntake'] ?? 0;
          setState(() {
            _todayWaterLiters = totalMl / 1000.0; // Convert ml to Liters
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If props activity water is provided, fallback to it, otherwise use fetched liters
    final String waterDisplay = _todayWaterLiters > 0
        ? '${_todayWaterLiters.toStringAsFixed(1)}L'
        : (widget.activity?['water'] != null ? '${widget.activity!['water']}L' : '0L');

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
            widget.activity?['workouts']?.toString() ?? '0',
            Icons.fitness_center_rounded,
            const Color(0xFF2563EB),
            null,
          ),
          _buildStatDivider(),
          _buildStatTile(
            'Calories',
            widget.activity?['calories'] != null ? '${widget.activity!['calories']} kcal' : '0 kcal',
            Icons.local_fire_department_rounded,
            const Color(0xFFF97316),
            null,
          ),
          _buildStatDivider(),
          _buildStatTile(
            'Water',
            waterDisplay,
            Icons.water_drop_rounded,
            const Color(0xFF0284C7),
                () async {
              // Navigate to water page and refresh upon returning
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WaterPage()),
              );
              _loadTodayWater();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
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