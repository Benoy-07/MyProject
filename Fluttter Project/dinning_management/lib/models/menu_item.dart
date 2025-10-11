class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final double rating;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.rating = 0.0,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> m, String id) {
    return MenuItemModel(
      id: id,
      name: m['name'] ?? '',
      description: m['description'] ?? '',
      price: (m['price'] ?? 0).toDouble(),
      category: m['category'] ?? '',
      imageUrl: m['imageUrl'] ?? '',
      rating: (m['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'price': price,
    'category': category,
    'imageUrl': imageUrl,
    'rating': rating,
  };
}
