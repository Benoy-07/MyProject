class CartItem {
  final String id;
  final String name;
  final String meal; // Breakfast/Lunch/Dinner
  final double price;
  int quantity;
  final String category;
  final String? imageUrl;

  CartItem({
    required this.id,
    required this.name,
    required this.meal,
    required this.price,
    this.quantity = 1,
    this.category = '',
    this.imageUrl,
  });

  // Backwards-compatible alias used in parts of the codebase
  String get itemName => name;

  double get total => price * quantity;
}
