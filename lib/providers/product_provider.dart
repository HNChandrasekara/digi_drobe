import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();
  
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Product>>? _sub;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProductProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Seed products if Firestore is empty (first run)
      await _service.seedProductsIfEmpty();
    } catch (e) {
      debugPrint('ProductProvider: seed error: $e');
    }
    _sub = _service.getProductsStream().listen(
      (list) {
        _products = list;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  List<Product> search(String query) {
    if (query.isEmpty) return _products;
    final q = query.toLowerCase();
    return _products
        .where((p) =>
            p.title.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();
  }

  List<Product> byCategory(String category) =>
      _products.where((p) => p.category == category).toList();

  List<String> get categories =>
      _products.map((p) => p.category).toSet().toList();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
