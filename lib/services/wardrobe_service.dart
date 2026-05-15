import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/wardrobe_item.dart';

class WardrobeService {
  static final _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _col {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('wardrobe');
  }

  // ── Real-time stream of user's wardrobe ─────────────────────────────────────
  Stream<List<WardrobeItem>> getWardrobeStream() {
    final col = _col;
    if (col == null) return const Stream.empty();
    return col
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(WardrobeItem.fromFirestore).toList());
  }

  // ── Add item ─────────────────────────────────────────────────────────────────
  Future<void> addItem(WardrobeItem item) async {
    final col = _col;
    if (col == null) throw Exception('User not authenticated');
    await col.add(item.toFirestore());
  }

  // ── Delete item ──────────────────────────────────────────────────────────────
  Future<void> deleteItem(String id) async {
    final col = _col;
    if (col == null) throw Exception('User not authenticated');
    await col.doc(id).delete();
  }

  // ── Update item ──────────────────────────────────────────────────────────────
  Future<void> updateItem(WardrobeItem item) async {
    final col = _col;
    if (col == null) throw Exception('User not authenticated');
    await col.doc(item.id).update(item.toFirestore());
  }
}
