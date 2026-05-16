import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserProfileService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'users';

  // ── Create profile (called after sign-up) ───────────────────────────────────
  Future<void> createProfile(UserProfile profile) async {
    await _db.collection(_col).doc(profile.uid).set(profile.toFirestore());
  }

  // ── Get profile once ────────────────────────────────────────────────────────
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _db.collection(_col).doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  // ── Stream profile ──────────────────────────────────────────────────────────
  Stream<UserProfile?> profileStream(String uid) {
    return _db
        .collection(_col)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
  }

  // ── Update profile ──────────────────────────────────────────────────────────
  Future<void> updateProfile(UserProfile profile) async {
    await _db.collection(_col).doc(profile.uid).update({
      'displayName': profile.displayName,
      'phone': profile.phone,
      'photoUrl': profile.photoUrl,
    });
  }

  // ── Get all users (admin) ────────────────────────────────────────────────────
  Stream<List<UserProfile>> getAllUsersStream() {
    return _db
        .collection(_col)
        .snapshots()
        .map((snap) => snap.docs.map(UserProfile.fromFirestore).toList());
  }

  // ── Set admin role ───────────────────────────────────────────────────────────
  Future<void> setRole(String uid, String role) async {
    await _db.collection(_col).doc(uid).update({'role': role});
  }
}
