import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/payment_provider.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    final displayName = user?.displayName?.trim() ?? '';
    final parts = displayName.split(RegExp(r'\s+'));

    _firstNameCtrl = TextEditingController(
      text: parts.isNotEmpty && parts.first.isNotEmpty ? parts.first : 'Digi',
    );
    _lastNameCtrl = TextEditingController(
      text: parts.length > 1 ? parts.skip(1).join(' ') : 'Drobe',
    );
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController(text: '0771234567');
    _addressCtrl = TextEditingController(text: 'No. 1, Galle Road');
    _cityCtrl = TextEditingController(text: 'Colombo');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PaymentProvider>().reset();
      }
    });
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();
    final payment = context.watch<PaymentProvider>();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Payments'), centerTitle: true),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            children: [
              _summaryCard(cart, isDark),
              const SizedBox(height: 24),
              _sectionTitle('Billing Details', isDark),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _field('First name', _firstNameCtrl, isDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Last name', _lastNameCtrl, isDark)),
                ],
              ),
              const SizedBox(height: 12),
              _field(
                'Email',
                _emailCtrl,
                isDark,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _field(
                'Phone',
                _phoneCtrl,
                isDark,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _field('Address', _addressCtrl, isDark),
              const SizedBox(height: 12),
              _field('City', _cityCtrl, isDark),
              const SizedBox(height: 24),
              _sectionTitle('Payment Method', isDark),
              const SizedBox(height: 12),
              _paymentTile(
                title: 'PayHere',
                icon: Icons.payments_rounded,
                method: PaymentMethod.payHere,
                payment: payment,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _paymentTile(
                title: 'PayPal',
                icon: Icons.account_balance_wallet_outlined,
                method: PaymentMethod.payPal,
                payment: payment,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: payment.selectedMethod != null && cart.items.isNotEmpty
                  ? () => _pay(payment)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMaroon,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.systemGray2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Pay Now',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(CartProvider cart, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _summaryRow('Items (${cart.itemCount})', cart.total, isDark),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery', style: _mutedStyle(isDark)),
              const Text(
                'Free',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          _summaryRow('Total', cart.total, isDark, isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    double value,
    bool isDark, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                )
              : _mutedStyle(isDark),
        ),
        Text(
          'Rs.${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            color: isTotal ? AppColors.primaryMaroon : null,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    bool isDark, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? AppColors.cardDark : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Required' : null,
    );
  }

  Widget _paymentTile({
    required String title,
    required IconData icon,
    required PaymentMethod method,
    required PaymentProvider payment,
    required bool isDark,
  }) {
    final selected = payment.selectedMethod == method;
    return Material(
      color: selected
          ? AppColors.primaryMaroon.withValues(alpha: 0.06)
          : (isDark ? AppColors.cardDark : Colors.white),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: payment.isProcessing ? null : () => payment.selectMethod(method),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? AppColors.primaryMaroon
                  : Colors.black.withValues(alpha: 0.05),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? AppColors.primaryMaroon : null),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: selected ? AppColors.primaryMaroon : null,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryMaroon,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _pay(PaymentProvider payment) {
    if (!_formKey.currentState!.validate()) return;

    if (payment.selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a payment method first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment successful!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  TextStyle _mutedStyle(bool isDark) {
    return TextStyle(
      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      fontWeight: FontWeight.w700,
    );
  }
}
