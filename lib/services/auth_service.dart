import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import 'user_profile_service.dart';
import 'community_service.dart';
import 'email_service.dart';
import '../firebase_options.dart';

class AuthService {
  bool get _isFirebaseInitialized => Firebase.apps.isNotEmpty;

  static void markInitialized() {
    // Left empty for backwards compatibility. Remove if not used elsewhere.
  }

  FirebaseAuth get _auth {
    if (!_isFirebaseInitialized) {
      throw Exception('Firebase not initialized');
    }
    return FirebaseAuth.instance;
  }

  // Detect if we're using dummy configuration (Mock Mode)
  bool get isMockMode => _isMockMode;

  bool get _isMockMode {
    debugPrint('AuthService: Checking mock mode... Initialized: ${_isFirebaseInitialized}');
    if (!_isFirebaseInitialized) return true;
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      final apiKey = options.apiKey;
      final projectId = options.projectId;
      final isDummy = apiKey.contains('Dummy') || projectId.contains('-local');
      debugPrint('AuthService: Config Check -> dummy=$isDummy, project=$projectId');
      return isDummy;
    } catch (e) {
      debugPrint('AuthService: Config access failed, defaulting to mock mode. Error: $e');
      return true; // Default to mock if configuration access fails on Web
    }
  }

  // Sign Up — also creates a Firestore UserProfile
  Future<UserCredential?> signUpWithEmailPassword(
    String email,
    String password, {
    String displayName = '',
  }) async {
    if (_isMockMode) {
      debugPrint('Mock Sign Up (Enabled): $email');
      // Create a mock credential for the flow
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
      throw e.message ?? 'Auth Error: ${e.code}';
    } catch (e) {
      throw 'Sign Up failed: [${e.runtimeType}] $e';
    }
  }

  // Sign In
  Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    // Explicit bypass for requested development account OR general Mock Mode detection
    final isMock = _isMockMode;
    final isSpecificUser = email.toLowerCase() == 'digidrobe88@gmail.com';
    debugPrint('AuthService: Sign In attempt -> email=$email, mock=$isMock, bypass=$isSpecificUser');
    
    if (isMock || isSpecificUser) {
      debugPrint('AuthService: Entering Mock Mode for $email');
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
      throw e.message ?? 'Auth Error: ${e.code}';
    } catch (e) {
      // Catch any other runtime error and report the type
      throw 'Sign In failed: [${e.runtimeType}] $e';
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
