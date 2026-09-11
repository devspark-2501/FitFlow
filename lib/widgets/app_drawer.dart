import 'package:fitflow/Screens/%20home/home_page.dart';
import 'package:fitflow/screens/%20planner/planner_page.dart';
import 'package:fitflow/screens/%20profile/profile_screen.dart';
// import 'package:fitflow/screens/home/home_page.dart';
// import 'package:fitflow/screens/planner/planner_page.dart';
// import 'package:fitflow/screens/profile/profile_screen.dart'; // Added Profile import
import 'package:fitflow/screens/timer/timer_page.dart';
import 'package:fitflow/screens/water/water_page.dart';
import 'package:fitflow/screens/workouts/workout_page.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final List<Map<String, dynamic>> menuItems = const [
    {
      "title": "Home",
      "icon": Icons.home,
    },
    {
      "title": "Workouts",
      "icon": Icons.fitness_center,
    },
    {
      "title": "Timer",
      "icon": Icons.timer,
    },
    {
      "title": "Planner",
      "icon": Icons.calendar_month,
    },
    {
      "title": "Progress",
      "icon": Icons.bar_chart,
    },
    {
      "title": "Water",
      "icon": Icons.water_drop,
    },
    {
      "title": "Exercises",
      "icon": Icons.accessibility_new,
    },
    {
      "title": "Challenges",
      "icon": Icons.local_fire_department,
    },
  ];

  void _navigateToScreen(BuildContext context, String title) {
    Navigator.pop(context); // Close drawer first

    if (title == "Home") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else if (title == "Workouts") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WorkoutPage()),
      );
    } else if (title == "Timer") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TimerPage()),
      );
    } else if (title == "Planner") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PlannerPage()),
      );
    } else if (title == "Water") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WaterPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary,
                    primary.withOpacity(0.75),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "FITFLOW",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    "Your Fitness Journey",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Navigation Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                children: [
                  ...menuItems.map(
                        (item) {
                      final String title = item["title"];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          leading: Icon(item["icon"], color: primary),
                          title: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => _navigateToScreen(context, title),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(indent: 16, endIndent: 16),

            // Profile & Settings Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    leading: Icon(Icons.person, color: primary),
                    title: const Text("Profile"),
                    onTap: () {
                      Navigator.pop(context); // Close drawer

                      // =========================================================
                      // TEMP PROFILE ROUTE START
                      // (Remove or update once authentication logic is attached)
                      // =========================================================
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                      // =========================================================
                      // TEMP PROFILE ROUTE END
                      // =========================================================
                    },
                  ),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    leading: Icon(Icons.settings, color: primary),
                    title: const Text("Settings"),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}