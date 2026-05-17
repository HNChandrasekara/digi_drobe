import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String productId;
  final String title;
  final String? brand;
  final String? imageUrl;
  final String? imageDataUrl;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.title,
    this.brand,
    this.imageUrl,
    this.imageDataUrl,
    required this.price,
    this.quantity = 1,
  });

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItem(
      productId: data['productId'] as String? ?? doc.id,
      title: data['title'] as String? ?? '',
      brand: data['brand'] as String?,
      imageUrl: data['imageUrl'] as String?,
      imageDataUrl: data['imageDataUrl'] as String?,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'productId': productId,
    'title': title,
    'brand': brand,
    'imageUrl': imageUrl,
    'imageDataUrl': imageDataUrl,
    'price': price,
    'quantity': quantity,
  };

  double get subtotal => price * quantity;
}
