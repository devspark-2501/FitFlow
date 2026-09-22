import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback onTap;

  const ProgressCard({
    super.key,
    this.userData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = userData?['user'] ?? userData;
    final bool isLoggedIn = user != null;

    // Active vs Empty Graph Heights
    final List<double> weeklyData = isLoggedIn
        ? [0.4, 0.7, 0.3, 0.9, 0.5, 0.2, 0.0]
        : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Weekly Activity",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isLoggedIn ? "Your active summary this week" : "Sign in to record your workout metrics",
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          Container(
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statTile("Burned", isLoggedIn ? "1,240" : "0", "kcal", Colors.orange),
                    _divider(),
                    _statTile("Active", isLoggedIn ? "95" : "0", "mins", const Color(0xFF2563EB)),
                    _divider(),
                    _statTile("Streak", isLoggedIn ? "4/7" : "0/7", "days", Colors.green),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                const SizedBox(height: 16),

                // Interactive Activity Bar Graph
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _dayBar("Mon", weeklyData[0], false),
                    _dayBar("Tue", weeklyData[1], false),
                    _dayBar("Wed", weeklyData[2], false),
                    _dayBar("Thu", weeklyData[3], isLoggedIn),
                    _dayBar("Fri", weeklyData[4], false),
                    _dayBar("Sat", weeklyData[5], false),
                    _dayBar("Sun", weeklyData[6], false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              TextSpan(
                text: " $unit",
                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(height: 28, width: 1, color: const Color(0xFFE2E8F0));
  }

  Widget _dayBar(String day, double heightFactor, bool isToday) {
    return Column(
      children: [
        Container(
          height: 54,
          width: 10,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 54 * heightFactor,
            width: 10,
            decoration: BoxDecoration(
              color: isToday ? const Color(0xFF2563EB) : const Color(0xFF93C5FD),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? const Color(0xFF2563EB) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}