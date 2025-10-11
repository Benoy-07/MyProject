import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:provider/provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import 'menu_detail_screen.dart';

class MenuListScreen extends StatefulWidget {
  const MenuListScreen({Key? key}) : super(key: key);

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  String _selectedCategory = 'lunch';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    menuProvider.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: languageProvider.isBengali ? 'মেনু আইটেম খুঁজুন...' : 'Search menu items...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Category Selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryButton(
                  languageProvider.isBengali ? 'সকালের নাস্তা' : 'Breakfast',
                  'breakfast',
                  languageProvider,
                ),
                const SizedBox(width: 8),
                _buildCategoryButton(
                  languageProvider.isBengali ? 'দুপুরের খাবার' : 'Lunch',
                  'lunch',
                  languageProvider,
                ),
                const SizedBox(width: 8),
                _buildCategoryButton(
                  languageProvider.isBengali ? 'রাতের খাবার' : 'Dinner',
                  'dinner',
                  languageProvider,
                ),
              ],
            ),
          ),
        ),

        // Menu Items
        Expanded(
          child: menuProvider.isLoading
              ? const LoadingWidget(message: 'Loading menu...')
              : menuProvider.error.isNotEmpty
                  ? ErrorWidget(
                      title: 'Error',
                      message: menuProvider.error,
                      buttonText: 'Retry',
                      onRetry: () => menuProvider.refreshMenu(),
                    )
                  : _buildMenuList(menuProvider, languageProvider),
        ),
      ],
    );
  }

  Widget _buildCategoryButton(String label, String category, LanguageProvider languageProvider) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedCategory == category,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = category;
        });
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: _selectedCategory == category ? Colors.white : null,
      ),
    );
  }

  Widget _buildMenuList(MenuProvider menuProvider, LanguageProvider languageProvider) {
    List menuItems = menuProvider.getMenuByCategory(_selectedCategory);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      menuItems = menuProvider.searchMenuItems(_searchQuery);
    }

    if (menuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              languageProvider.isBengali ? 'কোন মেনু আইটেম পাওয়া যায়নি' : 'No menu items found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              languageProvider.isBengali 
                  ? 'অনুগ্রহ করে পরে আবার চেষ্টা করুন'
                  : 'Please try again later',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: item.imageUrl != null
                ? CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(item.imageUrl!),
                  )
                : CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.fastfood,
                      color: AppColors.primary,
                    ),
                  ),
            title: Text(item.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '৳${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                if (item.dietaryTags.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: item.dietaryTags
                        .map((tag) => Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(fontSize: 10),
                              ),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              color: AppColors.primary,
              onPressed: () {
                _showAddToCartDialog(item, languageProvider);
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuDetailScreen(menuItem: item),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showAddToCartDialog(item, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('৳${item.price.toStringAsFixed(2)}'),
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(languageProvider.isBengali ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<MenuProvider>(context, listen: false).addToCart(item);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    languageProvider.isBengali 
                        ? '${item.name} কার্টে যোগ করা হয়েছে'
                        : '${item.name} added to cart',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(languageProvider.isBengali ? 'কার্টে যোগ করুন' : 'Add to Cart'),
          ),
        ],
      ),
    );
  }
}