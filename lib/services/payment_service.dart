import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class PaymentService {
  // PayHere Configuration
  static const String _payHereSandboxUrl =
      'https://sandbox.payhere.lk/api/v2'; // Sandbox URL
  static const String _payHereProductionUrl =
      'https://api.payhere.lk/api/v2'; // Production URL
  static const String _payHereMerchantId = '1233880';
  static const String _payHereMerchantSecret =
      'NDY0ODM3NDQzMzY0MzAxMzk1MzU5OTM2MjY1MzQxMjEzNzU4ODM=';
  static bool _payHereUseSandbox = true; // Toggle for sandbox/production

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
  }) async {
    // In mock mode return a fake sandbox checkout URL
    if (_payHereMerchantId.contains('YOUR_') ||
        _payHereMerchantSecret.contains('YOUR_')) {
      print('[PaymentService] PayHere: Mock mode - Would process payment');
      print('[PaymentService] PayHere: Amount: $amount, Order: $orderId');
      return 'https://sandbox.payhere.lk/pay/$orderId';
    }

    try {
      // PayHere hosted checkout - construct URL directly
      // Hash format: md5(amount|merchant_id|order_id|merchant_secret)
      final hash = md5
          .convert(
            utf8.encode(
              '$amount|$_payHereMerchantId|$orderId|$_payHereMerchantSecret',
            ),
          )
          .toString();

      final base = _payHereUseSandbox
          ? 'https://sandbox.payhere.lk'
          : 'https://www.payhere.lk';

      // PayHere hosted checkout URL - correct endpoint
      final checkoutUrl =
          '$base/pay/checkout?merchant_id=$_payHereMerchantId&return_url=${Uri.encodeComponent('https://digi-drobe.com/payment/success')}&cancel_url=${Uri.encodeComponent('https://digi-drobe.com/payment/cancel')}&notify_url=${Uri.encodeComponent('https://digi-drobe.com/payment/notify')}&order_id=$orderId&items=${Uri.encodeComponent('Fashion Items')}&amount=$amount&currency=LKR&first_name=Customer&last_name=Name&email=${Uri.encodeComponent(customerEmail)}&phone=${Uri.encodeComponent(customerPhone)}&address=${Uri.encodeComponent('123 Fashion St')}&city=Colombo&country=${Uri.encodeComponent('Sri Lanka')}&hash=$hash';

      print('[PaymentService] PayHere checkout URL: $checkoutUrl');
      return checkoutUrl;
    } catch (e) {
      print('[PaymentService] PayHere error: $e');
      return null;
    }
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
