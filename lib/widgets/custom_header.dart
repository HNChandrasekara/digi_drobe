import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../providers/cart_provider.dart';
import '../screens/cart_screen.dart';

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
                  color: AppColors.primaryMaroon,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
              Text(
                'Welcome, $userName!',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Consumer<CartProvider>(
                builder: (context, cart, _) {
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartScreen(),
                            ),
                          );
                        },
                        child: _buildIconButton(
                          Icons.shopping_cart_rounded,
                          isDark,
                        ),
                      ),
                      if (cart.itemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryMaroon,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${cart.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onProfileTap,
                child: _buildIconButton(Icons.settings_rounded, isDark),
              ),
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
