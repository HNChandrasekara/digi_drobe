import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../providers/theme_provider.dart';

class DigiSearchBar extends StatefulWidget {
  final Function(String)? onChanged;
  final TextEditingController? controller;

  const DigiSearchBar({super.key, this.onChanged, this.controller});

  @override
  State<DigiSearchBar> createState() => _DigiSearchBarState();
}

class _DigiSearchBarState extends State<DigiSearchBar> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Focus(
        onFocusChange: (focused) {
          setState(() => _isFocused = focused);
        },
        child: SearchBar(
          controller: _controller,
          onChanged: widget.onChanged,
          leading: Icon(Icons.search_rounded, color: AppColors.primaryMaroon),
          trailing: _controller.text.isNotEmpty
              ? [
                  GestureDetector(
                    onTap: () {
                      _controller.clear();
                      widget.onChanged?.call('');
                      setState(() {});
                    },
                    child: Icon(
                      Icons.clear_rounded,
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ]
              : null,
          hintText: 'Search',
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStatePropertyAll(
            isDarkMode ? AppColors.cardDark : Colors.white,
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(
              color: _isFocused
                  ? AppColors.primaryMaroon
                  : (isDarkMode
                        ? AppColors.dividerDark
                        : Colors.black.withValues(alpha: 0.05)),
              width: _isFocused ? 2 : 1,
            ),
          ),
        ),
      ),
    );
  }
}
