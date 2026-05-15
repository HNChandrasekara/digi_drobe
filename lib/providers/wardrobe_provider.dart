import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/wardrobe_item.dart';
import '../services/wardrobe_service.dart';

class WardrobeProvider extends ChangeNotifier {
  final WardrobeService _service = WardrobeService();

  List<WardrobeItem> _items = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<WardrobeItem>>? _sub;

  List<WardrobeItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WardrobeProvider() {
    // Re-init whenever auth state changes (login / logout)
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _startStream();
      } else {
        _sub?.cancel();
        _items = [];
        _isLoading = false;
        notifyListeners();
      }
    });
    // Also start now if already logged in
    if (FirebaseAuth.instance.currentUser != null) {
      _startStream();
    }
  }

  void _startStream() {
    _isLoading = true;
    notifyListeners();

    _sub?.cancel();
    _sub = _service.getWardrobeStream().listen(
      (list) {
        _items = list;
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

  // ── Filtered helpers ─────────────────────────────────────────────────────────
  List<WardrobeItem> byCategory(String category) {
    if (category == 'All') return _items;
    return _items.where((i) => i.category == category).toList();
  }

  List<WardrobeItem> search(String query, {String category = 'All'}) {
    var base = byCategory(category);
    if (query.isEmpty) return base;
    final q = query.toLowerCase();
    return base
        .where((i) =>
            i.title.toLowerCase().contains(q) ||
            i.brand.toLowerCase().contains(q) ||
            i.category.toLowerCase().contains(q))
        .toList();
  }

  List<String> get categories {
    final cats = _items.map((i) => i.category).toSet().toList();
    cats.sort();
    return cats;
  }

  int countByCategory(String category) {
    if (category == 'All') return _items.length;
    return _items.where((i) => i.category == category).length;
  }

  // ── CRUD wrappers ────────────────────────────────────────────────────────────
  Future<void> addItem(WardrobeItem item) => _service.addItem(item);
  Future<void> deleteItem(String id) => _service.deleteItem(id);
  Future<void> updateItem(WardrobeItem item) => _service.updateItem(item);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
