import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';
import '../services/prefs_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    // Show splash for a short duration while checking
    await Future.delayed(const Duration(milliseconds: 700));
    final isAdmin = await PrefsService.getBool('is_admin_logged_in');
    if (isAdmin) {
      // There is no dedicated admin route in the app routes map.
      // Redirect admin users to the main home page for now.
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    // If Firebase user exists OR we stored a user_logged_in flag, go to normal home
    final user = FirebaseAuthService.getCurrentUser();
    final userLoggedFlag = await PrefsService.getBool('user_logged_in');
    if (user != null || userLoggedFlag) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    // otherwise, show login
    Navigator.pushReplacementNamed(context, '/firebase-login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf6d365), Color(0xFFfda085)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
