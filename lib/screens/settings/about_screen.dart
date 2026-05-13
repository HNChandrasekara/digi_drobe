import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                   const Text(
                    'Welcome to DigiDrobe, the ultimate digital wardrobe companion that brings your closet to life! Our mission is to simplify fashion, promote sustainability, and help you look your best every single day.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'We aim to provide a seamless, AI-powered experience where you can organize your clothes, plan outfits, and discover your unique style. Thank you for choosing DigiDrobe - let\'s redefine your wardrobe together!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
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
              'About us',
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
            _buildSocialIcon(Icons.close),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Icon(icon, size: 20, color: Colors.black.withOpacity(0.7));
  }
}
