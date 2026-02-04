import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../providers/theme_provider.dart';

class AppPreferenceScreen extends StatefulWidget {
  const AppPreferenceScreen({super.key});

  @override
  State<AppPreferenceScreen> createState() => _AppPreferenceScreenState();
}

class _AppPreferenceScreenState extends State<AppPreferenceScreen> {
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  final List<String> _languages = ['English', 'Sinhala', 'Tamil'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 40),
              _buildThemeSection(),
              const SizedBox(height: 16),
              _buildNotificationSection(),
              const SizedBox(height: 16),
              _buildLanguageSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.brush_outlined,
                  color: Colors.black.withOpacity(0.6),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Theme & Appearance',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleDarkMode(value);
                  },
                  activeColor: const Color(0xFF8B1D1D),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            _buildToggleItem(
              icon: Icons.volume_up_outlined,
              title: 'Sound',
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
              hasDivider: true,
            ),
            _buildToggleItem(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool hasDivider = false,
  }) {
    return Column(
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
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF8B1D1D),
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
    );
  }

  Widget _buildLanguageSection() {
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
            Icon(
              Icons.translate_rounded,
              color: Colors.black.withOpacity(0.6),
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Language & Accessibility',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedLanguage,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              initialValue: _selectedLanguage,
              onSelected: (String lang) {
                setState(() {
                  _selectedLanguage = lang;
                });
              },
              itemBuilder: (BuildContext context) => _languages
                  .map(
                    (String lang) =>
                        PopupMenuItem<String>(value: lang, child: Text(lang)),
                  )
                  .toList(),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black.withOpacity(0.3),
                size: 16,
              ),
            ),
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A3A),
            ),
          ),
          const Expanded(
            child: Text(
              'App Preference',
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

  @override
  void dispose() {
    super.dispose();
  }
}
