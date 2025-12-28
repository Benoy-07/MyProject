// admin_menu_management.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMenuManagement extends StatefulWidget {
  const AdminMenuManagement({super.key});

  @override
  State<AdminMenuManagement> createState() => _AdminMenuManagementState();
}

class _AdminMenuManagementState extends State<AdminMenuManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Sample menu data structure
  final List<Map<String, dynamic>> _mealTypes = [
    {'id': 'breakfast', 'name': 'Breakfast', 'icon': Icons.breakfast_dining},
    {'id': 'lunch', 'name': 'Lunch', 'icon': Icons.lunch_dining},
    {'id': 'dinner', 'name': 'Dinner', 'icon': Icons.dinner_dining},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu Management"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddMenuDialog,
            tooltip: 'Add New Menu',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Manage Daily Menus",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Create and manage breakfast, lunch, and dinner menus",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            
            // Meal Type Cards
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: _mealTypes.length,
                itemBuilder: (context, index) {
                  final meal = _mealTypes[index];
                  return _buildMealTypeCard(meal);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeCard(Map<String, dynamic> meal) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToMealDetails(meal['id']),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.orange.shade100, Colors.white],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(meal['icon'] as IconData, size: 50, color: Colors.orange),
              const SizedBox(height: 12),
              Text(
                meal['name'] as String,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('menus')
                    .where('mealType', isEqualTo: meal['id'])
                    .where('date', isEqualTo: _getTodayDate())
                    .snapshots(),
                builder: (context, snapshot) {
                  final itemCount = snapshot.data?.docs.length ?? 0;
                  return Text(
                    '$itemCount items today',
                    style: TextStyle(color: Colors.grey[600]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToMealDetails(String mealType) {
    // Navigate to detailed meal management screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$mealType Management'),
        content: Text('Detailed management for $mealType coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAddMenuDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Menu'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Menu creation feature coming soon!'),
            SizedBox(height: 10),
            Text('You will be able to:'),
            Text('• Add food items'),
            Text('• Set prices'),
            Text('• Manage categories'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}