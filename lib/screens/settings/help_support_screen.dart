import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 30),
            _buildActionItem(Icons.edit_note_rounded, 'FAQ'),
            const SizedBox(height: 16),
            _buildActionItem(Icons.description_outlined, 'Digitisation Guide'),
            const SizedBox(height: 16),
            _buildActionItem(Icons.chat_bubble_outline_rounded, 'Chat with Us'),
            const Spacer(),
            _buildFooter(),
            const SizedBox(height: 40),
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
              'Help & Support',
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

  Widget _buildActionItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black.withValues(alpha: 0.6), size: 22),
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
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.black.withValues(alpha: 0.3), size: 16),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.black.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, size: 18, color: Colors.black87),
            const SizedBox(width: 8),
            const Text(
              'support@digidrobe.com',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(Icons.facebook),
            const SizedBox(width: 20),
            _buildSocialIcon(Icons.camera_alt_outlined),
            const SizedBox(width: 20),
            _buildSocialIcon(Icons.play_circle_outline),
            const SizedBox(width: 20),
            _buildSocialIcon(Icons.close), // For X/Twitter
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Icon(icon, size: 20, color: Colors.black.withValues(alpha: 0.7));
  }
}
