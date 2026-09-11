import 'package:flutter/material.dart';
import '../../components/profile/profile_header.dart';
import '../../components/profile/activity_stats.dart';
import '../../components/profile/plan_stats.dart';
import '../../components/profile/my_plans_dashboard.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ProfileScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    final name = userData?['name'] ?? 'Tanush Mathur';
    final email = userData?['email'] ?? 'tanush@fitflow.app';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('My Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          children: [
            ProfileHeader(name: name, email: email),
            const SizedBox(height: 24),
            const PlanStats(),
            const SizedBox(height: 20),
            const ActivityStats(),
            const SizedBox(height: 28),
            const MyPlansDashboard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}