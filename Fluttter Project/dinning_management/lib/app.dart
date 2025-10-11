import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'screens/splash_screen.dart';
import 'routes.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return MaterialApp(
      title: 'Dinning Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // Add your generated delegate if using intl
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('bn', ''), // Bengali
      ],
      initialRoute: '/',
      routes: AppRoutes.routes,
    );
  }
}
