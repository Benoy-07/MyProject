// admin_dashboard.dart - UPDATED
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_user_management.dart';
import 'admin_menu_management.dart';
import 'admin_meal_tracking.dart';
import 'admin_update_menu.dart';
import 'admin_order_history.dart'; // ADD THIS IMPORT

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Admin Panel", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildCard("User Management", Icons.people, Colors.blue, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserManagement()));
            }),
            _buildCard("Menu Management", Icons.restaurant_menu, Colors.orange, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMenuManagement()));
            }),
            _buildCard("Meal Tracking", Icons.track_changes, Colors.purple, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMealTracking()));
            }),
            _buildCard("Update Menu", Icons.edit, Colors.green, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUpdateMenu()));
            }),
            _buildCard("Order History", Icons.history, Colors.deepOrange, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrderHistory()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [color.withOpacity(0.1), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 30, backgroundColor: color.withOpacity(0.2), child: Icon(icon, size: 36, color: color)),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}