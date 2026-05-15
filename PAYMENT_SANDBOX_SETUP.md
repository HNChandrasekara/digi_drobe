# Payment Sandbox Setup Guide

## Overview
Digi Drobe supports **PayHere** and **PayPal** payment gateways in sandbox mode for testing. All payments currently use sandbox/test environments.

## PayHere Sandbox Setup

### 1. Create PayHere Account
- Visit [PayHere Merchant Portal](https://merchant.payhere.lk)
- Sign up and verify your account
- Go to **Settings** → **API Credentials**

### 2. Get Sandbox Credentials
- **Sandbox URL**: `https://sandbox.payhere.lk/api/v2` (automatically used)
- **Merchant ID**: Copy from PayHere dashboard
- **Merchant Secret**: Copy from PayHere dashboard

### 3. Configure in Your App
In `lib/services/payment_service.dart`:
```dart
static const String _payHereMerchantId = 'YOUR_PAYHERE_MERCHANT_ID';
static const String _payHereMerchantSecret = 'YOUR_PAYHERE_MERCHANT_SECRET';
static bool _payHereUseSandbox = true; // Keep true for testing
```

### 4. PayHere Test Cards
Use these test cards in sandbox mode:
- **Visa**: `4111111111111111` | Expiry: any future date | CVV: any 3 digits
- **Mastercard**: `5555555555554444` | Expiry: any future date | CVV: any 3 digits

## PayPal Sandbox Setup

### 1. Create PayPal Developer Account
- Visit [PayPal Developer](https://developer.paypal.com)
- Sign up and log in to Dashboard
- Go to **Sandbox** → **Accounts**

### 2. Get Sandbox Credentials
- Create a **Business Account** (Merchant)
- Create a **Personal Account** (Buyer for testing)
- Copy **Client ID** and **Secret** from Business Account
- **Sandbox URL**: `https://api.sandbox.paypal.com` (automatically used)

### 3. Configure in Your App
In `lib/services/payment_service.dart`:
```dart
static const String _payPalClientId = 'YOUR_PAYPAL_CLIENT_ID';
static const String _payPalSecret = 'YOUR_PAYPAL_CLIENT_SECRET';
static bool _payPalUseSandbox = true; // Keep true for testing
```

### 4. PayPal Test Accounts
Use the Personal Account created in sandbox to test payments:
1. When payment screen shows PayPal option
2. You'll be redirected to PayPal sandbox login
3. Log in with Personal Account credentials
4. Complete the test payment

## Testing the Payment Flow

### In App:
1. Go to **Cart** → Click **Checkout**
2. Select payment method (PayHere or PayPal)
3. See **"Sandbox Mode - Testing Only"** badge (confirms sandbox is active)
4. Click **Pay Now**

### Without API Keys (Mock Mode):
- Leave credentials as `YOUR_PAYHERE_...` / `YOUR_PAYPAL_...`
- Payment will log to console instead of sending
- Perfect for UI testing without real API keys

### With API Keys (Real Sandbox):
- Credentials are valid
- Real sandbox API calls are made
- No actual money is charged
- See payment results in console logs

## Switching Between Sandbox and Production

### For PayHere:
```dart
// Enable sandbox (testing)
PaymentService.setPayHereSandbox(true);

// Switch to production (real payments)
PaymentService.setPayHereSandbox(false);
```

### For PayPal:
```dart
// Enable sandbox (testing)
PaymentService.setPayPalSandbox(true);

// Switch to production (real payments)
PaymentService.setPayPalSandbox(false);
```

## Check Payment Mode Status

```dart
final status = PaymentService.getModeStatus();
print(status);
// Output:
// {
//   'payhere_sandbox': true,
//   'paypal_sandbox': true,
//   'payhere_configured': true/false,
//   'paypal_configured': true/false
// }
```

## Troubleshooting

### "Sandbox Mode - Testing Only" Badge Always Shows
✅ This is correct! It means you're in test mode (safe for development)

### Payments Processing Silently (No Errors)
- Check console logs for API responses
- Ensure API credentials are correct
- Verify PayHere/PayPal accounts are in good standing

### "Failed to compile" Error
- Run `flutter pub get`
- Ensure `http` package is in pubspec.yaml

### Payment Fails with Invalid Credentials
- Double-check Merchant ID and Secret (PayHere)
- Verify Client ID and Secret (PayPal)
- Ensure credentials are copied completely (no extra spaces)

### No "Sandbox Mode" Badge
- Your credentials are valid and production mode is enabled
- Check `PaymentService.setPayHereSandbox(false)` hasn't been called
- This only shows when using sandbox environments

## Production Setup

When ready for real payments:

1. **Enable Production URLs**:
   ```dart
   PaymentService.setPayHereSandbox(false);
   PaymentService.setPayPalSandbox(false);
   ```

2. **Get Real Credentials**:
   - PayHere: Copy production Merchant ID/Secret
   - PayPal: Use production Client ID/Secret

3. **Update Configuration**:
   - Replace sandbox credentials with production ones
   - Remove/comment out sandbox test data

4. **SSL/HTTPS Required**:
   - All payment URLs must use HTTPS
   - Domain must have valid SSL certificate

5. **PCI Compliance**:
   - Never log or store card data
   - Use tokenization for stored payments
   - Follow payment processor security guidelines

## API Reference

### PaymentService.processPayHerePayment()
```dart
Future<bool> processPayHerePayment({
  required String amount,
  required String orderId,
  required String customerEmail,
  required String customerPhone,
})
```
- Returns: `true` if payment initiated, `false` if failed
- Works in sandbox and production modes

### PaymentService.processPayPalPayment()
```dart
Future<bool> processPayPalPayment({
  required String amount,
  required String orderId,
  required String customerEmail,
})
```
- Returns: `true` if payment initiated, `false` if failed
- Works in sandbox and production modes

## Support
- **PayHere Docs**: https://payhere.lk/developers
- **PayPal Docs**: https://developer.paypal.com/docs
- **Sandbox Testing**: Use test cards/accounts provided above
