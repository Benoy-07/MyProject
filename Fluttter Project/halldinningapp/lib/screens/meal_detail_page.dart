// meal_detail_page.dart - CORRECTED
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/menu_service.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';

class MealDetailPage extends StatelessWidget {
  final String meal;
  const MealDetailPage({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart, color: Colors.black87),
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent, 
                      shape: BoxShape.circle, 
                      border: Border.all(color: Colors.white, width: 1.5)
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Center(
                      child: Text(
                        '${context.watch<CartService2>().items.length}',
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 11, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getGradientColors(meal),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: MenuService.getMenuForMeal(meal),
          builder: (context, snapshot) {
            // Handle different states
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              print('❌ Error in StreamBuilder: ${snapshot.error}');
              // Use fallback data when there's an error
              final fallbackItems = MenuService.getMenuForMealFallback(meal);
              return _buildMenuList(fallbackItems, context);
            }

            // Check if we have data
            if (!snapshot.hasData) {
              final fallbackItems = MenuService.getMenuForMealFallback(meal);
              return _buildMenuList(fallbackItems, context);
            }

            final items = snapshot.data!;
            return _buildMenuList(items, context);
          },
        ),
      ),
    );
  }

  Widget _buildMenuList(List<Map<String, dynamic>> items, BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No $meal items available',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later for today\'s menu',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = items[index];
        final price = (item['price'] as num).toDouble();
        final itemName = item['name'] ?? 'Unknown Item';
        final description = item['description'] ?? '';

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                // Item Image/Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: _getItemGradient(item['category']),
                  ),
                  child: item['imageUrl'] != null && (item['imageUrl'] as String).isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item['imageUrl'] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildFallbackIcon(item['category']),
                          ),
                        )
                      : _buildFallbackIcon(item['category']),
                ),
                const SizedBox(width: 16),
                
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _buildCategoryChip(item['category']),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                
                // Price and Add Button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '৳${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        final cartItem = CartItem(
                          id: item['id'] ?? '${itemName}_${DateTime.now().millisecondsSinceEpoch}',
                          name: itemName,
                          meal: meal,
                          price: price,
                          category: item['category'] ?? '',
                        );
                        context.read<CartService2>().addItem(cartItem);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$itemName added to cart'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getButtonColor(meal),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: items.length,
    );
  }

  Widget _buildFallbackIcon(String category) {
    IconData icon;
    switch (category) {
      case 'main_course':
        icon = Icons.restaurant;
      case 'breakfast':
        icon = Icons.breakfast_dining;
      case 'lunch':
        icon = Icons.lunch_dining;
      case 'dinner':
        icon = Icons.dinner_dining;
      case 'beverage':
        icon = Icons.local_drink;
      case 'dessert':
        icon = Icons.cake;
      default:
        icon = Icons.fastfood;
    }
    
    return Icon(icon, color: Colors.white, size: 30);
  }

  Widget _buildCategoryChip(String category) {
    final categoryLabels = {
      'main_course': 'Main Course',
      'side_dish': 'Side Dish',
      'dessert': 'Dessert',
      'beverage': 'Beverage',
      'breakfast': 'Breakfast',
      'lunch': 'Lunch',
      'dinner': 'Dinner',
    };
    
    final label = categoryLabels[category] ?? category;
    
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      backgroundColor: _getChipColor(category),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  List<Color> _getGradientColors(String meal) {
    switch (meal.toLowerCase()) {
      case 'breakfast':
        return [Colors.orange.shade50, Colors.yellow.shade50];
      case 'lunch':
        return [Colors.green.shade50, Colors.teal.shade50];
      case 'dinner':
        return [Colors.indigo.shade50, Colors.purple.shade50];
      default:
        return [Colors.grey.shade50, Colors.blueGrey.shade50];
    }
  }

  LinearGradient _getItemGradient(String category) {
    switch (category) {
      case 'main_course':
        return const LinearGradient(colors: [Colors.deepPurple, Colors.blue]);
      case 'breakfast':
        return const LinearGradient(colors: [Colors.orange, Colors.amber]);
      case 'lunch':
        return const LinearGradient(colors: [Colors.green, Colors.teal]);
      case 'dinner':
        return const LinearGradient(colors: [Colors.indigo, Colors.purple]);
      case 'dessert':
        return const LinearGradient(colors: [Colors.pink, Colors.purple]);
      case 'beverage':
        return const LinearGradient(colors: [Colors.blue, Colors.lightBlue]);
      default:
        return const LinearGradient(colors: [Colors.grey, Colors.blueGrey]);
    }
  }

  Color _getButtonColor(String meal) {
    switch (meal.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }

  Color _getChipColor(String category) {
    switch (category) {
      case 'main_course':
        return Colors.deepPurple;
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.indigo;
      case 'dessert':
        return Colors.pink;
      case 'beverage':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}