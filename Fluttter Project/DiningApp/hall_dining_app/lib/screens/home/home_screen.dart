import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../menu/menu_list_screen.dart';
import '../booking/booking_history_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MenuListScreen(),
    const BookingHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  void _initializeProviders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    if (authProvider.user != null) {
      menuProvider.initialize();
      bookingProvider.initialize(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.isBengali ? 'হল ডাইনিং ব্যবস্থাপনা' : 'Hall Dining Management',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.restaurant_menu),
            label: languageProvider.isBengali ? 'মেনু' : 'Menu',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: languageProvider.isBengali ? 'অর্ডার' : 'Orders',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: languageProvider.isBengali ? 'প্রোফাইল' : 'Profile',
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          languageProvider.isBengali ? 'লগআউট' : 'Logout',
        ),
        content: Text(
          languageProvider.isBengali 
              ? 'আপনি কি নিশ্চিত যে আপনি লগআউট করতে চান?'
              : 'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              languageProvider.isBengali ? 'বাতিল' : 'Cancel',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text(
              languageProvider.isBengali ? 'লগআউট' : 'Logout',
            ),
          ),
        ],
      ),
    );
  }
}