import 'package:flutter/material.dart';
import '../utils/colors.dart';

class CustomHeader extends StatelessWidget {
  final String userName;

  const CustomHeader({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.primaryMaroon,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
              Text(
                'Welcome, $userName!',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildIconButton(Icons.person_rounded),
              const SizedBox(width: 12),
              _buildIconButton(Icons.tune_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.systemGray6,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.iconColor, size: 22),
    );
  }
}
