// Updated Home page with interactive Tomorrow's Menu and bottom navigation
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';
import '../services/menu_service.dart';
import 'my_meal.dart';
import 'my_order.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Menu items are now fetched from Firestore via MenuService

  final Map<String, String> _mealTimes = {
    'Breakfast': '08:00 AM - 10:00 AM',
    'Lunch': '12:30 PM - 02:00 PM',
    'Dinner': '07:00 PM - 09:00 PM',
  };

  String _getDisplayName() {
    final user = FirebaseAuthService.getCurrentUser();
    if (user == null) return 'Guest';
    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      return user.displayName!;
    }
    if (user.email != null && user.email!.isNotEmpty) {
      return user.email!.split('@')[0];
    }
    return 'User';
  }

  Widget _buildHomeContent() {
    final displayName = _getDisplayName();
    final tomorrowStr = 'Tomorrow';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: welcome text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to $displayName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'We hope you have a great meal!',
                        style: TextStyle(color: Colors.white.withOpacity(0.95)),
                      ),
                    ],
                  ),
                ),
                // Right: optional small profile icon (kept minimal)
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.info_outline, color: Colors.white70),
                ),
              ],
            ),
          
          ),
          const SizedBox(height: 12),
          const Divider(height: 1.5),
          const SizedBox(height: 18),

          // Tomorrow's Menu header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tomorrow's Menu",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(tomorrowStr, style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
          const SizedBox(height: 12),

          // Meal cards (dynamically fetched from Firestore)
          StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
            stream: MenuService.getAllMenus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // show placeholders while loading
                return Column(
                  children: ['Breakfast', 'Lunch', 'Dinner'].map((meal) {
                    final time = _mealTimes[meal] ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: meal == 'Breakfast' ? [Colors.orange, Colors.deepOrange] : meal == 'Lunch' ? [Colors.green, Colors.teal] : [Colors.indigo, Colors.purple])),
                                  child: Icon(meal == 'Breakfast' ? Icons.free_breakfast : meal == 'Lunch' ? Icons.lunch_dining : Icons.dinner_dining, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(meal, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text(time, style: TextStyle(color: Colors.grey.shade600))]),
                            Row(children: [Text('...', style: TextStyle(color: Colors.grey.shade700)), const SizedBox(width: 8), const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)]),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              }

              final menus = snapshot.data ?? {};
              // If no menus returned, still show defaults
              final meals = menus.keys.isNotEmpty ? menus.keys.toList() : ['Breakfast', 'Lunch', 'Dinner'];

              return Column(
                children: meals.map((meal) {
                  final items = menus[meal] ?? [];
                  final time = _mealTimes[meal] ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/meal-detail',
                        arguments: {'meal': meal},
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(colors: meal == 'Breakfast' ? [Colors.orange, Colors.deepOrange] : meal == 'Lunch' ? [Colors.green, Colors.teal] : [Colors.indigo, Colors.purple]),
                                  ),
                                  child: Icon(
                                    meal == 'Breakfast'
                                        ? Icons.free_breakfast
                                        : meal == 'Lunch'
                                            ? Icons.lunch_dining
                                            : Icons.dinner_dining,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meal,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  time,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '${items.length} items',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),

          // Small CTA
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(child: Text('Tap a meal to view colorful menu items and add them to cart for checkout.', style: TextStyle(color: Colors.grey.shade800))),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Color get _appBarColor {
    switch (_selectedIndex) {
      case 1:
        return Colors.deepOrange;
      case 2:
        return Colors.teal;
      case 3:
        return Colors.indigo;
      default:
        return Colors.deepPurple;
    }
  }



  // Removed unused specialized content builders; the simple placeholder is used instead.

  // _showMealDetails removed: not referenced anywhere in the codebase.

  Widget _buildPlaceholder(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 18, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (_selectedIndex) {
      case 0:
        content = _buildHomeContent();
        break;
      case 1:
        content = _buildPlaceholder('My Meal - choose your plan', Icons.fastfood);
        break;
      case 2:
        content = _buildPlaceholder('My Orders - recent orders', Icons.receipt_long);
        break;
      case 3:
        content = _buildPlaceholder('Notifications', Icons.notifications_active);
        break;
      default:
        content = _buildHomeContent();
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _appBarColor,
        title: Text(_selectedIndex == 0 ? 'Home' : _selectedIndex == 1 ? 'My Meal' : _selectedIndex == 2 ? 'My Orders' : 'Notifications', style: TextStyle(color: _selectedIndex == 0 ? Colors.white : Colors.white)),
        actions: [
          IconButton(
            onPressed: () => _showProfileMenu(),
            icon: const Icon(Icons.person, color: Colors.white),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          // subtle background gradient for the scaffold body
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFf6d365),
              Color(0xFFfda085),
              Color(0xFFfbc2eb),
              Color(0xFFa6c1ee),
              Color(0xFF8fd3f4),
            ],
            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: content,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        backgroundColor: _appBarColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'My Meal'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'My Order'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notification'),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    // If user taps My Meal or My Order, navigate to their full pages
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyMealPage()));
      return;
    }

    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrderPage()));
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _showProfileMenu() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: const Text('Profile'), leading: const Icon(Icons.person), onTap: () { Navigator.pop(ctx); showDialog(context: context, builder: (c)=> AlertDialog(title: const Text('Profile'), content: const Text('Profile details here'), actions: [TextButton(onPressed: ()=> Navigator.pop(c), child: const Text('Close'))])); }),
              ListTile(title: const Text('Order history'), leading: const Icon(Icons.receipt_long), onTap: () { Navigator.pop(ctx); setState(() => _selectedIndex = 2); }),
              ListTile(title: const Text('Favourite Items'), leading: const Icon(Icons.favorite), onTap: () { Navigator.pop(ctx); showDialog(context: context, builder: (c)=> AlertDialog(title: const Text('Favourite Items'), content: const Text('Your favourites list is empty.'), actions: [TextButton(onPressed: ()=> Navigator.pop(c), child: const Text('Close'))])); }),
              ListTile(title: const Text('Monthly Cost History'), leading: const Icon(Icons.pie_chart), onTap: () { Navigator.pop(ctx); showDialog(context: context, builder: (c)=> AlertDialog(title: const Text('Monthly Cost History'), content: const Text('Monthly summary not yet implemented.'), actions: [TextButton(onPressed: ()=> Navigator.pop(c), child: const Text('Close'))])); }),
              ListTile(title: const Text('Settings'), leading: const Icon(Icons.settings), onTap: () { Navigator.pop(ctx); showDialog(context: context, builder: (c)=> AlertDialog(title: const Text('Settings'), content: const Text('Settings page not yet implemented.'), actions: [TextButton(onPressed: ()=> Navigator.pop(c), child: const Text('Close'))])); }),
              ListTile(title: const Text('About'), leading: const Icon(Icons.info), onTap: () { Navigator.pop(ctx); showAboutDialog(context: context, applicationName: 'Halal Dinning App', applicationVersion: '1.0.0'); }),
              ListTile(title: const Text('Logout'), leading: const Icon(Icons.logout), onTap: () { Navigator.pop(ctx); Navigator.pushNamedAndRemoveUntil(context, '/firebase-login', (r)=> false); }),
            ],
          ),
        );
      },
    );
  }
}
