import 'package:flutter/material.dart';

class WelcomeHeader extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const WelcomeHeader({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    final user = userData?['user'] as Map<String, dynamic>? ?? userData ?? {};
    final String username = user['name'] ?? user['username'] ?? 'User';
    final bool isLoggedIn = userData != null && userIdNotEmpty(user);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? "Welcome back, $username 👋" : "Welcome, Guest 👋",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLoggedIn
                      ? "Track your daily nutrition and fitness progress"
                      : "Log in to save your nutrition data",
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : "G",
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool userIdNotEmpty(Map<String, dynamic> user) {
    final id = user['id'] ?? user['_id'];
    return id != null && id.toString().isNotEmpty;
  }
}