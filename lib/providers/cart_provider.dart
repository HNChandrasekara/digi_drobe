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

  // Check if we should use local mock data
  bool get _shouldUseMock =>
      AuthService().isMockMode || AuthService().currentUser == null;
  String? get _uid => AuthService().currentUser?.uid;

  CartProvider() {
    _listenToCart();
  }

  void _listenToCart() {
    if (_shouldUseMock) {
      debugPrint('CartProvider: Using local memory for cart (Mock Mode)');
      return;
    }

    final uid = _uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();
    _sub?.cancel();
    _sub = _service
        .getCartStream(uid)
        .listen(
          (list) {
            _items = list;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('CartProvider: Stream error: $e');
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
    _addItemLocally(item);

    if (_shouldUseMock) {
      return;
    }

    final uid = _uid;
    if (uid == null) return;
    await _service.addItem(uid, item);
  }

  Future<void> increaseQuantity(CartItem item) => addItem(item);
  Future<void> decreaseQuantity(String productId) => decrementItem(productId);
  Future<void> removeFromCart(String productId) => removeItem(productId);

  void _addItemLocally(CartItem item) {
    final index = _items.indexWhere((i) => i.productId == item.productId);
    if (index >= 0) {
      _items[index].quantity += 1;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  Future<void> removeItem(String productId) async {
    _items.removeWhere((i) => i.productId == productId);
    notifyListeners();

    if (_shouldUseMock) {
      return;
    }

    final uid = _uid;
    if (uid == null) return;
    await _service.removeItem(uid, productId);
  }

  Future<void> decrementItem(String productId) async {
    final index = _items.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }

    if (_shouldUseMock) {
      return;
    }

    final uid = _uid;
    if (uid == null) return;
    await _service.decrementItem(uid, productId);
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();

    if (_shouldUseMock) {
      return;
    }

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
