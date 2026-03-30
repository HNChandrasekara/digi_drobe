import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';

class UserProvider extends ChangeNotifier {
  final UserProfileService _service = UserProfileService();

  UserProfile? _profile;
  StreamSubscription<UserProfile?>? _sub;

  UserProfile? get profile => _profile;
  bool get isAdmin => _profile?.isAdmin ?? false;
  String get displayName => _profile?.displayName ?? FirebaseAuth.instance.currentUser?.displayName ?? '';
  String get email => _profile?.email ?? FirebaseAuth.instance.currentUser?.email ?? '';

  UserProvider() {
    _listenToAuthState();
  }

  void _listenToAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _startProfileStream(user.uid);
      } else {
        _sub?.cancel();
        _profile = null;
        notifyListeners();
      }
    });
  }

  void _startProfileStream(String uid) {
    _sub?.cancel();
    _sub = _service.profileStream(uid).listen(
      (profile) {
        _profile = profile;
        notifyListeners();
      },
      onError: (_) {
        notifyListeners();
      },
    );
  }

  Future<void> updateProfile({required String displayName, required String phone}) async {
    if (_profile == null) return;
    _profile!.displayName = displayName;
    _profile!.phone = phone;
    await _service.updateProfile(_profile!);
    notifyListeners();
  }

  Future<void> updatePhotoUrl(String url) async {
    if (_profile == null) return;
    _profile!.photoUrl = url;
    await _service.updateProfile(_profile!);
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
