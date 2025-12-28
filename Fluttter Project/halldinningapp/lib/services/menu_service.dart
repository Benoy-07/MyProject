// services/menu_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get menu items for a specific meal type from Firestore
  static Stream<List<Map<String, dynamic>>> getMenuForMeal(String mealType) {
    // Convert meal type to lowercase for consistency
    String formattedMealType = mealType.toLowerCase();
    String todayDate = _getTodayDate();
    
    print('🔄 Fetching menu for: $formattedMealType on date: $todayDate');
    
    return _firestore
        .collection('menus')
        .where('mealType', isEqualTo: formattedMealType)
        .where('date', isEqualTo: todayDate)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) {
      // Convert QuerySnapshot to List<Map<String, dynamic>>
      List<Map<String, dynamic>> items = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        items.add({
          'id': doc.id,
          'name': data['itemName'] ?? 'No Name',
          'description': data['description'] ?? '',
          'price': (data['price'] ?? 0.0).toDouble(),
          'category': data['category'] ?? '',
          'mealType': data['mealType'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'isAvailable': data['isAvailable'] ?? true,
        });
      }
      
      print('✅ Found ${items.length} items for $formattedMealType');
      return items;
    });
  }

  // Get all available meal types from Firestore for today
  static Stream<List<String>> getAvailableMealTypes() {
    String todayDate = _getTodayDate();
    
    return _firestore
        .collection('menus')
        .where('date', isEqualTo: todayDate)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) {
      final mealTypes = <String>{};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final mealType = data['mealType']?.toString() ?? '';
        if (mealType.isNotEmpty) {
          // Capitalize first letter for display
          final capitalizedMeal = mealType[0].toUpperCase() + mealType.substring(1);
          mealTypes.add(capitalizedMeal);
        }
      }
      
      // If no meal types found, return default ones
      if (mealTypes.isEmpty) {
        return ['Breakfast', 'Lunch', 'Dinner'];
      }
      
      print('📊 Available meal types: ${mealTypes.toList()}');
      return mealTypes.toList();
    });
  }

  // Get menu items for a specific meal type (Future version for one-time read)
  static Future<List<Map<String, dynamic>>> getMenuForMealOnce(String mealType) async {
    try {
      String formattedMealType = mealType.toLowerCase();
      String todayDate = _getTodayDate();
      
      final snapshot = await _firestore
          .collection('menus')
          .where('mealType', isEqualTo: formattedMealType)
          .where('date', isEqualTo: todayDate)
          .where('isAvailable', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> items = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        items.add({
          'id': doc.id,
          'name': data['itemName'] ?? 'No Name',
          'description': data['description'] ?? '',
          'price': (data['price'] ?? 0.0).toDouble(),
          'category': data['category'] ?? '',
          'mealType': data['mealType'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'isAvailable': data['isAvailable'] ?? true,
        });
      }
      
      return items;
    } catch (e) {
      print('❌ Error fetching menu for $mealType: $e');
      return getMenuForMealFallback(mealType);
    }
  }

  // Get all menus for today (for admin or overview)
  static Stream<Map<String, List<Map<String, dynamic>>>> getAllMenus() {
    String todayDate = _getTodayDate();
    
    return _firestore
        .collection('menus')
        .where('date', isEqualTo: todayDate)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) {
      final menus = <String, List<Map<String, dynamic>>>{};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final mealType = data['mealType']?.toString() ?? 'other';
        final capitalizedMeal = mealType[0].toUpperCase() + mealType.substring(1);
        
        final item = {
          'id': doc.id,
          'name': data['itemName'] ?? 'No Name',
          'description': data['description'] ?? '',
          'price': (data['price'] ?? 0.0).toDouble(),
          'category': data['category'] ?? '',
          'mealType': data['mealType'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'isAvailable': data['isAvailable'] ?? true,
        };
        
        if (!menus.containsKey(capitalizedMeal)) {
          menus[capitalizedMeal] = [];
        }
        menus[capitalizedMeal]!.add(item);
      }
      
      return menus;
    });
  }

  // Add new menu item to Firestore (for admin)
  static Future<void> addMenuItem({
    required String itemName,
    required String description,
    required double price,
    required String mealType,
    required String category,
    String? imageUrl,
    bool isAvailable = true,
  }) async {
    try {
      final newItem = {
        'itemName': itemName,
        'description': description,
        'price': price,
        'mealType': mealType.toLowerCase(),
        'category': category,
        'imageUrl': imageUrl ?? '',
        'isAvailable': isAvailable,
        'date': _getTodayDate(),
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection('menus').add(newItem);
      print('✅ Menu item added: $itemName');
    } catch (e) {
      print('❌ Error adding menu item: $e');
      throw e;
    }
  }

  // Update menu item in Firestore (for admin)
  static Future<void> updateMenuItem({
    required String itemId,
    String? itemName,
    String? description,
    double? price,
    String? mealType,
    String? category,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (itemName != null) updateData['itemName'] = itemName;
      if (description != null) updateData['description'] = description;
      if (price != null) updateData['price'] = price;
      if (mealType != null) updateData['mealType'] = mealType.toLowerCase();
      if (category != null) updateData['category'] = category;
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;
      if (isAvailable != null) updateData['isAvailable'] = isAvailable;
      
      updateData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('menus').doc(itemId).update(updateData);
      print('✅ Menu item updated: $itemId');
    } catch (e) {
      print('❌ Error updating menu item: $e');
      throw e;
    }
  }

  // Delete menu item from Firestore (for admin)
  static Future<void> deleteMenuItem(String itemId) async {
    try {
      await _firestore.collection('menus').doc(itemId).delete();
      print('✅ Menu item deleted: $itemId');
    } catch (e) {
      print('❌ Error deleting menu item: $e');
      throw e;
    }
  }

  // Get today's date in YYYY-MM-DD format
  static String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // Fallback method - if Firestore is not available, use in-memory data
  static List<Map<String, dynamic>> getMenuForMealFallback(String meal) {
    final Map<String, List<Map<String, dynamic>>> _fallbackMenus = {
      'Breakfast': [
        {
          'name': 'Paratha',
          'description': 'Layered flatbread served hot with butter.',
          'price': 25.0,
          'category': 'breakfast',
          'id': 'fallback_breakfast_1',
          'mealType': 'breakfast',
          'isAvailable': true,
        },
        {
          'name': 'Omelette',
          'description': 'Fresh eggs with herbs and spices.',
          'price': 30.0,
          'category': 'breakfast',
          'id': 'fallback_breakfast_2',
          'mealType': 'breakfast',
          'isAvailable': true,
        },
        {
          'name': 'Tea', 
          'description': 'Strong milky tea with sugar.', 
          'price': 10.0,
          'category': 'beverage',
          'id': 'fallback_breakfast_3',
          'mealType': 'breakfast',
          'isAvailable': true,
        },
      ],
      'Lunch': [
        {
          'name': 'Steamed Rice', 
          'description': 'Fragrant basmati rice.', 
          'price': 40.0,
          'category': 'main_course',
          'id': 'fallback_lunch_1',
          'mealType': 'lunch',
          'isAvailable': true,
        },
        {
          'name': 'Chicken Curry', 
          'description': 'Tender chicken simmered in spices.', 
          'price': 85.0,
          'category': 'main_course',
          'id': 'fallback_lunch_2',
          'mealType': 'lunch',
          'isAvailable': true,
        },
        {
          'name': 'Mixed Veg', 
          'description': 'Seasonal vegetables cooked with light masala.', 
          'price': 60.0,
          'category': 'side_dish',
          'id': 'fallback_lunch_3',
          'mealType': 'lunch',
          'isAvailable': true,
        },
      ],
      'Dinner': [
        {
          'name': 'Naan', 
          'description': 'Oven-baked flatbread.', 
          'price': 20.0,
          'category': 'main_course',
          'id': 'fallback_dinner_1',
          'mealType': 'dinner',
          'isAvailable': true,
        },
        {
          'name': 'Beef Kebab', 
          'description': 'Spiced kebabs grilled to perfection.', 
          'price': 120.0,
          'category': 'main_course',
          'id': 'fallback_dinner_2',
          'mealType': 'dinner',
          'isAvailable': true,
        },
        {
          'name': 'Salad', 
          'description': 'Fresh garden salad with house dressing.', 
          'price': 35.0,
          'category': 'side_dish',
          'id': 'fallback_dinner_3',
          'mealType': 'dinner',
          'isAvailable': true,
        },
      ],
    };

    return List<Map<String, dynamic>>.from(_fallbackMenus[meal] ?? []);
  }
}