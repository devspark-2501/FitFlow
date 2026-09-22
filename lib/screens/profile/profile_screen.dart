import 'package:flutter/material.dart';
import 'package:fitflow/components/profile/activity_stats.dart';
import 'package:fitflow/components/profile/my_plans_dashboard.dart';
import 'package:fitflow/components/profile/plan_stats.dart';
import 'package:fitflow/components/profile/profile_header.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ProfileScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    // Extract user dynamic values or fall back to defaults
    final userMap = userData?['user'] as Map<String, dynamic>? ?? userData ?? {};
    final String userName = userMap['name'] ?? 'User';
    final String userEmail = userMap['email'] ?? 'No email available';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pass required parameters here
            ProfileHeader(
              name: userName,
              email: userEmail,
            ),
            const SizedBox(height: 20),

            PlanStats(),
            const SizedBox(height: 20),

            ActivityStats(),
            const SizedBox(height: 20),

            MyPlansDashboard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}