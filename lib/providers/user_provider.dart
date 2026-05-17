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
  String get displayName {
    if (_profile?.displayName != null && _profile!.displayName!.isNotEmpty) {
      return _profile!.displayName!;
    }
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser?.displayName != null &&
        currentUser!.displayName!.isNotEmpty) {
      return currentUser.displayName!;
    }
    // Fallback for Mock Mode / Specific test user
    if (currentUser?.email == 'digidrobe88@gmail.com' || currentUser == null) {
      return 'Hirushie';
    }
    return '';
  }

  String get email =>
      _profile?.email ??
      FirebaseAuth.instance.currentUser?.email ??
      'digidrobe88@gmail.com';

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
    _sub = _service
        .profileStream(uid)
        .listen(
          (profile) {
            _profile = profile;
            notifyListeners();
          },
          onError: (_) {
            notifyListeners();
          },
        );
  }

  Future<void> updateProfile({
    required String displayName,
    required String phone,
  }) async {
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
