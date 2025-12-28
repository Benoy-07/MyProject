// admin_meal_tracking.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminMealTracking extends StatefulWidget {
  const AdminMealTracking({super.key});

  @override
  State<AdminMealTracking> createState() => _AdminMealTrackingState();
}

class _AdminMealTrackingState extends State<AdminMealTracking> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _selectedDate = DateTime.now();
  String _selectedMealType = 'breakfast';

  final List<Map<String, String>> _mealTypes = [
    {'value': 'breakfast', 'label': 'Breakfast'},
    {'value': 'lunch', 'label': 'Lunch'},
    {'value': 'dinner', 'label': 'Dinner'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal Tracking"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Date and Meal Type Selector
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.purple),
                        const SizedBox(width: 8),
                        const Text('Select Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        TextButton(
                          onPressed: _selectDate,
                          child: Text(
                            DateFormat('MMM dd, yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.restaurant, color: Colors.purple),
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
            
            // Statistics Cards (dynamic from `orders` collection for selected date & meal type)
            FutureBuilder<Map<String, dynamic>>(
              future: _fetchDailyOrderStats(_selectedDate, _selectedMealType),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildStatCard('Total Orders', '...', Icons.people, Colors.blue)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Confirmed Orders', '...', Icons.check_circle, Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard('Absent Orders', '...', Icons.cancel, Colors.red)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Total Amount', '৳...', Icons.attach_money, Colors.orange)),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }

                final data = snap.data ?? {'totalOrders': 0, 'confirmedOrders': 0, 'absentOrders': 0, 'totalAmount': 0.0};
                final int totalOrders = data['totalOrders'] ?? 0;
                final int confirmedOrders = data['confirmedOrders'] ?? 0;
                final int absentOrders = data['absentOrders'] ?? 0;
                final double totalAmount = (data['totalAmount'] ?? 0.0) is double ? data['totalAmount'] : (data['totalAmount'] ?? 0.0).toDouble();

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Total Orders', '$totalOrders', Icons.people, Colors.blue)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('Confirmed Orders', '$confirmedOrders', Icons.check_circle, Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Absent Orders', '$absentOrders', Icons.cancel, Colors.red)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('Total Amount', '৳${totalAmount.toStringAsFixed(0)}', Icons.attach_money, Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
            
            // Meal Tracking List
            const Text(
              "Today's Meal Attendance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('meal_attendance')
                    .where('date', isEqualTo: _getFormattedDate(_selectedDate))
                    .where('mealType', isEqualTo: _selectedMealType)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final attendanceDocs = snapshot.data?.docs ?? [];

                  if (attendanceDocs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No attendance records found'),
                          Text('for selected date and meal type'),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: attendanceDocs.length,
                    itemBuilder: (context, index) {
                      final doc = attendanceDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      
                      final String userName = data['userName'] ?? 'Unknown';
                      final String userEmail = data['userEmail'] ?? 'No email';
                      final bool isPresent = data['isPresent'] == true;
                      final String time = data['timestamp'] != null 
                          ? DateFormat('HH:mm').format((data['timestamp'] as Timestamp).toDate())
                          : 'N/A';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isPresent ? Colors.green : Colors.red,
                            child: Icon(
                              isPresent ? Icons.check : Icons.close,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(userName),
                          subtitle: Text(userEmail),
                          trailing: Text(time),
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

  // Fetch daily order stats (for selected date + mealType)
  Future<Map<String, dynamic>> _fetchDailyOrderStats(DateTime date, String mealType) async {
    try {
      final dateStr = _getFormattedDate(date);
      // Query by date only to ensure orders without mealType field are included
      final query = await _firestore.collection('orders').where('date', isEqualTo: dateStr).get();

      final docs = query.docs;
      int totalOrders = 0;
      int confirmed = 0; // prepared/confirmed counted as confirmed
      double totalAmount = 0.0;

      for (final d in docs) {
        final data = d.data();

        // If a mealType field exists, require it to match the selected mealType (case-insensitive)
        final String? docMeal = data['mealType']?.toString();
        final bool includeForMeal = docMeal == null || docMeal.toLowerCase() == mealType.toLowerCase();
        if (!includeForMeal) continue;

        totalOrders += 1;

        final status = (data['status'] ?? '').toString().toLowerCase();
        if (status == 'prepared' || status == 'confirmed' || status == 'served') confirmed += 1;

        final amt = (data['totalAmount'] ?? 0);
        try {
          totalAmount += (amt is num) ? amt.toDouble() : double.parse(amt.toString());
        } catch (_) {}
      }

      final absent = totalOrders - confirmed;
      return {
        'totalOrders': totalOrders,
        'confirmedOrders': confirmed,
        'absentOrders': absent < 0 ? 0 : absent,
        'totalAmount': totalAmount,
      };
    } catch (e) {
      debugPrint('Error fetching daily order stats: $e');
      return {'totalOrders': 0, 'confirmedOrders': 0, 'absentOrders': 0, 'totalAmount': 0.0};
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getFormattedDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}