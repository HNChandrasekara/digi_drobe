import 'package:flutter/material.dart';
import '../utils/colors.dart';

class DigiSearchBar extends StatelessWidget {
  const DigiSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.systemGray6,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Search for clothes, styles...',
            hintStyle: TextStyle(color: AppColors.systemGray, fontSize: 15),
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.systemGray, size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }
}
