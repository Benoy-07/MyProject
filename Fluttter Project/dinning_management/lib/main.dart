import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/local_db_service.dart';

// TODO: add your generated firebase_options.dart from FlutterFire CLI
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  // initialize local DB
  await LocalDbService.init();

  // init notifications
  //await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        // add other providers (Cart, Booking, Loyalty)
      ],
      child: MyApp(),
    ),
  );
}
