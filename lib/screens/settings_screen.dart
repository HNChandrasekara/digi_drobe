import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../utils/colors.dart';
import 'settings/app_preference_screen.dart';
import 'settings/privacy_policy_screen.dart';
import 'settings/help_support_screen.dart';
import 'settings/about_screen.dart';
import 'settings/logout_screen.dart';
import 'settings/profile_settings_screen.dart';
import '../services/auth_service.dart';
import '../services/avatar_service.dart';
import '../services/sound_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AuthService _authService;
  String _displayName = '';
  String _displayEmail = '';

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      setState(() {
        _displayName = currentUser.displayName ?? '';
        _displayEmail = currentUser.email ?? '';
      });
    }
  }

  void _onLogout() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A3A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 30),
              _buildProfileCard(_displayName, _displayEmail),
              const SizedBox(height: 30),
              _buildSettingItem(
                context,
                Icons.person_outline_rounded,
                'Profile Settings',
                const ProfileSettingsScreen(),
              ),
              const SizedBox(height: 16),
              _buildSettingItem(
                context,
                Icons.grid_view_rounded,
                'App Preferences',
                const AppPreferenceScreen(),
              ),
              const SizedBox(height: 16),
              _buildGroupedSettings(context),
              const SizedBox(height: 16),
              _buildSettingItem(
                context,
                Icons.logout_rounded,
                'Log out',
                LogoutScreen(authService: _authService, onLogout: _onLogout),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(String displayName, String displayEmail) {
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
            FutureBuilder<Uint8List?>(
              future: AvatarService.loadAvatar(),
              builder: (context, snap) {
                final bytes = snap.data;
                return Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: bytes != null
                            ? Image.memory(
                                bytes,
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                              )
                            : const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
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
                );
              },
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayEmail,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
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
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: destination != null
            ? () async {
                await SoundService.playClick();
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => destination),
                );
                // If we returned from Profile Settings, reload user details
                if (destination is ProfileSettingsScreen) {
                  await _loadUserDetails();
                }
              }
            : null,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
          ),
          child: _buildItemRow(icon, title),
        ),
      ),
    );
  }

  Widget _buildItemRow(
    IconData icon,
    String title, {
    bool hasDivider = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.black.withOpacity(0.3),
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
              color: Colors.black.withOpacity(0.1),
            ),
        ],
      ),
    );
  }

  Widget _buildGroupedSettings(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
        ),
        child: Column(
          children: [
            _buildItemRow(
              Icons.security_rounded,
              'Privacy Policy',
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
