import 'package:flutter/material.dart';
import '../utils/colors.dart';

class CustomHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onProfileTap;

  const CustomHeader({super.key, required this.userName, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DigiDrobe',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryMaroon, // Brand color stays the same
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
              Text(
                'Welcome, $userName!',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onProfileTap,
                child: _buildIconButton(Icons.settings_rounded, isDark),
              ),
              const SizedBox(width: 12),
              _buildIconButton(Icons.tune_rounded, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.systemGray6,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isDark ? AppColors.iconColorDark : AppColors.iconColor,
        size: 22,
      ),
    );
  }
}
