import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  // Using Mailtrap (free tier for testing)
  // Sign up at https://mailtrap.io to get your token
  static const String _mailtrapToken = 'YOUR_MAILTRAP_TOKEN';
  static const String _mailtrapUrl =
      'https://send.api.mailtrap.io/api/send'; // or your email service endpoint
  static const String _senderEmail = 'noreply@digi-drobe.com';
  static const String _senderName = 'Digi Drobe';

  /// Sends a password reset email using Mailtrap API
  static Future<bool> sendPasswordResetEmail({
    required String recipientEmail,
    required String resetLink,
  }) async {
    // Fallback for testing without API key
    if (_mailtrapToken.contains('YOUR_') || _mailtrapToken.isEmpty) {
      print(
        '[EmailService] Mock mode: Would send reset email to $recipientEmail',
      );
      print('[EmailService] Reset link: $resetLink');
      return true;
    }

    try {
      final response = await http.post(
        Uri.parse(_mailtrapUrl),
        headers: {
          'Authorization': 'Bearer $_mailtrapToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': {'email': _senderEmail, 'name': _senderName},
          'to': [
            {'email': recipientEmail},
          ],
          'subject': 'Reset Your Digi Drobe Password',
          'html': _buildPasswordResetEmail(resetLink),
          'category': 'password_reset',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[EmailService] Password reset email sent successfully');
        return true;
      } else {
        print('[EmailService] Failed to send email: ${response.statusCode}');
        print('[EmailService] Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('[EmailService] Error sending email: $e');
      return false;
    }
  }

  /// Builds HTML content for password reset email
  static String _buildPasswordResetEmail(String resetLink) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f9f9f9; }
        .header { background-color: #8B3A3A; color: white; padding: 20px; border-radius: 8px 8px 0 0; text-align: center; }
        .content { padding: 30px; background-color: white; border-radius: 0 0 8px 8px; }
        .button { display: inline-block; background-color: #8B3A3A; color: white; padding: 12px 30px; border-radius: 6px; text-decoration: none; margin: 20px 0; font-weight: bold; }
        .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        .warning { background-color: #fff3cd; border: 1px solid #ffc107; padding: 15px; border-radius: 6px; margin: 20px 0; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>Digi Drobe</h1>
        </div>
        <div class="content">
          <h2>Reset Your Password</h2>
          <p>Hi there,</p>
          <p>We received a request to reset your Digi Drobe password. Click the button below to set a new password:</p>
          
          <center>
            <a href="$resetLink" class="button">Reset Password</a>
          </center>
          
          <p>Or copy and paste this link in your browser:</p>
          <p><code>$resetLink</code></p>
          
          <div class="warning">
            <strong>Security Note:</strong> This link will expire in 1 hour. If you didn't request this reset, you can safely ignore this email.
          </div>
          
          <p>If you continue to have problems, please reply to this email.</p>
          
          <p>Best regards,<br>The Digi Drobe Team</p>
        </div>
        <div class="footer">
          <p>&copy; 2026 Digi Drobe. All rights reserved.</p>
          <p>123 Fashion St, Style City, SC 12345</p>
        </div>
      </div>
    </body>
    </html>
    ''';
  }

  /// Sends a welcome email for new users
  static Future<bool> sendWelcomeEmail({
    required String recipientEmail,
    required String userName,
  }) async {
    if (_mailtrapToken.contains('YOUR_') || _mailtrapToken.isEmpty) {
      print(
        '[EmailService] Mock mode: Would send welcome email to $recipientEmail',
      );
      return true;
    }

    try {
      final response = await http.post(
        Uri.parse(_mailtrapUrl),
        headers: {
          'Authorization': 'Bearer $_mailtrapToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': {'email': _senderEmail, 'name': _senderName},
          'to': [
            {'email': recipientEmail},
          ],
          'subject': 'Welcome to Digi Drobe!',
          'html': _buildWelcomeEmail(userName),
          'category': 'welcome',
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('[EmailService] Error sending welcome email: $e');
      return false;
    }
  }

  /// Builds HTML content for welcome email
  static String _buildWelcomeEmail(String userName) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f9f9f9; }
        .header { background-color: #8B3A3A; color: white; padding: 20px; border-radius: 8px 8px 0 0; text-align: center; }
        .content { padding: 30px; background-color: white; border-radius: 0 0 8px 8px; }
        .button { display: inline-block; background-color: #8B3A3A; color: white; padding: 12px 30px; border-radius: 6px; text-decoration: none; margin: 20px 0; font-weight: bold; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>Welcome to Digi Drobe!</h1>
        </div>
        <div class="content">
          <p>Hi $userName,</p>
          <p>Welcome to Digi Drobe - your personal fashion assistant! We're excited to have you on board.</p>
          
          <h3>What you can do:</h3>
          <ul>
            <li>Browse and shop trending fashion items</li>
            <li>Get AI-powered style recommendations</li>
            <li>Schedule your outfits with calendar integration</li>
            <li>Check weather and get outfit suggestions</li>
            <li>Chat with our fashion bot for style tips</li>
          </ul>
          
          <p>Start exploring now and discover your perfect style!</p>
          
          <p>Best regards,<br>The Digi Drobe Team</p>
        </div>
      </div>
    </body>
    </html>
    ''';
  }
}
