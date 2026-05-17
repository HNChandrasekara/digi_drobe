import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import '../models/cart_item.dart';

class PaymentService {
  // PayHere Configuration
  static const String _payHereSandboxUrl =
      'https://sandbox.payhere.lk/api/v2'; // Sandbox URL
  static const String _payHereProductionUrl =
      'https://api.payhere.lk/api/v2'; // Production URL
  static const String _payHereMerchantId = '1235807';
  static const String _payHereMerchantSecret =
      'MTA0MDY3ODIyNjE2NTk1NzE3NzEzNDg0MTkwNTM3ODE3NzEyMzc=';
  static bool _payHereUseSandbox = true; // Toggle for sandbox/production
  static const String _payHereNotifyUrl =
      'https://digi-drobe.com/payment/notify';
  static const String payHereSuccessUrl =
      'https://digi-drobe.com/payment/success';
  static const String payHereCancelUrl =
      'https://digi-drobe.com/payment/cancel';

  static String get payHereCheckoutBaseUrl => _payHereUseSandbox
      ? 'https://sandbox.payhere.lk/pay/checkout'
      : 'https://www.payhere.lk/pay/checkout';

  // PayPal Configuration
  static const String _payPalSandboxUrl =
      'https://api.sandbox.paypal.com'; // Sandbox URL
  static const String _payPalProductionUrl =
      'https://api.paypal.com'; // Production URL
  static const String _payPalClientId = 'YOUR_PAYPAL_CLIENT_ID';
  static const String _payPalSecret = 'YOUR_PAYPAL_CLIENT_SECRET';
  static bool _payPalUseSandbox = true; // Toggle for sandbox/production

  /// Process PayHere Payment - Constructs direct checkout URL (no API call needed)
  static Future<String?> processPayHerePayment({
    required String amount,
    required String orderId,
    required String customerEmail,
    required String customerPhone,
    String firstName = 'Customer',
    String lastName = 'Name',
    String address = 'No. 1, Galle Road',
    String city = 'Colombo',
    String country = 'Sri Lanka',
    String items = 'Fashion Items',
  }) async {
    // In mock mode return a fake sandbox checkout URL
    if (_payHereMerchantId.contains('YOUR_') ||
        _payHereMerchantSecret.contains('YOUR_')) {
      print('[PaymentService] PayHere: Mock mode - Would process payment');
      print('[PaymentService] PayHere: Amount: $amount, Order: $orderId');
      return 'https://sandbox.payhere.lk/pay/$orderId';
    }

    try {
      final hash = _generatePayHereHash(
        orderId: orderId,
        amount: amount,
        currency: 'LKR',
      );

      final base = _payHereUseSandbox
          ? 'https://sandbox.payhere.lk'
          : 'https://www.payhere.lk';

      // PayHere hosted checkout URL - correct endpoint
      final checkoutUrl =
          '$base/pay/checkout?merchant_id=$_payHereMerchantId&return_url=${Uri.encodeComponent(payHereSuccessUrl)}&cancel_url=${Uri.encodeComponent(payHereCancelUrl)}&notify_url=${Uri.encodeComponent(_payHereNotifyUrl)}&order_id=$orderId&items=${Uri.encodeComponent(items)}&amount=$amount&currency=LKR&first_name=${Uri.encodeComponent(firstName)}&last_name=${Uri.encodeComponent(lastName)}&email=${Uri.encodeComponent(customerEmail)}&phone=${Uri.encodeComponent(customerPhone)}&address=${Uri.encodeComponent(address)}&city=${Uri.encodeComponent(city)}&country=${Uri.encodeComponent(country)}&hash=$hash';

      print('[PaymentService] PayHere checkout URL: $checkoutUrl');
      return checkoutUrl;
    } catch (e) {
      print('[PaymentService] PayHere error: $e');
      return null;
    }
  }

  static Map<String, String> buildPayHereFormFields({
    required String amount,
    required String orderId,
    required String customerEmail,
    required String customerPhone,
    required String firstName,
    required String lastName,
    required String address,
    required String city,
    required String country,
    required String items,
  }) {
    final normalizedAmount = double.parse(amount).toStringAsFixed(2);
    final hash = _generatePayHereHash(
      orderId: orderId,
      amount: normalizedAmount,
      currency: 'LKR',
    );

    return {
      'merchant_id': _payHereMerchantId,
      'return_url': payHereSuccessUrl,
      'cancel_url': payHereCancelUrl,
      'notify_url': _payHereNotifyUrl,
      'order_id': orderId,
      'items': items,
      'amount': normalizedAmount,
      'currency': 'LKR',
      'first_name': firstName,
      'last_name': lastName,
      'email': customerEmail,
      'phone': customerPhone,
      'address': address,
      'city': city,
      'country': country,
      'hash': hash,
    };
  }

  static String _generatePayHereHash({
    required String orderId,
    required String amount,
    required String currency,
  }) {
    final hashedSecret = md5
        .convert(utf8.encode(_payHereMerchantSecret))
        .toString()
        .toUpperCase();

    return md5
        .convert(
          utf8.encode(
            '$_payHereMerchantId$orderId$amount$currency$hashedSecret',
          ),
        )
        .toString()
        .toUpperCase();
  }

  /// Process PayHere payment through the official in-app Flutter SDK.
  static Future<String> processPayHereSdkPayment({
    required double amount,
    required String orderId,
    required List<CartItem> items,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String city,
    String country = 'Sri Lanka',
  }) {
    final itemNames = items.isEmpty
        ? 'Fashion Items'
        : items.map((item) => item.title).join(', ');

    final paymentObject = <String, dynamic>{
      'sandbox': _payHereUseSandbox,
      'merchant_id': _payHereMerchantId,
      'notify_url': _payHereNotifyUrl,
      'order_id': orderId,
      'items': itemNames,
      'amount': amount,
      'currency': 'LKR',
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'delivery_address': address,
      'delivery_city': city,
      'delivery_country': country,
      'custom_1': '',
      'custom_2': '',
    };

    final completer = Completer<String>();

    PayHere.startPayment(
      paymentObject,
      (paymentId) {
        if (!completer.isCompleted) {
          completer.complete(paymentId);
        }
      },
      (error) {
        if (!completer.isCompleted) {
          completer.completeError(Exception(error));
        }
      },
      () {
        if (!completer.isCompleted) {
          completer.completeError(Exception('Payment cancelled'));
        }
      },
    );

    return completer.future;
  }

  /// Process PayPal Payment
  static Future<bool> processPayPalPayment({
    required String amount,
    required String orderId,
    required String customerEmail,
  }) async {
    if (_payPalClientId.contains('YOUR_') || _payPalSecret.contains('YOUR_')) {
      print('[PaymentService] PayPal: Mock mode - Would process payment');
      print('[PaymentService] PayPal: Amount: $amount, Order: $orderId');
      return true;
    }

    try {
      final url = _payPalUseSandbox ? _payPalSandboxUrl : _payPalProductionUrl;

      // Get access token (using Basic auth header)
      final basicAuth =
          'Basic ' +
          base64Encode(utf8.encode('$_payPalClientId:$_payPalSecret'));

      final tokenResponse = await http.post(
        Uri.parse('$url/v1/oauth2/token'),
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'en_US',
          'Authorization': basicAuth,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials',
      );

      if (tokenResponse.statusCode != 200) {
        print(
          '[PaymentService] PayPal token error: ${tokenResponse.statusCode}',
        );
        print('[PaymentService] Response: ${tokenResponse.body}');
        return false;
      }

      final tokenData = jsonDecode(tokenResponse.body);
      final accessToken = tokenData['access_token'];

      // Create order
      final orderResponse = await http.post(
        Uri.parse('$url/v2/checkout/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'intent': 'CAPTURE',
          'purchase_units': [
            {
              'reference_id': orderId,
              'amount': {'currency_code': 'LKR', 'value': amount},
            },
          ],
          'payer': {'email_address': customerEmail},
          'application_context': {
            'return_url': 'https://digi-drobe.com/payment/success',
            'cancel_url': 'https://digi-drobe.com/payment/cancel',
            'brand_name': 'Digi Drobe',
            'locale': 'en-US',
            'landing_page': 'BILLING',
            'user_action': 'PAY_NOW',
          },
        }),
      );

      if (orderResponse.statusCode == 201) {
        print('[PaymentService] PayPal order created successfully');
        final orderData = jsonDecode(orderResponse.body);
        print('[PaymentService] Order ID: ${orderData['id']}');
        return true;
      } else {
        print('[PaymentService] PayPal error: ${orderResponse.statusCode}');
        print('[PaymentService] Response: ${orderResponse.body}');
        return false;
      }
    } catch (e) {
      print('[PaymentService] PayPal error: $e');
      return false;
    }
  }

  /// Toggle sandbox mode for PayHere
  static void setPayHereSandbox(bool useSandbox) {
    _payHereUseSandbox = useSandbox;
    print('[PaymentService] PayHere sandbox mode: $useSandbox');
  }

  /// Toggle sandbox mode for PayPal
  static void setPayPalSandbox(bool useSandbox) {
    _payPalUseSandbox = useSandbox;
    print('[PaymentService] PayPal sandbox mode: $useSandbox');
  }

  /// Get current mode status
  static Map<String, dynamic> getModeStatus() {
    return {
      'payhere_sandbox': _payHereUseSandbox,
      'paypal_sandbox': _payPalUseSandbox,
      'payhere_configured':
          !_payHereMerchantId.contains('YOUR_') &&
          _payHereMerchantId.isNotEmpty,
      'paypal_configured':
          !_payPalClientId.contains('YOUR_') && _payPalClientId.isNotEmpty,
    };
  }
}
