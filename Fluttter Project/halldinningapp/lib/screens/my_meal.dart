// my_meal_page.dart (updated to show menus by selected date)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:halldinningapp/screens/meal_detail_page.dart';

class MyMealPage extends StatefulWidget {
  const MyMealPage({super.key});

  @override
  State<MyMealPage> createState() => _MyMealPageState();
}

class _MyMealPageState extends State<MyMealPage> {
  DateTime _selectedDate = DateTime.now();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Meal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
            tooltip: 'Select date',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade50, Colors.orange.shade50],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Available Meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(dateStr, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('menus')
                    .where('date', isEqualTo: dateStr)
                    .where('isAvailable', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(child: Text('No meals available for $dateStr', style: TextStyle(color: Colors.grey.shade700)));
                  }

                  // Group by mealType
                  final Map<String, List<QueryDocumentSnapshot>> grouped = {};
                  for (var doc in docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final meal = (data['mealType'] ?? 'other').toString();
                    final cap = meal[0].toUpperCase() + meal.substring(1);
                    grouped.putIfAbsent(cap, () => []).add(doc);
                  }

                  final keys = grouped.keys.toList();

                  return ListView.builder(
                    itemCount: keys.length,
                    itemBuilder: (context, idx) {
                      final meal = keys[idx];
                      final items = grouped[meal]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ExpansionTile(
                            title: Text('$meal • ${items.length} items'),
                            children: items.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final price = (data['price'] as num?)?.toDouble() ?? 0.0;
                              return ListTile(
                                leading: data['imageUrl'] != null && (data['imageUrl'] as String).isNotEmpty
                                    ? CircleAvatar(backgroundImage: NetworkImage(data['imageUrl']))
                                    : CircleAvatar(child: Text(meal[0])),
                                title: Text(data['itemName'] ?? 'No name'),
                                subtitle: Text(data['description'] ?? ''),
                                trailing: Text('৳${price.toStringAsFixed(0)}'),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MealDetailPage(meal: meal,))),
                              );
                            }).toList(),
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
}