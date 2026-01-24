import 'package:flutter/material.dart';
import '../utils/colors.dart';

class DigiSearchBar extends StatelessWidget {
  final Function(String)? onChanged;

  const DigiSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(color: AppColors.systemGray, fontSize: 15),
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryMaroon, size: 22),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ),
    );
  }
}
