import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_model.dart';
import '../../providers/menu_provider.dart';
import '../../core/widgets/custom_button.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _preparationTimeController = TextEditingController();
  final _stockQuantityController = TextEditingController();

  String _selectedCategory = 'breakfast';
  bool _isAvailable = true;
  bool _isFeatured = false;
  bool _isEditing = false;
  String? _editingItemId;
  List<String> _dietaryTags = [];
  List<String> _allergens = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).loadTodaysMenu();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _preparationTimeController.dispose();
    _stockQuantityController.dispose();
    super.dispose();
  }

  void _startAddItem() {
    setState(() {
      _isEditing = false;
      _editingItemId = null;
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _preparationTimeController.clear();
      _stockQuantityController.clear();
      _selectedCategory = 'breakfast';
      _isAvailable = true;
      _isFeatured = false;
      _dietaryTags = [];
      _allergens = [];
    });
    _showItemDialog();
  }

  void _editItem(MenuItem item) {
    setState(() {
      _isEditing = true;
      _editingItemId = item.id;
      _nameController.text = item.name;
      _descriptionController.text = item.description;
      _priceController.text = item.price.toString();
      _preparationTimeController.text = item.preparationTime.toString();
      _stockQuantityController.text = item.stockQuantity.toString();
      _selectedCategory = item.category;
      _isAvailable = item.isAvailable;
      _isFeatured = item.isFeatured;
      _dietaryTags = List.from(item.dietaryTags);
      _allergens = List.from(item.allergens);
    });
    _showItemDialog();
  }

  void _showItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isEditing ? 'Edit Menu Item' : 'Add Menu Item'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _preparationTimeController,
                  decoration: const InputDecoration(labelText: 'Preparation Time (minutes)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter preparation time';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter valid preparation time';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stockQuantityController,
                  decoration: const InputDecoration(labelText: 'Stock Quantity'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter stock quantity';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter valid stock quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: const [
                    DropdownMenuItem(value: 'breakfast', child: Text('Breakfast')),
                    DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
                    DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                  },
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Available'),
                  value: _isAvailable,
                  onChanged: (value) {
                    setState(() => _isAvailable = value);
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Featured'),
                  value: _isFeatured,
                  onChanged: (value) {
                    setState(() => _isFeatured = value);
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveItem,
            child: Text(_isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) return;

    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    final item = MenuItem(
      id: _isEditing ? _editingItemId! : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      category: _selectedCategory,
      imageUrl: null, // TODO: Add image upload
      isAvailable: _isAvailable,
      isFeatured: _isFeatured,
      preparationTime: int.parse(_preparationTimeController.text),
      stockQuantity: int.parse(_stockQuantityController.text),
      dietaryTags: _dietaryTags, // TODO: Add dietary tags input
      allergens: _allergens, // TODO: Add allergens input
      nutritionInfo: {}, // TODO: Add nutrition info input
      customizations: {}, // TODO: Add customizations input
    );

    if (_isEditing) {
      menuProvider.updateMenuItem(item);
    } else {
      menuProvider.addMenuItem(item);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item ${_isEditing ? 'updated' : 'added'} successfully')),
    );
  }

  void _deleteItem(MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<MenuProvider>(context, listen: false).deleteMenuItem(item.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Menu'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Breakfast'),
            Tab(text: 'Lunch'),
            Tab(text: 'Dinner'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startAddItem,
        child: const Icon(Icons.add),
      ),
      body: menuProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : menuProvider.todaysMenu == null
              ? const Center(child: Text('No menu available for today'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCategoryList(menuProvider.todaysMenu!.breakfast),
                    _buildCategoryList(menuProvider.todaysMenu!.lunch),
                    _buildCategoryList(menuProvider.todaysMenu!.dinner),
                  ],
                ),
    );
  }

  Widget _buildCategoryList(List<MenuItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: item.imageUrl != null && (item.imageUrl?.isNotEmpty ?? false)
                    ? DecorationImage(
                        image: NetworkImage(item.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey[200],
              ),
              child: item.imageUrl == null || (item.imageUrl?.isEmpty ?? true)
                  ? Icon(Icons.restaurant, color: Colors.grey[400])
                  : null,
            ),
            title: Text(item.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.description),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '৳${item.price}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.isAvailable ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.isAvailable ? 'Available' : 'Unavailable',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (item.isFeatured) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Featured',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete'),
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: ListTile(
                    leading: Icon(
                      item.isAvailable ? Icons.block : Icons.check_circle,
                      color: item.isAvailable ? Colors.red : Colors.green,
                    ),
                    title: Text(item.isAvailable ? 'Make Unavailable' : 'Make Available'),
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editItem(item);
                    break;
                  case 'delete':
                    _deleteItem(item);
                    break;
                  case 'toggle':
                    final updatedItem = item.copyWith(
                      isAvailable: !item.isAvailable,
                    );
                    Provider.of<MenuProvider>(context, listen: false)
                        .updateMenuItem(updatedItem);
                    break;
                }
              },
            ),
          ),
        );
      },
    );
  }
}