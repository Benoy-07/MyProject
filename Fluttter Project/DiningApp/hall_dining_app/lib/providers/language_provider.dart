import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en', 'US');
  bool _isLoading = false;

  Locale get locale => _locale;
  bool get isLoading => _isLoading;
  bool get isEnglish => _locale.languageCode == 'en';
  bool get isBengali => _locale.languageCode == 'bn';

  // Initialize provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load saved locale from preferences
      // final prefs = await SharedPreferences.getInstance();
      // final savedLocale = prefs.getString('locale');
      
      // if (savedLocale != null) {
      //   _locale = Locale(savedLocale);
      // } else {
      //   // Use device locale or default to English
      //   final deviceLocale = WidgetsBinding.instance.window.locale;
      //   if (LocalizationService.supportedLocales.contains(deviceLocale)) {
      //     _locale = deviceLocale;
      //   } else {
      //     _locale = const Locale('en', 'US');
      //   }
      // }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set locale
  Future<void> setLocale(Locale newLocale) async {
    if (!LocalizationService.supportedLocales.contains(newLocale)) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _locale = newLocale;
      
      // Save to preferences
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('locale', newLocale.languageCode);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Toggle between English and Bengali
  Future<void> toggleLanguage() async {
    final newLocale = isEnglish ? const Locale('bn', 'BD') : const Locale('en', 'US');
    await setLocale(newLocale);
  }

  // Get supported locales
  List<Locale> get supportedLocales => LocalizationService.supportedLocales;

  // Get current language name
  String get currentLanguageName {
    switch (_locale.languageCode) {
      case 'en':
        return 'English';
      case 'bn':
        return 'বাংলা';
      default:
        return 'English';
    }
  }

  // Get language flag emoji
  String get currentLanguageFlag {
    switch (_locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'bn':
        return '🇧🇩';
      default:
        return '🇺🇸';
    }
  }

  // Check if locale is supported
  bool isLocaleSupported(Locale locale) {
    return LocalizationService.supportedLocales.contains(locale);
  }

  // Get locale display name
  String getLocaleDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'bn':
        return 'বাংলা (Bangla)';
      default:
        return locale.languageCode;
    }
  }
}