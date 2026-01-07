import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class AppPreferenceScreen extends StatelessWidget {
  const AppPreferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 40),
            _buildPreferenceItem(Icons.brush_outlined, 'Theme & Appearance'),
            const SizedBox(height: 16),
            _buildPreferenceItem(Icons.notifications_none_rounded, 'Sound & Notifications'),
            const SizedBox(height: 16),
            _buildPreferenceItem(Icons.translate_rounded, 'Language & Accessibility'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A3A)),
          ),
          const Expanded(
            child: Text(
              'App Preference',
              textAlign: Alignment.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A3A),
              ),
            ),
          ),
          const SizedBox(width: 48), // Spacer for centering
        ],
      ),
    );
  }

  Widget _buildPreferenceItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black.withOpacity(0.6), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.black.withOpacity(0.3), size: 16),
          ],
        ),
      ),
    );
  }
}
