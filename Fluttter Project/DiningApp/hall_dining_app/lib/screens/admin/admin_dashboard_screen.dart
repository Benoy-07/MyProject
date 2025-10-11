import 'package:flutter/material.dart';
import 'package:hall_dining_app/screens/booking/booking_screen.dart';
import 'package:hall_dining_app/screens/menu/menu_detail_screen.dart';
import 'package:hall_dining_app/screens/menu/menu_list_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
//import 'menu_management_screen.dart';
//import 'booking_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    // Check if user is admin
    if (user?.role != 'admin') {
      return const Scaffold(
        body: Center(
          child: Text('Access Denied'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _buildDashboardCard(
            icon: Icons.restaurant_menu,
            title: 'Menu Management',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  //builder: (context) => const MenuManagementScreen(),
                  builder: (context) => const MenuListScreen(),
                ),
              );
            },
          ),
          _buildDashboardCard(
            icon: Icons.book_online,
            title: 'Bookings',
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  //builder: (context) => const BookingManagementScreen(),
                  builder: (context) => const BookingScreen(),
                ),
              );
            },
          ),
          _buildDashboardCard(
            icon: Icons.analytics,
            title: 'Analytics',
            color: Colors.purple,
            onTap: () {
              // Navigate to analytics screen
            },
          ),
          _buildDashboardCard(
            icon: Icons.people,
            title: 'Users',
            color: Colors.orange,
            onTap: () {
              // Navigate to users management
            },
          ),
          _buildDashboardCard(
            icon: Icons.payment,
            title: 'Payments',
            color: Colors.teal,
            onTap: () {
              // Navigate to payments management
            },
          ),
          _buildDashboardCard(
            icon: Icons.feedback,
            title: 'Feedback',
            color: Colors.red,
            onTap: () {
              // Navigate to feedback management
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}