// admin_update_menu.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminUpdateMenu extends StatefulWidget {
  const AdminUpdateMenu({super.key});

  @override
  State<AdminUpdateMenu> createState() => _AdminUpdateMenuState();
}

class _AdminUpdateMenuState extends State<AdminUpdateMenu> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _itemDescriptionController = TextEditingController();
  
  String _selectedMealType = 'breakfast';
  String _selectedCategory = 'main_course';
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, String>> _mealTypes = [
    {'value': 'breakfast', 'label': 'Breakfast'},
    {'value': 'lunch', 'label': 'Lunch'},
    {'value': 'dinner', 'label': 'Dinner'},
  ];

  final List<Map<String, String>> _categories = [
    {'value': 'main_course', 'label': 'Main Course'},
    {'value': 'side_dish', 'label': 'Side Dish'},
    {'value': 'dessert', 'label': 'Dessert'},
    {'value': 'beverage', 'label': 'Beverage'},
    {'value': 'breakfast', 'label': 'Breakfast'},
    {'value': 'lunch', 'label': 'Lunch'},
    {'value': 'dinner', 'label': 'Dinner'},
  ];

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemPriceController.dispose();
    _itemDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Today's Menu"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMenu,
            tooltip: 'Save Menu',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Date and Meal Type Selection
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('Menu Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.restaurant, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('Meal Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        DropdownButton<String>(
                          value: _selectedMealType,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedMealType = newValue!;
                            });
                          },
                          items: _mealTypes.map((Map<String, String> meal) {
                            return DropdownMenuItem<String>(
                              value: meal['value'],
                              child: Text(meal['label']!),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Add New Item Form
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add New Menu Item",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _itemNameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.fastfood),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _itemPriceController,
                            decoration: const InputDecoration(
                              labelText: 'Price (₹)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.currency_rupee),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            items: _categories.map((Map<String, String> category) {
                              return DropdownMenuItem<String>(
                                value: category['value'],
                                child: Text(category['label']!),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: _itemDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addMenuItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Item to Menu'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Current Menu Items
            const Text(
              "Today's Menu Items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('menus')
                    .where('date', isEqualTo: _getFormattedDate(_selectedDate))
                    .where('mealType', isEqualTo: _selectedMealType)
                    .snapshots(), // Removed .orderBy('category') temporarily
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => setState(() {}),
                            child: const Text('Retry'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'If error persists, check Firebase Console for index creation',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }

                  final menuDocs = snapshot.data?.docs ?? [];

                  // Client-side sorting (temporary solution)
                  menuDocs.sort((a, b) {
                    final categoryA = (a.data() as Map<String, dynamic>)['category'] ?? '';
                    final categoryB = (b.data() as Map<String, dynamic>)['category'] ?? '';
                    return categoryA.compareTo(categoryB);
                  });

                  if (menuDocs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No menu items for selected date'),
                          Text('Add items using the form above'),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: menuDocs.length,
                    itemBuilder: (context, index) {
                      final doc = menuDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      
                      final String itemName = data['itemName'] ?? 'Unknown';
                      final double price = (data['price'] ?? 0).toDouble();
                      final String category = data['category'] ?? 'Unknown';
                      final String description = data['description'] ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(
                              '₹${price.toInt()}',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          title: Text(itemName),
                          subtitle: description.isNotEmpty ? Text(description) : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(
                                  _getCategoryLabel(category),
                                  style: const TextStyle(fontSize: 10),
                                ),
                                backgroundColor: Colors.green.shade100,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteMenuItem(doc.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryLabel(String category) {
    final categoryMap = {
      'main_course': 'MAIN',
      'side_dish': 'SIDE',
      'dessert': 'SWEET',
      'beverage': 'DRINK',
      'breakfast': 'BREAKFAST',
      'lunch': 'LUNCH',
      'dinner': 'DINNER',
    };
    return categoryMap[category] ?? category.toUpperCase();
  }

  Future<void> _addMenuItem() async {
    if (_itemNameController.text.isEmpty || _itemPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      final newItem = {
        'itemName': _itemNameController.text,
        'price': double.parse(_itemPriceController.text),
        'category': _selectedCategory,
        'description': _itemDescriptionController.text,
        'mealType': _selectedMealType,
        'date': _getFormattedDate(_selectedDate),
        'createdAt': FieldValue.serverTimestamp(),
        'isAvailable': true,
      };

      await _firestore.collection('menus').add(newItem);

      // Clear form
      _itemNameController.clear();
      _itemPriceController.clear();
      _itemDescriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu item added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding item: $e')),
      );
    }
  }

  Future<void> _deleteMenuItem(String itemId) async {
    try {
      await _firestore.collection('menus').doc(itemId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu item deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting item: $e')),
      );
    }
  }

  Future<void> _saveMenu() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menu saved successfully!')),
    );
  }

  String _getFormattedDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}