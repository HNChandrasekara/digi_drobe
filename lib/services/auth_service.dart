import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import 'user_profile_service.dart';
import 'community_service.dart';
import 'email_service.dart';

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

  // Sign Up — also creates a Firestore UserProfile
  Future<UserCredential?> signUpWithEmailPassword(
    String email,
    String password, {
    String displayName = '',
  }) async {
    if (!_isFirebaseInitialized) {
      debugPrint('Mock Sign Up: $email');
      return null;
    }
    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Set display name on FirebaseAuth user
      if (displayName.isNotEmpty) {
        await cred.user?.updateDisplayName(displayName);
        await cred.user?.reload();
      }
      // Create Firestore profile
      if (cred.user != null) {
        final profile = UserProfile(
          uid: cred.user!.uid,
          displayName: displayName.isNotEmpty ? displayName : email.split('@').first,
          email: email,
          role: 'user',
          createdAt: DateTime.now(),
        );
        // Make hirushie9@gmail.com admin
        if (email.toLowerCase() == 'hirushie9@gmail.com') {
          profile.role = 'admin';
        }
        await UserProfileService().createProfile(profile);
      }
      // Seed community channels if first run
      try {
        await CommunityService().seedChannelsIfEmpty();
      } catch (_) {}
      return cred;
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
      // Ensure Firestore profile exists (for users created before this update)
      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        final existing = await UserProfileService().getProfile(uid);
        if (existing == null) {
          final profile = UserProfile(
            uid: uid,
            displayName: userCredential.user!.displayName ?? email.split('@').first,
            email: email,
            role: email.toLowerCase() == 'hirushie9@gmail.com' ? 'admin' : 'user',
            createdAt: DateTime.now(),
          );
          await UserProfileService().createProfile(profile);
        }
        // Seed community channels if needed on sign-in
        try {
          await CommunityService().seedChannelsIfEmpty();
        } catch (_) {}
      }
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
      debugPrint('Logout: All user data cleared successfully.');
    } catch (e) {
      debugPrint('Logout Error: $e');
      rethrow;
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    if (!_isFirebaseInitialized) {
      debugPrint('Using Email Service for password reset: $email');
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
      return Stream.value(null);
    }
    return _auth.authStateChanges();
  }

  // Current User
  User? get currentUser {
    if (!_isFirebaseInitialized) return null;
    return _auth.currentUser;
  }
}
