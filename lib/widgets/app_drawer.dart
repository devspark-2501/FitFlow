import 'dart:convert';
import 'package:fitflow/screens/auth/login_screen.dart';
import 'package:fitflow/screens/home/home_page.dart';
import 'package:fitflow/screens/planner/planner_page.dart';
import 'package:fitflow/screens/profile/profile_screen.dart';
import 'package:fitflow/screens/timer/timer_page.dart';
import 'package:fitflow/screens/water/water_page.dart';
import 'package:fitflow/screens/workouts/workout_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  final List<Map<String, dynamic>> menuItems = const [
    {"title": "Home", "icon": Icons.home},
    {"title": "Workouts", "icon": Icons.fitness_center},
    {"title": "Timer", "icon": Icons.timer},
    {"title": "Planner", "icon": Icons.calendar_month},
    {"title": "Progress", "icon": Icons.bar_chart},
    {"title": "Water", "icon": Icons.water_drop},
    {"title": "Exercises", "icon": Icons.accessibility_new},
    {"title": "Challenges", "icon": Icons.local_fire_department},
  ];

  void _navigateToScreen(BuildContext context, String title) {
    Navigator.pop(context);

    if (title == "Home") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
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

  Future<void> _navigateToProfile(BuildContext context) async {
    Navigator.pop(context);
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('userData');

    if (!context.mounted) return;

    if (userString != null) {
      final userData = jsonDecode(userString);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(userData: userData),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    Navigator.pop(context);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
    );
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: FutureBuilder<SharedPreferences>(
                future: SharedPreferences.getInstance(),
                builder: (context, snapshot) {
                  final isLoggedIn = snapshot.hasData && snapshot.data!.containsKey('userData');

                  return Column(
                    children: [
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        leading: Icon(Icons.person, color: primary),
                        title: Text(isLoggedIn ? "Profile" : "Login"),
                        onTap: () => _navigateToProfile(context),
                      ),
                      if (isLoggedIn)
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                          title: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
                          onTap: () => _handleLogout(context),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}