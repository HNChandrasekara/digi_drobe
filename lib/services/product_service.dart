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
    // Disabled dummy data seeding for virtual wardrobe implementation.
    return;
  }
}
