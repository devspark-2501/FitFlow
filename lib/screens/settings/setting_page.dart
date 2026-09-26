import 'package:flutter/material.dart';
import 'package:fitflow/screens/auth/login_screen.dart';

class SettingPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const SettingPage({super.key, this.userData});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  bool _workoutReminders = true;
  String _selectedUnit = 'Metric (kg, cm)';

  @override
  Widget build(BuildContext context) {
    final user = widget.userData?['user'] ?? widget.userData;
    final String userName = user?['name'] ?? 'User';
    final String userEmail = user?['email'] ?? 'Not logged in';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Header Section
            _buildProfileCard(userName, userEmail),
            const SizedBox(height: 24),

            // Preferences
            _buildSectionHeader('Preferences'),
            _buildSettingTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              trailing: Switch(
                value: _darkMode,
                activeColor: const Color(0xFF2563EB),
                onChanged: (val) => setState(() => _darkMode = val),
              ),
            ),
            _buildSettingTile(
              icon: Icons.straighten_rounded,
              title: 'Unit System',
              subtitle: _selectedUnit,
              onTap: _showUnitPicker,
            ),

            const SizedBox(height: 24),

            // Notifications
            _buildSectionHeader('Notifications'),
            _buildSettingTile(
              icon: Icons.notifications_none_rounded,
              title: 'Push Notifications',
              trailing: Switch(
                value: _notificationsEnabled,
                activeColor: const Color(0xFF2563EB),
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
            ),
            _buildSettingTile(
              icon: Icons.alarm_rounded,
              title: 'Daily Workout Reminders',
              trailing: Switch(
                value: _workoutReminders,
                activeColor: const Color(0xFF2563EB),
                onChanged: (val) => setState(() => _workoutReminders = val),
              ),
            ),

            const SizedBox(height: 24),

            // Support & About
            _buildSectionHeader('Support & Legal'),
            _buildSettingTile(
              icon: Icons.help_outline_rounded,
              title: 'Help Center & Support',
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.info_outline_rounded,
              title: 'App Version',
              subtitle: '1.0.0',
            ),

            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE2E2),
                  foregroundColor: const Color(0xFFDC2626),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Log Out',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF2563EB),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2563EB)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF0F172A)),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))
            : null,
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)) : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _showUnitPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Unit System', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Metric (kg, cm)'),
                onTap: () {
                  setState(() => _selectedUnit = 'Metric (kg, cm)');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Imperial (lbs, ft)'),
                onTap: () {
                  setState(() => _selectedUnit = 'Imperial (lbs, ft)');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}