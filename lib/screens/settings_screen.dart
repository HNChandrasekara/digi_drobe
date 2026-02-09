import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../services/auth_service.dart';
import 'settings/profile_settings_screen.dart';
import 'settings/app_preference_screen.dart';
import 'settings/logout_screen.dart';
import 'settings/privacy_policy_screen.dart';
import 'settings/help_support_screen.dart';
import 'settings/about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();

  void _onLogout() {
    // Navigate to login screen or restart app flow
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1A1A3A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 30),
              _buildProfileCard(),
              const SizedBox(height: 30),
              _buildSettingItem(
                context,
                Icons.person_outline_rounded,
                'Profile Settings',
                const ProfileSettingsScreen(),
                isDark,
              ),
              const SizedBox(height: 16),
              _buildSettingItem(
                context,
                Icons.grid_view_rounded,
                'App Preferences',
                const AppPreferenceScreen(),
                isDark,
              ),
              const SizedBox(height: 16),
              _buildGroupedSettings(context, isDark),
              const SizedBox(height: 16),
              _buildSettingItem(
                context,
                Icons.logout_rounded,
                'Log out',
                LogoutScreen(authService: _authService, onLogout: _onLogout),
                isDark,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF8B1D1D),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B1D1D).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'DigiDrobe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'hirushie9@gmail.com',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget? destination,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: destination != null
            ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destination),
              )
            : null,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.dividerDark
                  : Colors.black.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: _buildItemRow(icon, title, isDark: isDark),
        ),
      ),
    );
  }

  Widget _buildItemRow(
    IconData icon,
    String title, {
    bool hasDivider = false,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : Colors.black.withOpacity(0.6),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textPrimaryDark : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : Colors.black.withOpacity(0.3),
                  size: 16,
                ),
              ],
            ),
          ),
          if (hasDivider)
            Divider(
              height: 1,
              indent: 56,
              endIndent: 20,
              color: isDark
                  ? AppColors.dividerDark
                  : Colors.black.withOpacity(0.1),
            ),
        ],
      ),
    );
  }

  Widget _buildGroupedSettings(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.dividerDark
                : Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            _buildItemRow(
              Icons.security_rounded,
              'Privacy Policy',
              isDark: isDark,
              hasDivider: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              ),
            ),
            _buildItemRow(
              Icons.headset_mic_outlined,
              'Help & Support',
              isDark: isDark,
              hasDivider: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              ),
            ),
            _buildItemRow(
              Icons.info_outline_rounded,
              'About',
              isDark: isDark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
