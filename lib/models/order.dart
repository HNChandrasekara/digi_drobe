import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double total;
  final String status; // 'pending', 'processing', 'completed', 'cancelled'
  final String paymentMethod;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawItems = data['items'] as List<dynamic>? ?? [];
    final items = rawItems.map((item) {
      final m = item as Map<String, dynamic>;
      return CartItem(
        productId: m['productId'] as String? ?? '',
        title: m['title'] as String? ?? '',
        imageUrl: m['imageUrl'] as String?,
        price: (m['price'] as num?)?.toDouble() ?? 0.0,
        quantity: (m['quantity'] as num?)?.toInt() ?? 1,
      );
    }).toList();

    return Order(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      items: items,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? 'pending',
      paymentMethod: data['paymentMethod'] as String? ?? 'Unknown',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'items': items.map((item) => item.toFirestore()).toList(),
        'total': total,
        'status': status,
        'paymentMethod': paymentMethod,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
