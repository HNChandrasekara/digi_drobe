class Product {
  final String id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String brand;

  final String? model3dUrl;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.brand,
    this.model3dUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      brand: json['brand'] as String,
      model3dUrl: json['model3dUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'description': description,
    'category': category,
    'brand': brand,
    'model3dUrl': model3dUrl,
  };
}
