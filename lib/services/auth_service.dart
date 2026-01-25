import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  bool get _isFirebaseInitialized => Firebase.apps.isNotEmpty;

  FirebaseAuth get _auth {
    if (!_isFirebaseInitialized) {
      throw Exception('Firebase not initialized');
    }
    return FirebaseAuth.instance;
  }

  // Sign Up
  Future<UserCredential?> signUpWithEmailPassword(String email, String password) async {
    if (!_isFirebaseInitialized) {
      debugPrint('Mock Sign Up: $email');
      return null; // Return null or mock data in mock mode
    }
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    }
  }

  // Sign In
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    if (!_isFirebaseInitialized) {
      debugPrint('Mock Sign In: $email');
      return null;
    }
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    if (!_isFirebaseInitialized) {
      debugPrint('Mock Sign Out');
      return;
    }
    await _auth.signOut();
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    if (!_isFirebaseInitialized) {
      debugPrint('Mock Password Reset: $email');
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    }
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
