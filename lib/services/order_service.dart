import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order.dart';

class OrderService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'orders';

  // ── Place an order ──────────────────────────────────────────────────────────
  Future<String> placeOrder(Order order) async {
    final ref = await _db.collection(_col).add(order.toFirestore());
    return ref.id;
  }

  // ── Get user orders stream ──────────────────────────────────────────────────
  Stream<List<Order>> getUserOrders(String userId) {
    return _db
        .collection(_col)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Order.fromFirestore).toList());
  }

  // ── Get all orders (admin) ──────────────────────────────────────────────────
  Stream<List<Order>> getAllOrders() {
    return _db
        .collection(_col)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Order.fromFirestore).toList());
  }

  // ── Update order status ─────────────────────────────────────────────────────
  Future<void> updateStatus(String orderId, String status) async {
    await _db.collection(_col).doc(orderId).update({'status': status});
  }
}
