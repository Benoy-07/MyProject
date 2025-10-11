import 'package:flutter/material.dart';
import 'package:hall_dining_app/models/booking_model.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/menu_provider.dart';
import 'menu_management_screen.dart';
import 'booking_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).loadAllBookings();
      Provider.of<MenuProvider>(context, listen: false).loadTodaysMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final menuProvider = Provider.of<MenuProvider>(context);

    final todayBookings = bookingProvider.bookings
        .where((booking) => 
            booking.bookingDate.day == DateTime.now().day &&
            booking.bookingDate.month == DateTime.now().month)
        .toList();

    final pendingBookings = bookingProvider.bookings
        .where((booking) => booking.status == BookingStatus.pending)
        .length;

    final totalRevenue = bookingProvider.bookings
        .where((booking) => booking.status == BookingStatus.confirmed)
        .fold(0.0, (sum, booking) => sum + booking.totalAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              bookingProvider.loadAllBookings();
              menuProvider.loadTodaysMenu();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Quick Stats
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard(
                  'Today\'s Bookings',
                  todayBookings.length.toString(),
                  Icons.book_online,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Pending',
                  pendingBookings.toString(),
                  Icons.pending_actions,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Total Revenue',
                  '৳${totalRevenue.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.green,
                ),
                _buildStatCard(
                  'Menu Items',
                  '${(menuProvider.todaysMenu?.breakfast.length ?? 0) + (menuProvider.todaysMenu?.lunch.length ?? 0) + (menuProvider.todaysMenu?.dinner.length ?? 0)}',
                  Icons.restaurant_menu,
                  Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Quick Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildActionChip(
                          'Manage Menu',
                          Icons.restaurant_menu,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MenuManagementScreen(),
                              ),
                            );
                          },
                        ),
                        _buildActionChip(
                          'View Bookings',
                          Icons.list_alt,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BookingManagementScreen(),
                              ),
                            );
                          },
                        ),
                        _buildActionChip(
                          'Add Menu Item',
                          Icons.add_circle,
                          () {
                            // Navigate to add menu item
                          },
                        ),
                        _buildActionChip(
                          'Today\'s Report',
                          Icons.analytics,
                          () {
                            // Generate today's report
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Recent Bookings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Bookings',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BookingManagementScreen(),
                              ),
                            );
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildRecentBookings(bookingProvider.bookings),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Meal Type Distribution
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Distribution',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildMealDistribution(todayBookings),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: Colors.deepPurple,
      onPressed: onTap,
    );
  }

  Widget _buildRecentBookings(List<Booking> bookings) {
    final recentBookings = bookings.take(5).toList();
    
    if (recentBookings.isEmpty) {
      return const Center(
        child: Column(
          children: [
            Icon(Icons.receipt, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text('No bookings yet'),
          ],
        ),
      );
    }

    return Column(
      children: recentBookings.map((booking) => ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getMealTypeColor(booking.mealType).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getMealIcon(booking.mealType),
            color: _getMealTypeColor(booking.mealType),
          ),
        ),
        title: Text('${booking.userName} • ${booking.mealType.toUpperCase()}'),
        subtitle: Text('${_formatDate(booking.bookingDate)} • ${booking.items.length} items'),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '৳${booking.totalAmount}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Chip(
              label: Text(
                booking.status.name.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 8),
              ),
              backgroundColor: _getStatusColor(booking.status),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildMealDistribution(List<Booking> bookings) {
    final distribution = _calculateMealDistribution(bookings);
    
    return Column(
      children: distribution.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  entry.key.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: LinearProgressIndicator(
                  value: bookings.isEmpty ? 0.0 : entry.value / bookings.length,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getMealTypeColor(entry.key),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${entry.value}',
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Map<String, int> _calculateMealDistribution(List<Booking> bookings) {
    final distribution = {'breakfast': 0, 'lunch': 0, 'dinner': 0};
    
    for (final booking in bookings) {
      distribution[booking.mealType] = (distribution[booking.mealType] ?? 0) + 1;
    }
    
    return distribution;
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType) {
      case 'breakfast': return Colors.orange;
      case 'lunch': return Colors.green;
      case 'dinner': return Colors.purple;
      default: return Colors.blue;
    }
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'breakfast': return Icons.breakfast_dining;
      case 'lunch': return Icons.lunch_dining;
      case 'dinner': return Icons.dinner_dining;
      default: return Icons.restaurant;
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed: return Colors.green;
      case BookingStatus.pending: return Colors.orange;
      case BookingStatus.cancelled: return Colors.red;
      case BookingStatus.completed: return Colors.blue;
      case BookingStatus.preparing: return Colors.blueAccent;
      case BookingStatus.ready: return Colors.teal;
      case BookingStatus.expired: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}