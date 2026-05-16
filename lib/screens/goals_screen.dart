import 'package:flutter/material.dart';
import '../utils/colors.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Our Master Plan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 32),
            _buildGoalCard(
              title: "Save the Planet",
              subtitle:
                  "Because 'Naked' is technically sustainable, but not very office-appropriate.",
              icon: Icons.public_rounded,
              color: Colors.green,
              isDark: isDark,
            ),
            _buildGoalCard(
              title: "End Morning Drama",
              subtitle:
                  "Stop the 20-minute floor-staring session where you claim you have 'nothing to wear'.",
              icon: Icons.sentiment_very_dissatisfied_rounded,
              color: Colors.orange,
              isDark: isDark,
            ),
            _buildGoalCard(
              title: "AI Overlords (Friendly ones)",
              subtitle:
                  "Make our AI smarter than your ex, and much better at picking shoes.",
              icon: Icons.psychology_rounded,
              color: Colors.purple,
              isDark: isDark,
            ),
            _buildGoalCard(
              title: "Stylemate Superiority",
              subtitle:
                  "Prove to the world that looking good is 90% confidence and 10% not wearing socks with sandals.",
              icon: Icons.auto_awesome_rounded,
              color: AppColors.primaryMaroon,
              isDark: isDark,
            ),
            _buildGoalCard(
              title: "Fit-Check Confidence",
              subtitle:
                  "Because 'does this look okay?' shouldn't require a 3-person committee and a psychic.",
              icon: Icons.check_circle_outline_rounded,
              color: Colors.blue,
              isDark: isDark,
            ),
            _buildGoalCard(
              title: "Sustainability Hero",
              subtitle:
                  "Reduce textile waste by helping you love and wear what you already own.",
              icon: Icons.eco_rounded,
              color: Colors.teal,
              isDark: isDark,
            ),
            _buildGoalCard(
              title: "Wardrobe Analytics",
              subtitle:
                  "Finally understand why you own 12 white t-shirts but only wear the one from 2018.",
              icon: Icons.analytics_rounded,
              color: Colors.amber,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                "Disclaimer: No pixels were harmed in the making of this app.",
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "World Domination?",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "No, just helping you look fabulous. But maybe world domination later. We'll see.",
          style: TextStyle(
            fontSize: 16,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
