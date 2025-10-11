import 'package:flutter/material.dart';
import 'package:hall_dining_management/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  String _userName = "User";
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _bannerController;
  late Animation<double> _bannerScaleAnimation;

  // Sample data for demonstration
  final List<Map<String, dynamic>> _todayMenu = [
    {
      'meal': 'Breakfast',
      'time': '08:00 AM - 10:00 AM',
      'icon': Icons.breakfast_dining,
      'color': Colors.orange,
      'items': 'Poha, Bread Butter, Tea, Banana',
      'price': 30.0,
    },
    {
      'meal': 'Lunch',
      'time': '12:30 PM - 02:30 PM',
      'icon': Icons.lunch_dining,
      'color': Colors.green,
      'items': 'Rice, Dal, Mixed Veg, Chapati, Salad',
      'price': 60.0,
    },
    {
      'meal': 'Snacks',
      'time': '04:30 PM - 06:00 PM',
      'icon': Icons.coffee,
      'color': Colors.brown,
      'items': 'Samosa, Tea, Biscuits, Pakora',
      'price': 25.0,
    },
    {
      'meal': 'Dinner',
      'time': '07:30 PM - 09:30 PM',
      'icon': Icons.dinner_dining,
      'color': Colors.purple,
      'items': 'Rice, Chicken Curry, Salad, Dessert',
      'price': 70.0,
    },
  ];

  final List<Map<String, dynamic>> _myOrders = [
    {
      'id': '#ORD001',
      'meal': 'Lunch',
      'date': 'Today, 1:15 PM',
      'status': 'Confirmed',
      'price': 60.0,
    },
    {
      'id': '#ORD002',
      'meal': 'Breakfast',
      'date': 'Today, 8:30 AM',
      'status': 'Completed',
      'price': 30.0,
    },
    {
      'id': '#ORD003',
      'meal': 'Dinner',
      'date': 'Yesterday, 8:00 PM',
      'status': 'Completed',
      'price': 70.0,
    },
  ];

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Meal Booking Confirmed',
      'message': 'Your lunch booking for today is confirmed',
      'time': '2 hours ago',
      'read': false,
    },
    {
      'title': 'Payment Successful',
      'message': 'Payment of ₹500 has been received',
      'time': '1 day ago',
      'read': true,
    },
    {
      'title': 'New Menu Available',
      'message': 'Check out this week\'s special menu',
      'time': '2 days ago',
      'read': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _bannerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _bannerScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _bannerController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadUserName();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  void _loadUserName() async {
    if (_currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();
        
        if (userDoc.exists) {
          setState(() {
            _userName = userDoc['name'] ?? "User";
          });
        }
      } catch (e) {
        print('Error loading user name: $e');
        setState(() {
          _userName = "User";
        });
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _navigateToMealDetails(Map<String, dynamic> meal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FadeTransition(
          opacity: _fadeAnimation,
          child: MealDetailsScreen(meal: meal),
        ),
      ),
    );
  }

  void _bookMeal(Map<String, dynamic> meal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Book ${meal['meal']}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${meal['time']}'),
            const SizedBox(height: 8),
            const Text('Are you sure you want to book this meal?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast('${meal['meal']} booked successfully!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  void _showMenuDialog() {
    final options = _buildMenuOptions();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Menu Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(option['icon'], color: Colors.blue),
                    ),
                    title: Text(option['title']),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.pop(context);
                      option['onTap']();
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _buildMenuOptions() {
    return [
      {
        'title': 'Profile',
        'icon': Icons.person,
        'onTap': () => _navigateToProfile(),
      },
      {
        'title': 'Payment Methods',
        'icon': Icons.payment,
        'onTap': () => _navigateToPaymentMethods(),
      },
      {
        'title': 'Refer a Friend',
        'icon': Icons.group_add,
        'onTap': () => _navigateToReferFriend(),
      },
      {
        'title': 'Order History',
        'icon': Icons.history,
        'onTap': () => _navigateToOrderHistory(),
      },
      {
        'title': 'Favourite Items',
        'icon': Icons.favorite,
        'onTap': () => _navigateToFavourites(),
      },
      {
        'title': 'Contact Us',
        'icon': Icons.contact_support,
        'onTap': () => _navigateToContactUs(),
      },
      {
        'title': 'FAQ',
        'icon': Icons.help,
        'onTap': () => _navigateToFAQ(),
      },
      {
        'title': 'Dining Website',
        'icon': Icons.language,
        'onTap': () => _navigateToDiningWebsite(),
      },
      {
        'title': 'Monthly Cost History',
        'icon': Icons.analytics,
        'onTap': () => _navigateToMonthlyCost(),
      },
      {
        'title': 'Settings',
        'icon': Icons.settings,
        'onTap': () => _navigateToSettings(),
      },
      {
        'title': 'Logout',
        'icon': Icons.logout,
        'onTap': _logout,
      },
    ];
  }

  // Navigation methods for menu options
  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FadeTransition(
        opacity: _fadeAnimation,
        child: const ProfileScreen(),
      )),
    );
  }

  void _navigateToPaymentMethods() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FadeTransition(
        opacity: _fadeAnimation,
        child: const PaymentMethodsScreen(),
      )),
    );
  }

  void _navigateToReferFriend() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FadeTransition(
        opacity: _fadeAnimation,
        child: const ReferFriendScreen(),
      )),
    );
  }

  void _navigateToOrderHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FadeTransition(
        opacity: _fadeAnimation,
        child: const OrderHistoryScreen(),
      )),
    );
  }

  void _navigateToFavourites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FadeTransition(
        opacity: _fadeAnimation,
        child: const FavouriteItemsScreen(),
      )),
    );
  }

  void _navigateToContactUs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FadeTransition(
        opacity: _fadeAnimation,
        child: const ContactUsScreen(),
      )),
    );
  }

  void _navigateToFAQ() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FadeTransition(
        opacity: _fadeAnimation,
        child: const FAQScreen(),
      )),
    );
  }

  void _navigateToDiningWebsite() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FadeTransition(
        opacity: _fadeAnimation,
        child: const DiningWebsiteScreen(),
      )),
    );
  }

  void _navigateToMonthlyCost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FadeTransition(
        opacity: _fadeAnimation,
        child: const MonthlyCostScreen(),
      )),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FadeTransition(
        opacity: _fadeAnimation,
        child: const SettingsScreen(),
      )),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              _authService.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // Different screens for bottom navigation
  Widget _buildHomeScreen() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        await Future.delayed(const Duration(seconds: 1));
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Centered Welcome Section
                // FadeTransition(
                //   opacity: _fadeAnimation,
                //   child: Container(
                //     width: double.infinity,
                //     padding: const EdgeInsets.all(24),
                //     child: Column(
                //       children: [
                //         // Card(
                //         //   elevation: 12,
                //         //   shadowColor: Colors.blue.withOpacity(0.4),
                //         //   shape: RoundedRectangleBorder(
                //         //     borderRadius: BorderRadius.circular(24),
                //         //   ),
                //         //   child: Padding(
                //         //     padding: const EdgeInsets.all(32),
                //         //     child: Column(
                //         //       children: [
                //         //         Container(
                //         //           width: 80,
                //         //           height: 80,
                //         //           decoration: BoxDecoration(
                //         //             gradient: LinearGradient(
                //         //               colors: [Colors.blue.shade100, Colors.blue.shade200],
                //         //             ),
                //         //             borderRadius: BorderRadius.circular(20),
                //         //             boxShadow: [
                //         //               BoxShadow(
                //         //                 color: Colors.blue.withOpacity(0.3),
                //         //                 blurRadius: 15,
                //         //                 offset: const Offset(0, 6),
                //         //               ),
                //         //             ],
                //         //           ),
                //         //           child: const Icon(
                //         //             Icons.person,
                //         //             size: 40,
                //         //             color: Colors.blue,
                //         //           ),
                //         //         ),
                //         //         const SizedBox(height: 20),
                //         //         Text(
                //         //           'Welcome $_userName!',
                //         //           style: TextStyle(
                //         //             fontSize: 28,
                //         //             fontWeight: FontWeight.bold,
                //         //             color: Colors.grey[900],
                //         //             letterSpacing: 1.0,
                //         //           ),
                //         //           textAlign: TextAlign.center,
                //         //         ),
                //         //         const SizedBox(height: 8),
                //         //         Text(
                //         //           'Enjoy your dining experience today!',
                //         //           style: TextStyle(
                //         //             fontSize: 18,
                //         //             color: Colors.grey[600],
                //         //             fontStyle: FontStyle.italic,
                //         //           ),
                //         //           textAlign: TextAlign.center,
                //         //         ),
                //         //       ],
                //         //     ),
                //         //   ),
                //         // ),
                //         const SizedBox(height: 24),
                //       ],
                //     ),
                //   ),
                // ),
                // Interactive Banner below Welcome
                SizedBox(height: 10),
                AnimatedBuilder(
                  animation: _bannerScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _bannerScaleAnimation.value,
                      child: InkWell(
                        onTap: () => _showToast('Explore Hall Dining Management!'),
                        onLongPress: () => _showToast('Long press for more options!'),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade600, Colors.purple.shade600, Colors.indigo.shade600],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                   // borderRadius: BorderRadius.circular(24),
                                   borderRadius: BorderRadius.circular(0),
                                    image: const DecorationImage(
                                      image: AssetImage('assets/image.png'), // Assume asset; replace with network if needed
                                      fit: BoxFit.cover,
                                      opacity: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 40,
                                left: 24,
                                right: 24,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Welcome Benoy',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            // ignore: deprecated_member_use
                                            color: Colors.black,
                                            offset: Offset(2, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to explore today\'s specials and book your favorites effortlessly.',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.5),
                                            offset: const Offset(2, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 24,
                                right: 24,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Explore',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 24,
                                right: 24,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  child: Icon(
                                    Icons.restaurant_menu,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 40,
                                  ),
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
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's Menu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Menu",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        label: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._todayMenu.map((meal) => AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: _buildMenuItem(meal),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: 24),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActions(),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: 100), // For bottom nav
          ),
        ],
      ),
    );
  }

  Widget _buildMyMealScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Meal Bookings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 16),
          ..._todayMenu.map((meal) => _buildMealBookingCard(meal)),
        ],
      ),
    );
  }

  Widget _buildMyOrderScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Orders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 16),
          ..._myOrders.map((order) => _buildOrderCard(order)),
        ],
      ),
    );
  }

  Widget _buildNotificationsScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 16),
          ..._notifications.map((notification) => _buildNotificationCard(notification)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 6,
      shadowColor: meal['color'].withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToMealDetails(meal),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [meal['color'].withOpacity(0.2), meal['color'].withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: meal['color'].withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  meal['icon'],
                  color: meal['color'],
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal['meal'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      meal['time'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meal['items'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.bookmark_border, color: Colors.blue, size: 20),
                      onPressed: () => _bookMeal(meal),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${meal['price']}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildActionCard(
          'Book Meal',
          Icons.restaurant,
          Colors.blue,
          () => _showToast('Book Meal clicked'),
        ),
        _buildActionCard(
          'Events',
          Icons.event,
          Colors.green,
          () => _showToast('Events clicked'),
        ),
        _buildActionCard(
          'My Orders',
          Icons.shopping_cart,
          Colors.orange,
          () => setState(() => _currentIndex = 2),
        ),
        _buildActionCard(
          'Feedback',
          Icons.feedback,
          Colors.purple,
          () => _showToast('Feedback clicked'),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 6,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealBookingCard(Map<String, dynamic> meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: meal['color'].withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToMealDetails(meal),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [meal['color'].withOpacity(0.2), meal['color'].withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(meal['icon'], color: meal['color'], size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal['meal'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(meal['time'], style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _bookMeal(meal),
                icon: const Icon(Icons.bookmark_add, size: 16),
                label: const Text('Book Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.withOpacity(0.2), Colors.blue.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.shopping_cart, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${order['meal']} - ${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(order['date']),
                  Text('Status: ${order['status']}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Text(
              '₹${order['price']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: notification['read'] ? Colors.white : Colors.blue[50],
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.withOpacity(0.2), Colors.orange.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(Icons.notifications, color: Colors.orange, size: 24),
        ),
        title: Text(notification['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['message']),
            Text(
              notification['time'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        onTap: () {
          setState(() {
            notification['read'] = true;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Hall Dining',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.person),
              onPressed: _showMenuDialog,
              tooltip: 'Menu',
            ),
          ),
        ],
      ),
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'My Meal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'My Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return _buildMyMealScreen();
      case 2:
        return _buildMyOrderScreen();
      case 3:
        return _buildNotificationsScreen();
      default:
        return _buildHomeScreen();
    }
  }
}

// Meal Details Screen
class MealDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> meal;

  const MealDetailsScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(meal['meal']),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueAccent],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Header
            Card(
              elevation: 8,
              shadowColor: meal['color'].withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [meal['color'].withOpacity(0.2), meal['color'].withOpacity(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: meal['color'].withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        meal['icon'],
                        color: meal['color'],
                        size: 35,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal['meal'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            meal['time'],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Meal Details
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meal Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Items:', meal['items']),
                    const SizedBox(height: 12),
                    _buildDetailRow('Price:', '₹${meal['price']}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Book Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${meal['meal']} booked successfully!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.bookmark_add),
                label: Text(
                  'Book This Meal',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: Colors.blue.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Individual Screen Classes (Add these in separate files or in the same file)

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 100, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Profile Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Under Development',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment, size: 100, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Payment Methods Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Under Development',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReferFriendScreen extends StatelessWidget {
  const ReferFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Refer a Friend'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_add, size: 100, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Refer Friend Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Under Development',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 100, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Order History Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Under Development',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FavouriteItemsScreen extends StatelessWidget {
  const FavouriteItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Favourite Items'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, size: 100, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Favourite Items Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Under Development',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.contact_support, size: 100, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Contact Us Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Under Development',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('FAQ'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.help, size: 100, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'FAQ Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Under Development',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiningWebsiteScreen extends StatelessWidget {
  const DiningWebsiteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dining Website'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.language, size: 100, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Dining Website Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Under Development',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MonthlyCostScreen extends StatelessWidget {
  const MonthlyCostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Monthly Cost History'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics, size: 100, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Monthly Cost History Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Under Development',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings, size: 100, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Settings Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Under Development',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}