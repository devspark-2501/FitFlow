import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitflow/screens/home/home_page.dart';
import '../../components/profile/profile_header.dart';
import '../../components/profile/activity_stats.dart';
import '../../components/profile/plan_stats.dart';
import '../../components/profile/my_plans_dashboard.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ProfileScreen({super.key, this.userData});

  Future<void> _handleLogout(BuildContext context) async {
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
    final user = userData?['user'] ?? userData;
    final String name = user?['name'] ?? 'User';
    final String email = user?['email'] ?? 'No email provided';
    final Map<String, dynamic>? planStats = user?['planStats'];
    final Map<String, dynamic>? activity = user?['activityStats'];
    final List<dynamic>? plans = user?['plans'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Log Out',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            ProfileHeader(name: name, email: email),
            const SizedBox(height: 20),
            PlanStats(stats: planStats),
            const SizedBox(height: 16),
            ActivityStats(activity: activity),
            const SizedBox(height: 24),
            MyPlansDashboard(userPlans: plans),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}