import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hall_dining_management/service/auth_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _welcomeCardColorAnimation;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _adminName = "Admin";
  int _totalUsers = 0;
  Map<String, int> _todayMeals = {
    'breakfast': 0,
    'lunch': 0,
    'snacks': 0,
    'dinner': 0,
  };
  int _pendingOrders = 0;
  double _todayRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Color animation for welcome card
    _welcomeCardColorAnimation = ColorTween(
      begin: Colors.blue[50],
      end: Colors.purple[50],
    ).animate(_animationController);

    // Load initial data
    _loadAdminData();
    _loadStatistics();
    _startRealtimeListeners();
  }

 void _loadAdminData() async {
  try {
    final currentUser = await AuthService().getCurrentUser();  // await যোগ করো এখানে
    if (currentUser != null) {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)  // এখন .uid কাজ করবে
          .get();
      
      if (userDoc.exists) {
        setState(() {
          _adminName = userDoc['name'] ?? "Admin";
        });
      }
    }
  } catch (e) {
    print('Error loading admin data: $e');
  }
}

  void _loadStatistics() async {
    await _loadTotalUsers();
    await _loadTodayMeals();
    await _loadPendingOrders();
    await _loadTodayRevenue();
  }

  Future<void> _loadTotalUsers() async {
    try {
      QuerySnapshot usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();
      
      setState(() {
        _totalUsers = usersSnapshot.docs.length;
      });
    } catch (e) {
      print('Error loading total users: $e');
    }
  }

  Future<void> _loadTodayMeals() async {
    try {
      DateTime today = DateTime.now();
      String todayDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      
      QuerySnapshot mealsSnapshot = await _firestore
          .collection('meal_bookings')
          .where('date', isEqualTo: todayDate)
          .get();

      Map<String, int> mealsCount = {
        'breakfast': 0,
        'lunch': 0,
        'snacks': 0,
        'dinner': 0,
      };

      for (var doc in mealsSnapshot.docs) {
        String mealType = doc['mealType'];
        if (mealsCount.containsKey(mealType)) {
          mealsCount[mealType] = mealsCount[mealType]! + 1;
        }
      }

      setState(() {
        _todayMeals = mealsCount;
      });
    } catch (e) {
      print('Error loading today meals: $e');
    }
  }

  Future<void> _loadPendingOrders() async {
    try {
      QuerySnapshot ordersSnapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: 'pending')
          .get();
      
      setState(() {
        _pendingOrders = ordersSnapshot.docs.length;
      });
    } catch (e) {
      print('Error loading pending orders: $e');
    }
  }

  Future<void> _loadTodayRevenue() async {
    try {
      DateTime today = DateTime.now();
      String todayDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      
      QuerySnapshot revenueSnapshot = await _firestore
          .collection('orders')
          .where('date', isEqualTo: todayDate)
          .where('status', isEqualTo: 'completed')
          .get();

      double totalRevenue = 0.0;
      for (var doc in revenueSnapshot.docs) {
        totalRevenue += (doc['totalAmount'] ?? 0).toDouble();
      }

      setState(() {
        _todayRevenue = totalRevenue;
      });
    } catch (e) {
      print('Error loading today revenue: $e');
    }
  }

  void _startRealtimeListeners() {
    // Real-time listener for users count
    _firestore
        .collection('users')
        .where('role', isEqualTo: 'user')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _totalUsers = snapshot.docs.length;
      });
    });

    // Real-time listener for today's meals
    DateTime today = DateTime.now();
    String todayDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    _firestore
        .collection('meal_bookings')
        .where('date', isEqualTo: todayDate)
        .snapshots()
        .listen((snapshot) {
      Map<String, int> mealsCount = {
        'breakfast': 0,
        'lunch': 0,
        'snacks': 0,
        'dinner': 0,
      };

      for (var doc in snapshot.docs) {
        String mealType = doc['mealType'];
        if (mealsCount.containsKey(mealType)) {
          mealsCount[mealType] = mealsCount[mealType]! + 1;
        }
      }

      setState(() {
        _todayMeals = mealsCount;
      });
    });

    // Real-time listener for pending orders
    _firestore
        .collection('orders')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _pendingOrders = snapshot.docs.length;
      });
    });

    // Real-time listener for today's revenue
    _firestore
        .collection('orders')
        .where('date', isEqualTo: todayDate)
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .listen((snapshot) {
      double totalRevenue = 0.0;
      for (var doc in snapshot.docs) {
        totalRevenue += (doc['totalAmount'] ?? 0).toDouble();
      }

      setState(() {
        _todayRevenue = totalRevenue;
      });
    });
  }

  void _saveMealsHistory() async {
    try {
      DateTime today = DateTime.now();
      String todayDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      
      // Check if today's history already exists
      DocumentSnapshot historyDoc = await _firestore
          .collection('meals_history')
          .doc(todayDate)
          .get();

      if (!historyDoc.exists) {
        // Save today's meals data to history
        await _firestore
            .collection('meals_history')
            .doc(todayDate)
            .set({
              'date': todayDate,
              'breakfastBookings': _todayMeals['breakfast'],
              'lunchBookings': _todayMeals['lunch'],
              'snacksBookings': _todayMeals['snacks'],
              'dinnerBookings': _todayMeals['dinner'],
              'totalRevenue': _todayRevenue,
              'savedAt': FieldValue.serverTimestamp(),
            });
        
        print('Meals history saved for $todayDate');
      }
    } catch (e) {
      print('Error saving meals history: $e');
    }
  }

  // Auto-save meals history after dinner time (9:30 PM)
  void _scheduleMealsHistorySave() {
    DateTime now = DateTime.now();
    DateTime dinnerEndTime = DateTime(now.year, now.month, now.day, 21, 30); // 9:30 PM
    
    if (now.isAfter(dinnerEndTime)) {
      _saveMealsHistory();
    }
    
    // Schedule next check
    Future.delayed(const Duration(minutes: 30), _scheduleMealsHistorySave);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _navigateToMenuManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MenuManagementScreen()),
    );
  }

  void _navigateToUserManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserManagementScreen()),
    );
  }

  void _navigateToOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OrdersScreen()),
    );
  }

  void _navigateToMealsHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MealsHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Settings Icon
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showToast('Settings clicked');
            },
            tooltip: 'Settings',
          ),
          // Notifications Icon
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showToast('Notifications clicked');
            },
            tooltip: 'Notifications',
          ),
          // Logout Icon
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated Welcome Card
            AnimatedBuilder(
              animation: _welcomeCardColorAnimation,
              builder: (context, child) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _welcomeCardColorAnimation.value!,
                          Colors.white,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Animated Icon
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[400]!, Colors.purple[400]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome $_adminName! 👋',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Manage hall dining operations efficiently',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green[100]!),
                                  ),
                                  child: Text(
                                    'System Status: Active',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Quick Stats
            Text(
              '📊 Quick Stats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Users',
                    '$_totalUsers',
                    Icons.people,
                    Colors.green,
                    'Real-time user count',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Today\'s Meals',
                    '${_todayMeals['breakfast']! + _todayMeals['lunch']! + _todayMeals['snacks']! + _todayMeals['dinner']!}',
                    Icons.restaurant,
                    Colors.orange,
                    'B:${_todayMeals['breakfast']} L:${_todayMeals['lunch']} S:${_todayMeals['snacks']} D:${_todayMeals['dinner']}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Pending Orders',
                    '$_pendingOrders',
                    Icons.shopping_cart,
                    Colors.red,
                    'Need attention',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Revenue',
                    '₹${_todayRevenue.toStringAsFixed(1)}K',
                    Icons.attach_money,
                    Colors.purple,
                    'Today\'s collection',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Management Options
            Text(
              '⚙️ Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildManagementOption(
                  'Menu Management',
                  Icons.menu_book,
                  Colors.blue,
                  'Manage food items & prices',
                  _navigateToMenuManagement,
                ),
                _buildManagementOption(
                  'User Management',
                  Icons.people_outline,
                  Colors.green,
                  'View & manage users',
                  _navigateToUserManagement,
                ),
                _buildManagementOption(
                  'Orders',
                  Icons.shopping_cart,
                  Colors.orange,
                  'Process orders & payments',
                  _navigateToOrders,
                ),
                _buildManagementOption(
                  'Meals History',
                  Icons.history,
                  Colors.purple,
                  'View past meal records',
                  _navigateToMealsHistory,
                ),
              ],
            ),
            
            // Additional Information Section
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Quick Tips',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTipItem('Check pending orders regularly'),
                    _buildTipItem('Update menu before meal times'),
                    _buildTipItem('Review user feedback weekly'),
                    _buildTipItem('Monitor revenue reports daily'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: color,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementOption(
      String title, IconData icon, Color color, String subtitle, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.2), color.withOpacity(0.4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: color.withOpacity(0.3), width: 2),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 6, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AuthService().signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// Placeholder screens for navigation
class MenuManagementScreen extends StatelessWidget {
  const MenuManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Management')),
      body: const Center(child: Text('Menu Management Screen')),
    );
  }
}

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: const Center(child: Text('User Management Screen')),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: const Center(child: Text('Orders Screen')),
    );
  }
}

class MealsHistoryScreen extends StatelessWidget {
  const MealsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meals History')),
      body: const Center(child: Text('Meals History Screen')),
    );
  }
}