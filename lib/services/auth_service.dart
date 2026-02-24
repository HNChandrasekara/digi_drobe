import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'email_service.dart';
// import 'avatar_service.dart';

class AuthService {
  static bool _initialized = false;
  static void markInitialized() => _initialized = true;

  bool get _isFirebaseInitialized => Firebase.apps.isNotEmpty;

  FirebaseAuth get _auth {
    if (!_isFirebaseInitialized) {
      throw Exception('Firebase not initialized');
    }
    return FirebaseAuth.instance;
  }

  // Sign Up
  Future<UserCredential?> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    if (!_isFirebaseInitialized) {
      debugPrint('Mock Sign Up: $email');
      return null; // Return null or mock data in mock mode
    }
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    }
  }

  // Sign In
  Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    if (!_isFirebaseInitialized) {
      debugPrint('Mock Sign In: $email');
      return null;
    }
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      if (!_isFirebaseInitialized) {
        debugPrint('Mock Sign Out');
      } else {
        await _auth.signOut();
      }
      
      // Clear local user data
      // await AvatarService.clearAvatar();
      
      debugPrint('Logout: All user data cleared successfully.');
    } catch (e) {
      debugPrint('Logout Error: $e');
      rethrow;
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    if (!_isFirebaseInitialized) {
      // Use custom email service for web/non-Firebase environments
      debugPrint('Using Email Service for password reset: $email');

      // Generate a reset token (in production, generate and store securely)
      final resetToken = _generateResetToken();
      final resetLink =
          'https://digi-drobe.com/reset-password?token=$resetToken&email=$email';

      final success = await EmailService.sendPasswordResetEmail(
        recipientEmail: email,
        resetLink: resetLink,
      );

      if (!success) {
        throw 'Failed to send password reset email. Please try again.';
      }
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    }
  }

  // Generate a simple reset token (in production, use secure token generation)
  static String _generateResetToken() {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';
    String token = '';
    for (int i = 0; i < 32; i++) {
      token += chars[(DateTime.now().millisecond + i) % chars.length];
    }
    return token;
  }

  // User Stream
  Stream<User?> get authStateChanges {
    if (!_isFirebaseInitialized) {
      return Stream.value(null); // Fallback stream for mock mode
    }
    return _auth.authStateChanges();
  }

  // Current User
  User? get currentUser {
    if (!_isFirebaseInitialized) return null;
    return _auth.currentUser;
  }
}
