import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hall_dining_app/providers/auth_provider.dart';
import 'package:hall_dining_app/providers/booking_provider.dart';
import 'package:hall_dining_app/providers/language_provider.dart';
import 'package:hall_dining_app/providers/menu_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}