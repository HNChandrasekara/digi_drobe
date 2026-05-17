import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/order.dart' as app_order;
import '../services/auth_service.dart';
import '../services/order_service.dart';

enum PaymentMethod { payHere, payPal }

enum PaymentResultStatus { success, failed, cancelled }

class PaymentResult {
  final PaymentResultStatus status;
  final String message;
  final String? orderId;
  final String? paymentId;

  const PaymentResult({
    required this.status,
    required this.message,
    this.orderId,
    this.paymentId,
  });
}

class CustomerDetails {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;

  const CustomerDetails({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    this.country = 'Sri Lanka',
  });
}

class PaymentProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  PaymentMethod? _selectedMethod = PaymentMethod.payHere;
  bool _isProcessing = false;

  PaymentMethod? get selectedMethod => _selectedMethod;
  bool get isProcessing => _isProcessing;
  bool get canPay => _selectedMethod != null && !_isProcessing;

  void reset({PaymentMethod method = PaymentMethod.payHere}) {
    _selectedMethod = method;
    _isProcessing = false;
    notifyListeners();
  }

  void selectMethod(PaymentMethod method) {
    if (_isProcessing) return;
    _selectedMethod = method;
    notifyListeners();
  }

  Future<PaymentResult> pay({
    required List<CartItem> items,
    required double total,
    required CustomerDetails customer,
  }) async {
    if (_selectedMethod == null) {
      return const PaymentResult(
        status: PaymentResultStatus.failed,
        message: 'Select a payment method first',
      );
    }

    if (items.isEmpty || total <= 0) {
      return const PaymentResult(
        status: PaymentResultStatus.failed,
        message: 'Your cart is empty',
      );
    }

    _isProcessing = true;
    notifyListeners();

    final orderId = 'ORDER-${DateTime.now().millisecondsSinceEpoch}';

    try {
      if (_selectedMethod == PaymentMethod.payHere) {
        final paymentId = 'MOCK-PAYHERE-${DateTime.now().millisecondsSinceEpoch}';

        await _savePaidOrder(
          orderId: orderId,
          items: items,
          total: total,
          method: 'PayHere Mock',
          paymentId: paymentId,
        );

        return PaymentResult(
          status: PaymentResultStatus.success,
          message: 'Mock PayHere payment completed',
          orderId: orderId,
          paymentId: paymentId,
        );
      }

      final paymentId = 'MOCK-PAYPAL-${DateTime.now().millisecondsSinceEpoch}';

      await _savePaidOrder(
        orderId: orderId,
        items: items,
        total: total,
        method: 'PayPal',
        paymentId: paymentId,
      );

      return PaymentResult(
        status: PaymentResultStatus.success,
        message: 'Mock PayPal payment completed',
        orderId: orderId,
        paymentId: paymentId,
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      final isCancelled = message.toLowerCase().contains('cancel');
      return PaymentResult(
        status: isCancelled
            ? PaymentResultStatus.cancelled
            : PaymentResultStatus.failed,
        message: message,
        orderId: orderId,
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> _savePaidOrder({
    required String orderId,
    required List<CartItem> items,
    required double total,
    required String method,
    String? paymentId,
  }) async {
    final auth = AuthService();
    final user = auth.currentUser;

    if (auth.isMockMode || user == null) {
      debugPrint(
        'PaymentProvider: Mock paid order saved locally: $orderId, total=$total',
      );
      return;
    }

    final order = app_order.Order(
      id: orderId,
      userId: user.uid,
      items: items,
      total: total,
      status: 'Paid',
      paymentMethod: paymentId == null ? method : '$method #$paymentId',
      createdAt: DateTime.now(),
    );

    await _orderService.placeOrder(order);
  }

  Future<void> savePaidPayHereOrder({
    required String orderId,
    required List<CartItem> items,
    required double total,
    String? paymentId,
  }) {
    return _savePaidOrder(
      orderId: orderId,
      items: items,
      total: total,
      method: 'PayHere',
      paymentId: paymentId,
    );
  }
}
