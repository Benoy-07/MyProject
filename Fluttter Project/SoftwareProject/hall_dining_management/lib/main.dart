import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hall_dining_management/admin/admin_homescreen.dart';
import 'package:hall_dining_management/auth/signin_page.dart';
import 'package:hall_dining_management/firebase_options.dart';
import 'package:hall_dining_management/service/auth_service.dart';
import 'package:hall_dining_management/user/user_homescreen.dart';
//import 'auth_service.dart';
//import 'signin_screen.dart';
//import 'admin_homescreen.dart';
//import 'user_homescreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HallDiningManagement());
}

class HallDiningManagement extends StatelessWidget {
  const HallDiningManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hall Dining Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<String>(
            future: AuthService().getUserRole(user.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }
              if (roleSnapshot.data == 'admin') {
                return const AdminHomeScreen();
              } else {
                return const UserHomeScreen();
              }
            },
          );
        } else {
          return const SignInScreen();
        }
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.restaurant,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Hall Dining',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              'Management',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}