import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/thrift_item.dart';

class ThriftService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'thrift_items';

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ── Stream of all thrift items ─────────────────────────────────────────────
  Stream<List<ThriftItem>> getThriftItemsStream() {
    return _db
        .collection(_col)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ThriftItem.fromFirestore).toList());
  }

  // ── Add item ─────────────────────────────────────────────────────────────────
  Future<void> addThriftItem(ThriftItem item) async {
    if (_uid == null) throw Exception('User not authenticated');
    await _db.collection(_col).add(item.toFirestore());
  }

  // ── Delete item (only if seller) ─────────────────────────────────────────────
  Future<void> deleteThriftItem(String id) async {
    final doc = await _db.collection(_col).doc(id).get();
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    if (data['sellerId'] != _uid) {
      throw Exception('You can only delete your own items');
    }

    await _db.collection(_col).doc(id).delete();
  }

  // ── Seed initial thrift items (for demo) ────────────────────────────────────
  Future<void> seedIfEmpty() async {
    final snap = await _db.collection(_col).limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final demoItems = [
      ThriftItem(
        id: '',
        title: 'Vintage Leather Jacket',
        price: 45.0,
        description: 'Authentic 90s leather jacket, well-maintained.',
        category: 'Outerwear',
        brand: 'Vintage',
        sellerId: 'system',
        sellerName: 'Admin',
        condition: 'Used - Good',
        addedAt: DateTime.now(),
      ),
      ThriftItem(
        id: '',
        title: 'Blue Summer Dress',
        price: 20.0,
        description: 'Light and airy, perfect for summer days.',
        category: 'Dresses',
        brand: 'Zara',
        sellerId: 'system',
        sellerName: 'Admin',
        condition: 'Used - Like New',
        addedAt: DateTime.now(),
      ),
    ];

    for (var item in demoItems) {
      await addThriftItem(item);
    }
  }
}
