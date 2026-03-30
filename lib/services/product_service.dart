import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'products';

  // ── Stream of all products ──────────────────────────────────────────────────
  Stream<List<Product>> getProductsStream() {
    return _db.collection(_col).snapshots().map(
          (snap) => snap.docs.map(Product.fromFirestore).toList(),
        );
  }

  // ── One-time fetch ──────────────────────────────────────────────────────────
  Future<List<Product>> getProducts() async {
    final snap = await _db.collection(_col).get();
    return snap.docs.map(Product.fromFirestore).toList();
  }

  Future<Product?> getProductById(String id) async {
    final doc = await _db.collection(_col).doc(id).get();
    if (!doc.exists) return null;
    return Product.fromFirestore(doc);
  }

  // ── Admin CRUD ──────────────────────────────────────────────────────────────
  Future<void> addProduct(Product product) async {
    await _db.collection(_col).add(product.toFirestore());
  }

  Future<void> updateProduct(Product product) async {
    await _db.collection(_col).doc(product.id).update(product.toFirestore());
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection(_col).doc(id).delete();
  }

  // ── Seed initial products (called once on first run) ────────────────────────
  Future<void> seedProductsIfEmpty() async {
    final snap = await _db.collection(_col).limit(1).get();
    if (snap.docs.isNotEmpty) return; // Already seeded

    final seedData = [
      {
        'title': 'Premium Cotton Polo Shirt',
        'price': 45.99,
        'description':
            'High-quality 100% cotton polo shirt in classic white. Perfect for casual and semi-formal occasions.',
        'category': 'Tops',
        'brand': 'ThreadCraft',
        'imageUrl':
            'https://images.unsplash.com/photo-1581655353564-df123a1eb820?auto=format&fit=crop&q=80',
        'model3dUrl': 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
        'stock': 50,
      },
      {
        'title': 'Elegant Maroon Heels',
        'price': 89.99,
        'description':
            'Sophisticated maroon leather heels with a 3-inch heel. Designed for comfort and style.',
        'category': 'Footwear',
        'brand': 'StyleSteps',
        'imageUrl':
            'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&q=80',
        'stock': 25,
      },
      {
        'title': 'Designer Leather Handbag',
        'price': 120.00,
        'description':
            'Luxurious designer handbag crafted from premium leather. Multiple compartments.',
        'category': 'Accessories',
        'brand': 'Luxe Carry',
        'imageUrl':
            'https://images.unsplash.com/photo-1584916201218-f4242ceb4809?auto=format&fit=crop&q=80',
        'stock': 15,
      },
      {
        'title': 'Classic Blue Denim Jeans',
        'price': 65.50,
        'description':
            'Timeless blue denim jeans with a modern fit. Comfortable, durable fabric.',
        'category': 'Bottoms',
        'brand': 'DenimCo',
        'imageUrl':
            'https://images.unsplash.com/photo-1542272604-780211a7fdf0?auto=format&fit=crop&q=80',
        'stock': 41,
      },
      {
        'title': 'Floral Summer Dress',
        'price': 55.00,
        'description':
            'Lightweight floral summer dress perfect for warm weather. Easy-care fabric.',
        'category': 'Dresses',
        'brand': 'SunStyle',
        'imageUrl':
            'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?auto=format&fit=crop&q=80',
        'stock': 22,
      },
      {
        'title': 'White Casual Sneakers',
        'price': 72.00,
        'description':
            'Comfortable white sneakers with cushioned insoles. Great for everyday wear.',
        'category': 'Footwear',
        'brand': 'ComfortWalk',
        'imageUrl':
            'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&q=80',
        'stock': 10,
      },
    ];

    final batch = _db.batch();
    for (final product in seedData) {
      final ref = _db.collection(_col).doc();
      batch.set(ref, product);
    }
    await batch.commit();
  }
}
