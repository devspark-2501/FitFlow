import 'package:fitflow/screens/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';

class SettingsProfileSection extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final Function(Map<String, dynamic> updatedUser) onProfileUpdated;

  const SettingsProfileSection({
    super.key,
    this.userData,
    required this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final user = userData?['user'] ?? userData ?? {};
    final String name = user['name'] ?? 'User';
    final String email = user['email'] ?? 'Not Logged In';
    final String bio = user['bio'] ?? 'No bio added yet.';
    final String? avatarUrl = user['avatarUrl'];

    final int followers = (user['followers'] as List?)?.length ?? 0;
    final int purchases = (user['purchases'] as List?)?.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF2563EB),
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(email, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditProfileScreen(userData: userData)),
                  );
                  if (result != null) {
                    onProfileUpdated(result);
                  }
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(bio, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('Following', '$followers'),
              Container(height: 20, width: 1, color: const Color(0xFFE2E8F0)),
              _buildMetric('Purchases', '$purchases'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      ],
    );
  }
}