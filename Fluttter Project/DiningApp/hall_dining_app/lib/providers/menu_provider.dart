import 'package:flutter/foundation.dart';
import '../models/menu_model.dart';
import '../services/firestore_service.dart';

class MenuProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<DailyMenu> _dailyMenus = [];
  List<MenuItem> _featuredItems = [];
  List<MenuItem> _cartItems = [];
  DailyMenu? _todaysMenu;
  bool _isLoading = false;
  String _error = '';
  String _selectedCategory = 'lunch';
  DateTime _selectedDate = DateTime.now();

  List<DailyMenu> get dailyMenus => _dailyMenus;
  List<MenuItem> get featuredItems => _featuredItems;
  List<MenuItem> get cartItems => _cartItems;
  DailyMenu? get todaysMenu => _todaysMenu;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get selectedCategory => _selectedCategory;
  DateTime get selectedDate => _selectedDate;

  double get cartTotal {
    return _cartItems.fold(0, (total, item) => total + item.price);
  }

  int get cartItemCount {
    return _cartItems.length;
  }

  // Initialize provider
  void initialize() {
    loadTodaysMenu();
    _loadFeaturedItems();
  }

  // Load today's menu
  Future<void> loadTodaysMenu() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _firestoreService.getTodaysMenuStream().listen((menus) {
        _todaysMenu = menus.isNotEmpty ? menus.first : null;
        _isLoading = false;
        notifyListeners();
      }, onError: (error) {
        _error = 'Failed to load menu: $error';
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Failed to load menu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load featured menu items
  Future<void> _loadFeaturedItems() async {
    try {
      if (_todaysMenu != null) {
        _featuredItems = [
          ..._todaysMenu!.breakfast.where((item) => item.isFeatured),
          ..._todaysMenu!.lunch.where((item) => item.isFeatured),
          ..._todaysMenu!.dinner.where((item) => item.isFeatured),
        ].take(6).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Failed to load featured items: $e');
    }
  }

  // Load weekly menu
  Future<void> loadWeeklyMenu(DateTime startDate) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _dailyMenus = await _firestoreService.getWeeklyMenu(startDate);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load weekly menu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add menu item
  Future<void> addMenuItem(MenuItem item) async {
    try {
      await _firestoreService.addMenuItem(item);
      await loadTodaysMenu(); // Refresh menu after adding
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add menu item: $e';
      notifyListeners();
    }
  }

  // Update menu item
  Future<void> updateMenuItem(MenuItem item) async {
    try {
      await _firestoreService.updateMenuItem(item);
      await loadTodaysMenu(); // Refresh menu after updating
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update menu item: $e';
      notifyListeners();
    }
  }

  // Delete menu item
  Future<void> deleteMenuItem(String itemId) async {
    try {
      await _firestoreService.deleteMenuItem(itemId);
      await loadTodaysMenu(); // Refresh menu after deleting
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete menu item: $e';
      notifyListeners();
    }
  }

  // Get menu items by category for selected date
  List<MenuItem> getMenuByCategory(String category) {
    if (_todaysMenu == null) return [];
    
    switch (category) {
      case 'breakfast':
        return _todaysMenu!.breakfast;
      case 'lunch':
        return _todaysMenu!.lunch;
      case 'dinner':
        return _todaysMenu!.dinner;
      default:
        return [];
    }
  }

  // Set selected category
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Add item to cart
  void addToCart(MenuItem item) {
    _cartItems.add(item);
    notifyListeners();
  }

  // Remove item from cart
  void removeFromCart(MenuItem item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  // Remove item from cart by index
  void removeFromCartByIndex(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }

  // Clear cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Check if item is in cart
  bool isInCart(MenuItem item) {
    return _cartItems.any((cartItem) => cartItem.id == item.id);
  }

  // Get item count in cart
  int getItemCountInCart(MenuItem item) {
    return _cartItems.where((cartItem) => cartItem.id == item.id).length;
  }

  // Search menu items
  List<MenuItem> searchMenuItems(String query) {
    if (_todaysMenu == null) return [];
    
    final allItems = [
      ..._todaysMenu!.breakfast,
      ..._todaysMenu!.lunch,
      ..._todaysMenu!.dinner,
    ];
    
    return allItems.where((item) =>
      item.name.toLowerCase().contains(query.toLowerCase()) ||
      item.description.toLowerCase().contains(query.toLowerCase()) ||
      item.dietaryTags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }

  // Filter menu items by dietary restrictions
  List<MenuItem> filterMenuItems({
    List<String>? dietaryTags,
    double? maxPrice,
    String? category,
  }) {
    if (_todaysMenu == null) return [];
    
    List<MenuItem> allItems = [];
    
    if (category == null || category == 'all') {
      allItems = [
        ..._todaysMenu!.breakfast,
        ..._todaysMenu!.lunch,
        ..._todaysMenu!.dinner,
      ];
    } else {
      allItems = getMenuByCategory(category);
    }
    
    return allItems.where((item) {
      if (dietaryTags != null && dietaryTags.isNotEmpty) {
        final hasAllTags = dietaryTags.every((tag) => item.dietaryTags.contains(tag));
        if (!hasAllTags) return false;
      }
      
      if (maxPrice != null && item.price > maxPrice) {
        return false;
      }
      
      return true;
    }).toList();
  }

  // Get available categories for today
  List<String> getAvailableCategories() {
    final categories = <String>[];
    
    if (_todaysMenu?.hasBreakfast ?? false) {
      categories.add('breakfast');
    }
    if (_todaysMenu?.hasLunch ?? false) {
      categories.add('lunch');
    }
    if (_todaysMenu?.hasDinner ?? false) {
      categories.add('dinner');
    }
    
    return categories;
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Refresh menu data
  Future<void> refreshMenu() async {
    loadTodaysMenu();
    _loadFeaturedItems();
  }
}