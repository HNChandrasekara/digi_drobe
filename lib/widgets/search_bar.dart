import 'package:flutter/material.dart';
import '../utils/colors.dart';

class DigiSearchBar extends StatelessWidget {
  final Function(String)? onChanged;

  const DigiSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SearchBar(
        onChanged: onChanged,
        leading: const Icon(Icons.search_rounded, color: AppColors.primaryMaroon),
        hintText: 'Search',
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: const WidgetStatePropertyAll(Colors.white),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        side: WidgetStatePropertyAll(
          BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
      ),
    );
  }
}
