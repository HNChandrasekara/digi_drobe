import 'package:flutter/material.dart';
import '../models/thrift_item.dart';
import '../services/thrift_service.dart';

class ThriftProvider extends ChangeNotifier {
  final ThriftService _service = ThriftService();
  List<ThriftItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<ThriftItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ThriftProvider() {
    _init();
    _service.seedIfEmpty();
  }

  void _init() {
    _isLoading = true;
    notifyListeners();

    _service.getThriftItemsStream().listen(
      (data) {
        _items = data;
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

  Future<void> addItem(ThriftItem item) async {
    try {
      await _service.addThriftItem(item);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _service.deleteThriftItem(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
