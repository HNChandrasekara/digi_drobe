import 'package:cloud_firestore/cloud_firestore.dart';

class ThriftItem {
  final String id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String brand;
  final String? imageUrl;
  final String? imageDataUrl;
  final String sellerId;
  final String sellerName;
  final DateTime? addedAt;
  final String
  condition; // e.g., "New", "Used - Like New", "Used - Good", "Used - Fair"

  const ThriftItem({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.brand,
    this.imageUrl,
    this.imageDataUrl,
    required this.sellerId,
    required this.sellerName,
    this.addedAt,
    this.condition = 'Used - Good',
  });

  factory ThriftItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ThriftItem(
      id: doc.id,
      title: data['title'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      brand: data['brand'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      imageDataUrl: data['imageDataUrl'] as String?,
      sellerId: data['sellerId'] as String? ?? '',
      sellerName: data['sellerName'] as String? ?? 'Anonymous',
      addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
      condition: data['condition'] as String? ?? 'Used - Good',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'price': price,
    'description': description,
    'category': category,
    'brand': brand,
    'imageUrl': imageUrl,
    'imageDataUrl': imageDataUrl,
    'sellerId': sellerId,
    'sellerName': sellerName,
    'addedAt': addedAt != null
        ? Timestamp.fromDate(addedAt!)
        : FieldValue.serverTimestamp(),
    'condition': condition,
  };
}
