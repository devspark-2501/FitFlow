import 'package:flutter/material.dart';

class WelcomeSection extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback onActionTap;

  const WelcomeSection({
    super.key,
    this.userData,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = userData?['user'] ?? userData;
    final bool isLoggedIn = user != null;
    final String name = isLoggedIn ? (user['name'] ?? 'Athlete') : 'Guest';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2563EB).withOpacity(0.08),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDBEAFE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2563EB).withOpacity(0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isLoggedIn ? "WELCOME BACK" : "FITFLOW JOURNEY",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isLoggedIn ? "Good Day, $name 👋" : "Welcome, Friend 👋",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isLoggedIn
                    ? "Ready to crush your workout goals today?"
                    : "Sign in to track your progress and build your streak!",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              if (!isLoggedIn) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: onActionTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Get Started / Sign In",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}