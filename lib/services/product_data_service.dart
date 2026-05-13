import '../models/product.dart';

class ProductDataService {
  static final List<Product> _products = [
    Product(
      id: '1',
      title: 'Premium Cotton Polo Shirt',
      price: 45.99,
      description:
          'High-quality 100% cotton polo shirt in classic white. Perfect for casual and semi-formal occasions. Features a comfortable fit and breathable fabric.',
      category: 'Tops',
      brand: 'ThreadCraft',
      imageUrl: 'https://images.unsplash.com/photo-1581655353564-df123a1eb820?auto=format&fit=crop&q=80',
      model3dUrl: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
    ),
    Product(
      id: '2',
      title: 'Elegant Maroon Heels',
      price: 89.99,
      description:
          'Sophisticated maroon leather heels with a 3-inch heel. Designed for comfort and style. Perfect for evening events or professional settings.',
      category: 'Footwear',
      brand: 'StyleSteps',
      imageUrl: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&q=80',
    ),
    Product(
      id: '3',
      title: 'Designer Leather Handbag',
      price: 120.00,
      description:
          'Luxurious designer handbag crafted from premium leather. Multiple compartments and an adjustable shoulder strap. A versatile piece for any wardrobe.',
      category: 'Accessories',
      brand: 'Luxe Carry',
      imageUrl: 'https://images.unsplash.com/photo-1584916201218-f4242ceb4809?auto=format&fit=crop&q=80',
    ),
    Product(
      id: '4',
      title: 'Classic Blue Denim Jeans',
      price: 65.50,
      description:
          'Timeless blue denim jeans with a modern fit. Made from comfortable, durable fabric with a classic five-pocket design.',
      category: 'Bottoms',
      brand: 'DenimCo',
      imageUrl: 'https://images.unsplash.com/photo-1542272604-780211a7fdf0?auto=format&fit=crop&q=80',
    ),
    Product(
      id: '5',
      title: 'Floral Summer Dress',
      price: 55.00,
      description:
          'Lightweight floral summer dress perfect for warm weather. Features a flowing design and easy-care fabric. Ideal for casual outings.',
      category: 'Dresses',
      brand: 'SunStyle',
      imageUrl: 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?auto=format&fit=crop&q=80',
    ),
    Product(
      id: '6',
      title: 'White Casual Sneakers',
      price: 72.00,
      description:
          'Comfortable white sneakers with cushioned insoles. Great for everyday wear. Features a durable rubber sole and breathable mesh upper.',
      category: 'Footwear',
      brand: 'ComfortWalk',
      imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&q=80',
    ),
  ];

  /// Get all products
  static List<Product> getAllProducts() => _products;

  /// Get product by ID
  static Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Search products by title or description
  static List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    final lowerQuery = query.toLowerCase();
    return _products
        .where(
          (p) =>
              p.title.toLowerCase().contains(lowerQuery) ||
              p.description.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Get products by category
  static List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  /// Get all unique categories
  static List<String> getCategories() {
    return _products.map((p) => p.category).toSet().toList();
  }

  /// Calculate cart total
  static double calculateCartTotal(List<Product> products) {
    return products.fold(0.0, (sum, p) => sum + p.price);
  }
}
