import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../widgets/custom_header.dart';
import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';
import '../models/cart_item.dart';
import 'payments_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = context.watch<UserProvider>().displayName;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(userName: userName),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                children: [
                  Text(
                    'Shopping Cart',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<CartProvider>(
                builder: (context, cart, _) {
                  if (cart.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _buildCartList(context, cart.items, isDark, cart);
                },
              ),
            ),
            Consumer<CartProvider>(
              builder: (context, cart, _) =>
                  _buildCheckoutFooter(context, isDark, cart),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartList(
    BuildContext context,
    List<CartItem> items,
    bool isDark,
    CartProvider cart,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 30),
      itemBuilder: (context, index) {
        final item = items[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isDark ? AppColors.surfaceDark : AppColors.systemGray6,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildCartItemImage(item, isDark),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.brand != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.brand!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Rs.${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quantity controls
                  Row(
                    children: [
                      _qtyButton(
                        icon: Icons.remove,
                        isDark: isDark,
                        onTap: () => cart.decreaseQuantity(item.productId),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _qtyButton(
                        icon: Icons.add,
                        isDark: isDark,
                        onTap: () => cart.increaseQuantity(item),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : Colors.black.withValues(alpha: 0.7),
                  size: 24,
                ),
                onPressed: () => cart.removeItem(item.productId),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCartItemImage(CartItem item, bool isDark) {
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return Image.network(
        item.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _buildSavedImageFallback(item.imageDataUrl, isDark),
      );
    }

    return _buildSavedImageFallback(item.imageDataUrl, isDark);
  }

  Widget _buildSavedImageFallback(String? imageDataUrl, bool isDark) {
    if (imageDataUrl != null && imageDataUrl.isNotEmpty) {
      try {
        final base64Data = imageDataUrl.contains(',')
            ? imageDataUrl.split(',').last
            : imageDataUrl;
        return Image.memory(base64Decode(base64Data), fit: BoxFit.cover);
      } catch (_) {
        return _cartImagePlaceholder(isDark);
      }
    }

    return _cartImagePlaceholder(isDark);
  }

  Widget _cartImagePlaceholder(bool isDark) {
    return Center(
      child: Icon(
        Icons.photo,
        color: isDark ? AppColors.textSecondaryDark : AppColors.systemGray,
        size: 40,
      ),
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.systemGray6,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: AppColors.primaryMaroon),
      ),
    );
  }

  Widget _buildCheckoutFooter(
    BuildContext context,
    bool isDark,
    CartProvider cart,
  ) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        border: isDark
            ? Border.all(color: AppColors.dividerDark, width: 0.5)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              Text(
                'Rs.${cart.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: cart.items.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentsScreen(),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMaroon,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Checkout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
