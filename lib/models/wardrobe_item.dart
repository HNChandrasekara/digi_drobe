import 'package:cloud_firestore/cloud_firestore.dart';

class WardrobeItem {
  final String id;
  final String title;
  final String category;
  final String brand;
  final String description;
  final String? imageUrl;
  final String? imageDataUrl;
  final DateTime? addedAt;

  const WardrobeItem({
    required this.id,
    required this.title,
    required this.category,
    this.brand = '',
    this.description = '',
    this.imageUrl,
    this.imageDataUrl,
    this.addedAt,
  });

  factory WardrobeItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WardrobeItem(
      id: doc.id,
      title: data['title'] as String? ?? '',
      category: data['category'] as String? ?? 'Uncategorized',
      brand: data['brand'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      imageDataUrl: data['imageDataUrl'] as String?,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'category': category,
    'brand': brand,
    'description': description,
    'imageUrl': imageUrl,
    'imageDataUrl': imageDataUrl,
    'addedAt': addedAt != null
        ? Timestamp.fromDate(addedAt!)
        : FieldValue.serverTimestamp(),
  };
}
