import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _service = CartService();

  List<CartItem> _items = [];
  bool _isLoading = false;
  StreamSubscription<List<CartItem>>? _sub;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  double get total => _items.fold(0.0, (sum, i) => sum + i.subtotal);

  String? get _uid => AuthService().currentUser?.uid;

  CartProvider() {
    _listenToCart();
  }

  void _listenToCart() {
    final uid = _uid;
    if (uid == null) return;
    _isLoading = true;
    notifyListeners();
    _sub?.cancel();
    _sub = _service.getCartStream(uid).listen(
      (list) {
        _items = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Call this after sign-in to start listening to the cart.
  void reload() {
    _listenToCart();
  }

  Future<void> addItem(CartItem item) async {
    final uid = _uid;
    if (uid == null) return;
    await _service.addItem(uid, item);
  }

  Future<void> removeItem(String productId) async {
    final uid = _uid;
    if (uid == null) return;
    await _service.removeItem(uid, productId);
  }

  Future<void> decrementItem(String productId) async {
    final uid = _uid;
    if (uid == null) return;
    await _service.decrementItem(uid, productId);
  }

  Future<void> clearCart() async {
    final uid = _uid;
    if (uid == null) return;
    await _service.clearCart(uid);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
