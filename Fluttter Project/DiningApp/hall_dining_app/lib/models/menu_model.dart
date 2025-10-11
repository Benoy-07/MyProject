class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category; // breakfast, lunch, dinner
  final String? imageUrl;
  final bool isAvailable;
  final Map<String, dynamic>? nutritionInfo;
  final List<String> dietaryTags; // vegetarian, vegan, gluten-free, etc.
  final List<String> allergens;
  final int preparationTime; // in minutes
  final double rating;
  final int ratingCount;
  final bool isFeatured;
  final int stockQuantity;
  final DateTime? availableUntil;
  final Map<String, dynamic>? customizations;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    this.isAvailable = true,
    this.nutritionInfo,
    this.dietaryTags = const [],
    this.allergens = const [],
    this.preparationTime = 15,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.isFeatured = false,
    this.stockQuantity = 100,
    this.availableUntil,
    this.customizations,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'nutritionInfo': nutritionInfo ?? {},
      'dietaryTags': dietaryTags,
      'allergens': allergens,
      'preparationTime': preparationTime,
      'rating': rating,
      'ratingCount': ratingCount,
      'isFeatured': isFeatured,
      'stockQuantity': stockQuantity,
      'availableUntil': availableUntil?.millisecondsSinceEpoch,
      'customizations': customizations ?? {},
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'],
      isAvailable: map['isAvailable'] ?? true,
      nutritionInfo: map['nutritionInfo'] ?? {},
      dietaryTags: List<String>.from(map['dietaryTags'] ?? []),
      allergens: List<String>.from(map['allergens'] ?? []),
      preparationTime: map['preparationTime'] ?? 15,
      rating: (map['rating'] ?? 0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
      isFeatured: map['isFeatured'] ?? false,
      stockQuantity: map['stockQuantity'] ?? 100,
      availableUntil: map['availableUntil'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['availableUntil'])
          : null,
      customizations: map['customizations'] ?? {},
    );
  }

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? isAvailable,
    Map<String, dynamic>? nutritionInfo,
    List<String>? dietaryTags,
    List<String>? allergens,
    int? preparationTime,
    double? rating,
    int? ratingCount,
    bool? isFeatured,
    int? stockQuantity,
    DateTime? availableUntil,
    Map<String, dynamic>? customizations,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      allergens: allergens ?? this.allergens,
      preparationTime: preparationTime ?? this.preparationTime,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      isFeatured: isFeatured ?? this.isFeatured,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      availableUntil: availableUntil ?? this.availableUntil,
      customizations: customizations ?? this.customizations,
    );
  }

  // Helper methods
  bool get isVegetarian => dietaryTags.contains('vegetarian');
  bool get isVegan => dietaryTags.contains('vegan');
  bool get isGlutenFree => dietaryTags.contains('gluten-free');
  bool get isSpicy => dietaryTags.contains('spicy');
  
  double get discountedPrice {
    // You can implement discount logic here
    return price;
  }
}

class DailyMenu {
  final String id;
  final DateTime date;
  final List<MenuItem> breakfast;
  final List<MenuItem> lunch;
  final List<MenuItem> dinner;
  final bool isSpecialDay;
  final String? specialEvent;
  final String? specialEventDescription;
  final double? specialEventPrice;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DailyMenu({
    required this.id,
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    this.isSpecialDay = false,
    this.specialEvent,
    this.specialEventDescription,
    this.specialEventPrice,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'breakfast': breakfast.map((item) => item.toMap()).toList(),
      'lunch': lunch.map((item) => item.toMap()).toList(),
      'dinner': dinner.map((item) => item.toMap()).toList(),
      'isSpecialDay': isSpecialDay,
      'specialEvent': specialEvent,
      'specialEventDescription': specialEventDescription,
      'specialEventPrice': specialEventPrice,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory DailyMenu.fromMap(Map<String, dynamic> map) {
    return DailyMenu(
      id: map['id'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      breakfast: List<MenuItem>.from(
        (map['breakfast'] ?? []).map((item) => MenuItem.fromMap(item)),
      ),
      lunch: List<MenuItem>.from(
        (map['lunch'] ?? []).map((item) => MenuItem.fromMap(item)),
      ),
      dinner: List<MenuItem>.from(
        (map['dinner'] ?? []).map((item) => MenuItem.fromMap(item)),
      ),
      isSpecialDay: map['isSpecialDay'] ?? false,
      specialEvent: map['specialEvent'],
      specialEventDescription: map['specialEventDescription'],
      specialEventPrice: map['specialEventPrice']?.toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }

  List<MenuItem> getMenuByCategory(String category) {
    switch (category) {
      case 'breakfast':
        return breakfast;
      case 'lunch':
        return lunch;
      case 'dinner':
        return dinner;
      default:
        return [];
    }
  }

  bool get hasBreakfast => breakfast.isNotEmpty;
  bool get hasLunch => lunch.isNotEmpty;
  bool get hasDinner => dinner.isNotEmpty;
}

class MenuCategory {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final int displayOrder;
  final bool isActive;
  final DateTime createdAt;

  MenuCategory({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.displayOrder = 0,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory MenuCategory.fromMap(Map<String, dynamic> map) {
    return MenuCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      displayOrder: map['displayOrder'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}