import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String brand;

  final String? imageUrl;
  final String? model3dUrl;

  final int? stock;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.brand,
    this.imageUrl,
    this.model3dUrl,
    this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      brand: json['brand'] as String,
      imageUrl: json['imageUrl'] as String?,
      model3dUrl: json['model3dUrl'] as String?,
      stock: json['stock'] as int?,
    );
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      title: data['title'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      brand: data['brand'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      model3dUrl: data['model3dUrl'] as String?,
      stock: (data['stock'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'price': price,
    'description': description,
    'category': category,
    'brand': brand,
    'imageUrl': imageUrl,
    'model3dUrl': model3dUrl,
    'stock': stock,
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'description': description,
    'category': category,
    'brand': brand,
    'imageUrl': imageUrl,
    'model3dUrl': model3dUrl,
  };
}
