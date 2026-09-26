import 'package:fitflow/components/settings/logout_dialog.dart';
import 'package:fitflow/components/settings/profile_section.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const SettingPage({super.key, this.userData});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  Map<String, dynamic>? _currentUserData;

  @override
  void initState() {
    super.initState();
    _currentUserData = widget.userData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile & Purchases Info Component
            SettingsProfileSection(
              userData: _currentUserData,
              onProfileUpdated: (updatedUser) {
                setState(() {
                  _currentUserData = updatedUser;
                });
              },
            ),
            const SizedBox(height: 24),

            // Logout & Exit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => LogoutDialog.show(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE2E2),
                  foregroundColor: const Color(0xFFDC2626),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Log Out & Switch Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}