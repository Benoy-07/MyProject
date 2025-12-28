// cart_service2.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/cart_item.dart';

class CartService2 with ChangeNotifier {
  final List<CartItem> _items = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CartItem> get items => List.unmodifiable(_items);
  double get total => _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  void addItem(CartItem item) {
    final existing = _items.indexWhere((i) => i.id == item.id || i.name == item.name);
    if (existing >= 0) {
      _items[existing].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  final List<List<CartItem>> _orderHistory = [];
  List<List<CartItem>> get orderHistory => List.unmodifiable(_orderHistory);

  // Backwards-compatible: accept map-based items
  void addToCart(Map<String, dynamic> itemMap, int quantity) {
    final id = itemMap['id'] ?? '${itemMap['name'] ?? 'item'}_${DateTime.now().millisecondsSinceEpoch}';
    final cartItem = CartItem(
      id: id,
      name: itemMap['name'] ?? itemMap['itemName'] ?? 'Unknown',
      meal: itemMap['meal'] ?? '',
      price: (itemMap['price'] as num?)?.toDouble() ?? 0.0,
      quantity: quantity,
      category: itemMap['category'] ?? '',
      imageUrl: itemMap['imageUrl'],
    );
    addItem(cartItem);
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void removeItem(CartItem item) {
    _items.removeWhere((i) => i.id == item.id);
    notifyListeners();
  }

  void changeQuantity(CartItem item, int newQuantity) {
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx < 0) return;
    if (newQuantity <= 0) {
      _items.removeAt(idx);
    } else {
      _items[idx].quantity = newQuantity;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Alias used in some widgets
  void clear() => clearCart();

  Future<void> placeOrder({required String userName, required String userEmail, required String userHall}) async {
    if (_items.isEmpty) throw Exception('Cart is empty');

    try {
      final orderData = {
        'userName': userName,
        'userEmail': userEmail,
        'userHall': userHall,
        'items': _items.map((item) => {
              'itemName': item.name,
              'price': item.price,
              'quantity': item.quantity,
              'imageUrl': item.imageUrl,
            }).toList(),
        'totalAmount': total,
        'status': 'pending',
        'paymentStatus': 'completed',
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'orderTime': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      await _firestore.collection('orders').add(orderData);
      // Save a copy of the current cart to order history before clearing
      final snapshot = _items.map((e) => CartItem(
        id: e.id,
        name: e.name,
        meal: e.meal,
        price: e.price,
        quantity: e.quantity,
        category: e.category,
        imageUrl: e.imageUrl,
          )).toList();
      _orderHistory.add(snapshot);
      clearCart();
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }
}
