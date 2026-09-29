import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitflow/components/profile/activity_stats.dart';
import 'package:fitflow/components/profile/my_plans_dashboard.dart';
import 'package:fitflow/components/profile/plan_stats.dart';
import 'package:fitflow/components/profile/profile_header.dart';
import 'package:fitflow/screens/profile/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ProfileScreen({super.key, this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _currentUserData;

  @override
  void initState() {
    super.initState();
    _currentUserData = widget.userData;
    _loadStoredUserData();
  }

  // Fetch the latest updated user data from SharedPreferences
  Future<void> _loadStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('userData');

    if (userString != null) {
      if (mounted) {
        setState(() {
          _currentUserData = jsonDecode(userString);
        });
      }
    }
  }

  // Helper to safely extract the user object nested in MongoDB response
  Map<String, dynamic> _getFormattedUserMap() {
    if (_currentUserData == null) return {};
    if (_currentUserData!.containsKey('user') &&
        _currentUserData!['user'] is Map<String, dynamic>) {
      return _currentUserData!['user'] as Map<String, dynamic>;
    }
    return _currentUserData!;
  }

  // Navigate to EditProfileScreen and reload data upon return
  Future<void> _navigateToEditProfile() async {
    final updatedResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userData: _currentUserData),
      ),
    );

    if (updatedResult != null) {
      await _loadStoredUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userMap = _getFormattedUserMap();
    final String userName = userMap['name'] ?? 'User';
    final String userEmail = userMap['email'] ?? 'No email available';
    final String? avatarUrl = userMap['avatarUrl'];
    final String? bio = userMap['bio'];

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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF2563EB)),
            tooltip: 'Edit Profile',
            onPressed: _navigateToEditProfile,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStoredUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(
                name: userName,
                email: userEmail,
                avatarUrl: avatarUrl,
                bio: bio,
              ),
              const SizedBox(height: 20),

              const PlanStats(),
              const SizedBox(height: 20),

              const ActivityStats(),
              const SizedBox(height: 20),

              const MyPlansDashboard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}