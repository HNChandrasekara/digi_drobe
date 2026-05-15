# Email Service Setup Guide

## Overview
Digi Drobe uses Mailtrap for email delivery (free tier supports testing). The email service sends password reset links and welcome emails to users.

## Getting Your Mailtrap API Key

1. **Sign Up**: Visit [Mailtrap.io](https://mailtrap.io) and create a free account
2. **Create Integration**: 
   - Go to **Integrations** → **API**
   - Select **Sending API**
   - Choose **Node.js** (we'll use the API endpoint)
3. **Get Your Token**: Copy your API token from the credentials

## Configuration

### Step 1: Add Your Mailtrap API Token
In `lib/services/email_service.dart`, replace:
```dart
static const String _mailtrapToken = 'YOUR_MAILTRAP_TOKEN';
```

with your actual token:
```dart
static const String _mailtrapToken = 'your_actual_mailtrap_token_here';
```

### Step 2: (Optional) Update Sender Email
If you have a verified sender domain, update:
```dart
static const String _senderEmail = 'noreply@digi-drobe.com';
static const String _senderName = 'Digi Drobe';
```

### Step 3: Configure Reset Link Domain
In `lib/services/auth_service.dart`, update the reset link domain:
```dart
final resetLink = 'https://your-actual-domain.com/reset-password?token=$resetToken&email=$email';
```

## Testing

1. **Without API Key** (Mock Mode):
   - Leave `_mailtrapToken = 'YOUR_MAILTRAP_TOKEN'`
   - App will print to console instead of sending
   - Perfect for development/testing

2. **With API Key** (Real Emails):
   - Emails will be sent through Mailtrap
   - Check Mailtrap dashboard for delivery status
   - Free tier allows testing with real email addresses

### Test Flow:
1. Go to Forgot Password screen
2. Enter a test email
3. Click "Send Reset Link"
4. Check Mailtrap dashboard or email inbox
5. Verify the reset link in the email

## Email Types Implemented

### 1. Password Reset Email
- Triggers when user clicks "Forgot Password"
- Contains reset link (valid for 1 hour)
- Includes security warning
- HTML-formatted with professional styling

### 2. Welcome Email (Optional)
- Can be sent after signup
- Currently only method defined
- Use in signup_screen.dart after account creation:
```dart
await EmailService.sendWelcomeEmail(
  recipientEmail: email,
  userName: userName,
);
```

## Troubleshooting

**"Failed to compile"**
- Ensure `http` package is in pubspec.yaml (already included)
- Run `flutter pub get`

**Emails not sending**
- Check API token is correct in `email_service.dart`
- Verify token in Mailtrap dashboard is still valid
- Check Mailtrap shows failed deliveries (might have validation errors)

**"Unsupported Email"** error from Mailtrap
- Free tier has restrictions on recipient domains
- Use a personal Gmail/Outlook test account instead

**Rate Limit**
- Free tier: Usually 500 emails/month
- Upgrade plan if you exceed limits

## Security Notes

**Current Implementation:**
- Reset tokens are basic random strings
- Production should use:
  - Cryptographically secure token generation
  - Token storage in backend database
  - Token expiration (currently hardcoded to 1 hour)
  - HTTPS-only reset links

**For Production:**
1. Use secure token library: `crypto` or `pointycastle`
2. Store tokens in backend database with expiration
3. Validate tokens on reset link click
4. Hash tokens before storage

## API Reference

### EmailService.sendPasswordResetEmail()
```dart
Future<bool> sendPasswordResetEmail({
  required String recipientEmail,
  required String resetLink,
})
```
- Returns: true if email sent successfully, false otherwise
- Throws: No exceptions (returns boolean status)

### EmailService.sendWelcomeEmail()
```dart
Future<bool> sendWelcomeEmail({
  required String recipientEmail,
  required String userName,
})
```
- Returns: true if email sent successfully, false otherwise

## Next Steps

1. Add email to signup flow (auto-send welcome email)
2. Create reset password UI screen
3. Implement token validation in backend
4. Add email verification for signups
5. Configure custom domain email for production

For more info, visit [Mailtrap Documentation](https://mailtrap.io/blog/send-emails-with-api)
