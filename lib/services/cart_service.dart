import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';

class CartService {
  static final _db = FirebaseFirestore.instance;

  CollectionReference _cartRef(String userId) =>
      _db.collection('carts').doc(userId).collection('items');

  // ── Stream current user's cart ──────────────────────────────────────────────
  Stream<List<CartItem>> getCartStream(String userId) {
    return _cartRef(userId).snapshots().map(
          (snap) => snap.docs.map(CartItem.fromFirestore).toList(),
        );
  }

  // ── Add or increment item ───────────────────────────────────────────────────
  Future<void> addItem(String userId, CartItem item) async {
    final ref = _cartRef(userId).doc(item.productId);
    final existing = await ref.get();
    if (existing.exists) {
      final currentQty = (existing.data() as Map<String, dynamic>)['quantity'] as int? ?? 1;
      await ref.update({'quantity': currentQty + 1});
    } else {
      await ref.set(item.toFirestore());
    }
  }

  // ── Decrease quantity or remove item ────────────────────────────────────────
  Future<void> decrementItem(String userId, String productId) async {
    final ref = _cartRef(userId).doc(productId);
    final existing = await ref.get();
    if (!existing.exists) return;
    final currentQty = (existing.data() as Map<String, dynamic>)['quantity'] as int? ?? 1;
    if (currentQty <= 1) {
      await ref.delete();
    } else {
      await ref.update({'quantity': currentQty - 1});
    }
  }

  // ── Remove item entirely ────────────────────────────────────────────────────
  Future<void> removeItem(String userId, String productId) async {
    await _cartRef(userId).doc(productId).delete();
  }

  // ── Clear cart ──────────────────────────────────────────────────────────────
  Future<void> clearCart(String userId) async {
    final snap = await _cartRef(userId).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
