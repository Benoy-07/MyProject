import 'package:flutter/material.dart';
import 'package:halldinningapp/admin/admin_dashboard.dart';
import 'services/firebase_auth_service.dart';
import 'auth/signup_page.dart';
import 'auth/login_page.dart';
import 'auth/otp_verification_page.dart';
import 'auth/password_setup_page.dart';
import 'auth/firebase_login_page.dart';
import 'auth/firebase_signup_page.dart';
import 'auth/email_verification_page.dart';
import 'screens/home_page.dart';
import 'screens/meal_detail_page.dart';
import 'screens/my_meal.dart';
import 'screens/my_order.dart';
import 'screens/notifications_page.dart';
import 'screens/cart_page.dart';
import 'screens/payment_page.dart';
import 'screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'services/cart_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase (safe to call on all platforms)
  await FirebaseAuthService.initializeFirebase();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService2()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Halal Dinning App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
        '/otp': (context) {
          final email = ModalRoute.of(context)?.settings.arguments as String?;
          return OTPVerificationPage(email: email ?? '');
        },
        '/password': (context) {
          final email = ModalRoute.of(context)?.settings.arguments as String?;
          return PasswordSetupPage(email: email ?? '');
        },
        // Firebase Routes
        '/firebase-login': (context) => const FirebaseLoginPage(),
        '/firebase-signup': (context) => const FirebaseSignupPage(),
        '/email-verification': (context) {
          final email = ModalRoute.of(context)?.settings.arguments as String?;
          return EmailVerificationPage(email: email ?? 'your@email.com');
        },
        '/firebase-home': (context) => const HomePage(),
        '/meal-detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
          final meal = args?['meal'] ?? 'Breakfast';
          return MealDetailPage(meal: meal);
        },
        '/my-meal': (context) => const MyMealPage(),
        '/my-order': (context) => const MyOrderPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/cart': (context) => const CartPage(),
        '/payment': (context) => const PaymentPage(),
        '/admin-dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}

