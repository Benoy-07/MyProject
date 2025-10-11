import 'package:flutter/material.dart';
import 'package:hall_dining_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/localization_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: 'Hall Dining Management',
          theme: ThemeData(
            primarySwatch: Colors.orange,
            useMaterial3: true,
          ),
          locale: languageProvider.locale,
          supportedLocales: LocalizationService.supportedLocales,
          localizationsDelegates: const [
            // AppLocalizations.delegate,
            // GlobalMaterialLocalizations.delegate,
            // GlobalWidgetsLocalizations.delegate,
            // GlobalCupertinoLocalizations.delegate,
          ],
          home: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isLoading) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              return authProvider.user != null 
                  ? const HomeScreen()
                  : const LoginScreen();
            },
          ),
        );
      },
    );
  }
}