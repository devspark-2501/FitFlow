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
    final userMap = userData?['user'] as Map<String, dynamic>? ?? userData ?? {};

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
            // Profile Header Component
            ProfileHeader(userData: userMap),
            const SizedBox(height: 20),

            // Plan Stats Component
            PlanStats(userData: userMap),
            const SizedBox(height: 20),

            // Activity Stats Component
            ActivityStats(userData: userMap),
            const SizedBox(height: 20),

            // My Plans Dashboard Component
            MyPlansDashboard(userData: userMap),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}