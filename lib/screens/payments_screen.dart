import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../services/payment_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../models/order.dart' as app_order;
import '../services/order_service.dart';
import 'billing_paid_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String selectedMethod = 'PayHere';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildOrderSummary(isDark, cart.itemCount, cart.total),
                    const SizedBox(height: 24),
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildPaymentMethod(
                      'PayHere',
                      Icons.payments_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentMethod(
                      'PayPal',
                      Icons.account_balance_wallet_outlined,
                      isDark,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildFooter(isDark, cart),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              'Payments',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(bool isDark, int itemCount, double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.dividerDark
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items ($itemCount)',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              Text(
                'Rs.${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              const Text(
                'Free',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: isDark ? AppColors.dividerDark : null),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                'Rs.${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryMaroon,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(String title, IconData icon, bool isDark) {
    final bool isSelected = selectedMethod == title;
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = title),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryMaroon.withValues(alpha: 0.05)
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryMaroon
                : (isDark
                      ? AppColors.dividerDark
                      : Colors.black.withValues(alpha: 0.05)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryMaroon
                  : (isDark
                        ? AppColors.textSecondaryDark
                        : Colors.black.withValues(alpha: 0.6)),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primaryMaroon
                      : (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryMaroon,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDark, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.dividerDark
                : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () async {
            if (cart.items.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Your cart is empty')),
              );
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Processing Payment...')),
            );

            bool success = false;
            // Prefer signed-in user's email if available; otherwise leave empty.
            final email = AuthService().currentUser?.email ?? '';
            final phone = '';

            final orderId = 'ORDER-${DateTime.now().millisecondsSinceEpoch}';
            final amountStr = cart.total.toStringAsFixed(2);
            final itemsSnapshot = cart.items
                .map(
                  (item) => CartItem(
                    productId: item.productId,
                    title: item.title,
                    brand: item.brand,
                    imageUrl: item.imageUrl,
                    imageDataUrl: item.imageDataUrl,
                    price: item.price,
                    quantity: item.quantity,
                  ),
                )
                .toList();
            final totalSnapshot = cart.total;

            if (selectedMethod == 'PayHere') {
              final redirectUrl = await PaymentService.processPayHerePayment(
                amount: amountStr,
                orderId: orderId,
                customerEmail: email,
                customerPhone: phone,
              );

              if (redirectUrl != null) {
                // Open the PayHere checkout in a new tab/window
                final uri = Uri.parse(redirectUrl);
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                  return;
                } catch (e) {
                  // fallback: show success message and log URL
                  print('[PaymentsScreen] Failed to launch URL: $e');
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Open this URL to complete payment: $redirectUrl',
                      ),
                    ),
                  );
                  return;
                }
              } else {
                success = false;
              }
            } else if (selectedMethod == 'PayPal') {
              success = await PaymentService.processPayPalPayment(
                amount: amountStr,
                orderId: orderId,
                customerEmail: email,
              );
            }

            if (!mounted) return;

            if (success) {
              final user = AuthService().currentUser;
              final billingOrder = app_order.Order(
                id: orderId,
                userId: user?.uid ?? 'unknown',
                items: itemsSnapshot,
                total: totalSnapshot,
                status: 'paid',
                paymentMethod: selectedMethod,
                createdAt: DateTime.now(),
              );

              try {
                await OrderService().placeOrder(billingOrder);
                await cart.clearCart();
              } catch (e) {
                debugPrint('[PaymentsScreen] Could not save paid order: $e');
              }

              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BillingPaidScreen(
                    orderId: orderId,
                    paymentMethod: selectedMethod,
                    total: totalSnapshot,
                    items: itemsSnapshot,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$selectedMethod payment failed. Please try again.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryMaroon,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Pay Now',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
