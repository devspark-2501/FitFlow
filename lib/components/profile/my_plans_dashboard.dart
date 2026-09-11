import 'package:flutter/material.dart';

class MyPlansDashboard extends StatelessWidget {
  const MyPlansDashboard({super.key});

  final List<Map<String, dynamic>> plans = const [
    {
      "title": "Hypertrophy Push-Pull",
      "category": "Workout Plan",
      "duration": "4 Weeks",
      "icon": Icons.fitness_center,
      "color": Color(0xFF38BDF8),
    },
    {
      "title": "High-Protein Keto",
      "category": "Meal Plan",
      "duration": "Daily 2,400 kcal",
      "icon": Icons.restaurant,
      "color": Color(0xFF4ADE80),
    },
    {
      "title": "5K Endurance Run",
      "category": "Cardio Plan",
      "duration": "3 Days/Wk",
      "icon": Icons.directions_run,
      "color": Color(0xFFF97316),
    },
    {
      "title": "Gallon Hydration",
      "category": "Water Plan",
      "duration": "3.8 L / Day",
      "icon": Icons.water_drop,
      "color": Color(0xFF06B6D4),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "My Active Plans",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Explore Plans",
                style: TextStyle(color: Color(0xFF38BDF8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: plans.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final plan = plans[index];
            final Color planColor = plan['color'];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: planColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(plan['icon'], color: planColor, size: 22),
                      ),
                      Icon(Icons.bookmark_added, color: planColor, size: 20),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan['title'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${plan['category']} • ${plan['duration']}",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}