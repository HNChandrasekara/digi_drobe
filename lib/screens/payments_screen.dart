import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../services/payment_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/product_data_service.dart';
import '../services/auth_service.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String selectedMethod = 'PayHere';
  bool _payHereSandbox = true;
  bool _payPalSandbox = true;

  double get _cartTotal {
    final allProducts = ProductDataService.getAllProducts();
    final cartProducts = allProducts.take(3).toList();
    return ProductDataService.calculateCartTotal(cartProducts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildOrderSummary(),
                    const SizedBox(height: 24),
                    // Email/phone inputs removed per request. We will use the account email when available.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount', style: TextStyle(fontSize: 16)),
                        Text(
                          '\$${_cartTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildPaymentMethod('PayHere', Icons.payments_rounded),
                    const SizedBox(height: 12),
                    _buildPaymentMethod(
                      'PayPal',
                      Icons.account_balance_wallet_outlined,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
            ),
          ),
          const Expanded(
            child: Text(
              'Payments',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
            children: const [
              Text(
                'Items (2)',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                'Rs.40,000.00',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Delivery',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                'Free',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              Text(
                'Rs.40,000.00',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8B1D1D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(String title, IconData icon) {
    final bool isSelected = selectedMethod == title;
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = title),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8B1D1D).withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8B1D1D)
                : Colors.black.withOpacity(0.05),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF8B1D1D)
                  : Colors.black.withOpacity(0.6),
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
                      ? const Color(0xFF8B1D1D)
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF8B1D1D),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Processing Payment...')),
            );

            bool success = false;
            // Prefer signed-in user's email if available; otherwise leave empty.
            final email = AuthService().currentUser?.email ?? '';
            final phone = '';

            final orderId = 'ORDER-${DateTime.now().millisecondsSinceEpoch}';
            final amountStr = _cartTotal.toStringAsFixed(2);

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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$selectedMethod payment initiated successfully!',
                  ),
                  backgroundColor: Colors.green,
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
            backgroundColor: const Color(0xFF8B1D1D),
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
