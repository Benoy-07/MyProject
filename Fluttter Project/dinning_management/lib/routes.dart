import 'package:dinning_management/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
//import 'screens/auth/login_screen.dart';
import 'screens/menu_display_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/order_confirmation_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/qr_verification_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/budget_tracker_screen.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    '/': (context) => SplashScreen(),
    '/login': (context) => LoginScreen(),
    '/menu': (context) => MenuDisplayScreen(),
    '/booking': (context) => BookingScreen(),
    '/payment': (context) => PaymentScreen(),
    '/confirm': (context) => OrderConfirmationScreen(),
    '/history': (context) => OrderHistoryScreen(),
    '/feedback': (context) => FeedbackScreen(),
    '/subscription': (context) => SubscriptionScreen(),
    //'/qr': (context) => QrVerificationScreen(),
    '/profile': (context) => ProfileScreen(),
    '/budget': (context) => BudgetTrackerScreen(),
  };
}
