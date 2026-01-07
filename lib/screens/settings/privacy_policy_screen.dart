import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last updated: 2023/06/12',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildContentText(
                      'Your privacy is important to us. At AquaGuard, we are committed to protecting your personal information and providing a safe, enjoyable quiz experience. This Privacy Policy explains what information we collect, how we use it, and the choices you have regarding your data. We may collect personal information such as your name, email, and avatar if you create an account. Additionally, we gather gameplay data including your scores, achievements, progress, and quiz history. We also collect device and usage information such as your device type, operating system, app usage patterns, and crash reports. Optional data, such as location, is collected only if you enable location-based features within the app.'
                    ),
                    const SizedBox(height: 20),
                    _buildContentText(
                      'The information we collect is used to personalize your quiz experience, track your progress and achievements, send notifications or reminders if you opt-in, and improve the app by fixing bugs and analyzing usage trends.'
                    ),
                    const SizedBox(height: 20),
                    _buildContentText(
                      'We do not sell your personal information. However, we may share limited data with trusted third-party service providers who help with cloud storage or analytics. Social features, such as sharing scores or achievements, are used only if you choose to participate.'
                    ),
                  ],
                ),
              ),
            ],
          ),
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
              'Privacy Policy',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A3A),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContentText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: Colors.black.withOpacity(0.7),
        height: 1.6,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
