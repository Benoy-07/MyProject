import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_model.dart';
import '../../providers/menu_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';

class MenuDetailScreen extends StatelessWidget {
  final MenuItem menuItem;

  const MenuDetailScreen({
    Key? key,
    required this.menuItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(menuItem.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (menuItem.imageUrl != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(menuItem.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fastfood,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),

            const SizedBox(height: 16),

            // Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '৳${menuItem.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                if (menuItem.rating > 0)
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${menuItem.rating} (${menuItem.ratingCount})',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              menuItem.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            // Dietary Tags
            if (menuItem.dietaryTags.isNotEmpty) ...[
              Text(
                languageProvider.isBengali ? 'ডায়েটারি ট্যাগস' : 'Dietary Tags',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: menuItem.dietaryTags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Allergens
            if (menuItem.allergens.isNotEmpty) ...[
              Text(
                languageProvider.isBengali ? 'অ্যালার্জেন' : 'Allergens',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: menuItem.allergens
                    .map((allergen) => Chip(
                          label: Text(
                            allergen,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: AppColors.error,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Nutrition Information
            if (menuItem.nutritionInfo != null && menuItem.nutritionInfo!.isNotEmpty) ...[
              Text(
                languageProvider.isBengali ? 'পুষ্টির তথ্য' : 'Nutrition Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: menuItem.nutritionInfo!.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            entry.value.toString(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Add to Cart Button
            CustomButton(
              text: languageProvider.isBengali ? 'কার্টে যোগ করুন' : 'Add to Cart',
              onPressed: () {
                Provider.of<MenuProvider>(context, listen: false).addToCart(menuItem);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      languageProvider.isBengali 
                          ? '${menuItem.name} কার্টে যোগ করা হয়েছে'
                          : '${menuItem.name} added to cart',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}