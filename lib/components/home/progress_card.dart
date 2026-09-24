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
    final user = userData?['user'] as Map<String, dynamic>? ?? userData ?? {};

    // Safely extract stats or fall back to defaults
    final String burnedKcal = user['burnedKcal']?.toString() ?? '0';
    final String activeMins = user['activeMins']?.toString() ?? '0';
    final String streakDays = user['streakDays']?.toString() ?? '0/7';

    // Parse weekly activity factors (expects List<double> or fallback)
    final List<dynamic> rawWeekly = user['weeklyActivity'] as List<dynamic>? ?? [];
    final List<double> weeklyData = List.generate(7, (index) {
      if (index < rawWeekly.length && rawWeekly[index] is num) {
        return (rawWeekly[index] as num).toDouble();
      }
      return 0.0;
    });

    final bool hasData = rawWeekly.any((val) => (val as num? ?? 0) > 0) ||
        burnedKcal != '0' ||
        activeMins != '0';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Weekly Activity",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            hasData
                ? "Your active summary this week"
                : "No workout activity logged yet for this week",
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
                    _statTile("Burned", burnedKcal, "kcal", Colors.orange),
                    _divider(),
                    _statTile("Active", activeMins, "mins", const Color(0xFF2563EB)),
                    _divider(),
                    _statTile("Streak", streakDays, "days", Colors.green),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _dayBar("Mon", weeklyData[0]),
                    _dayBar("Tue", weeklyData[1]),
                    _dayBar("Wed", weeklyData[2]),
                    _dayBar("Thu", weeklyData[3]),
                    _dayBar("Fri", weeklyData[4]),
                    _dayBar("Sat", weeklyData[5]),
                    _dayBar("Sun", weeklyData[6]),
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

  Widget _dayBar(String day, double heightFactor) {
    final bool hasValue = heightFactor > 0;
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
            height: 54 * heightFactor.clamp(0.0, 1.0),
            width: 10,
            decoration: BoxDecoration(
              color: hasValue ? const Color(0xFF2563EB) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: TextStyle(
            fontSize: 10,
            color: hasValue ? const Color(0xFF2563EB) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}