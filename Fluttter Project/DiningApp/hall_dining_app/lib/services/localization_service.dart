import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class LocalizationService {
  LocalizationService(this.locale);

  final Locale locale;
  static Map<String, String> _localizedStrings = {};

  static LocalizationService of(BuildContext context) {
    return Localizations.of<LocalizationService>(context, LocalizationService)!;
  }

  static Future<LocalizationService> load(Locale locale) async {
    LocalizationService localizationService = LocalizationService(locale);
    
    try {
      String jsonString = await rootBundle.loadString(
        'lib/l10n/app_${locale.languageCode}.arb',
      );
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });
    } catch (e) {
      // Fallback to English if the locale file doesn't exist
      if (locale.languageCode != 'en') {
        return await load(const Locale('en', 'US'));
      }
      print('Error loading localization: $e');
    }
    
    return localizationService;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Helper method for pluralization
  String translatePlural(String key, int count) {
    final pluralKey = count == 1 ? '${key}_one' : '${key}_other';
    return _localizedStrings[pluralKey] ?? translate(key);
  }

  // Get current locale
  Locale get currentLocale => locale;

  // Check if current locale is Bengali
  bool get isBengali => locale.languageCode == 'bn';

  // Supported locales
  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('bn', 'BD'),
  ];

  // Fallback locale
  static const fallbackLocale = Locale('en', 'US');

  // Localization delegates
  static const localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

// Extension for easy translation
extension LocalizationExtension on String {
  String tr(BuildContext context) {
    return LocalizationService.of(context).translate(this);
  }

  String trPlural(BuildContext context, int count) {
    return LocalizationService.of(context).translatePlural(this, count);
  }
}

// AppLocalizations for easier access
class AppLocalizations {
  final BuildContext context;

  AppLocalizations(this.context);

  String get appTitle => 'appTitle'.tr(context);
  String get welcome => 'welcome'.tr(context);
  String get login => 'login'.tr(context);
  String get register => 'register'.tr(context);
  String get email => 'email'.tr(context);
  String get password => 'password'.tr(context);
  String get name => 'name'.tr(context);
  String get menu => 'menu'.tr(context);
  String get breakfast => 'breakfast'.tr(context);
  String get lunch => 'lunch'.tr(context);
  String get dinner => 'dinner'.tr(context);
  String get bookNow => 'bookNow'.tr(context);
  String get price => 'price'.tr(context);
  String get addToCart => 'addToCart'.tr(context);
  String get payment => 'payment'.tr(context);
  String get totalAmount => 'totalAmount'.tr(context);
  String get selectPaymentMethod => 'selectPaymentMethod'.tr(context);
  String get payNow => 'payNow'.tr(context);
  String get bookingHistory => 'bookingHistory'.tr(context);
  String get profile => 'profile'.tr(context);
  String get logout => 'logout'.tr(context);
  String get settings => 'settings'.tr(context);
  String get language => 'language'.tr(context);
  String get notifications => 'notifications'.tr(context);
  String get help => 'help'.tr(context);

  // Validation messages
  String get emailRequired => 'emailRequired'.tr(context);
  String get validEmail => 'validEmail'.tr(context);
  String get passwordRequired => 'passwordRequired'.tr(context);
  String get passwordMinLength => 'passwordMinLength'.tr(context);
  String get passwordNotMatch => 'passwordNotMatch'.tr(context);
  String get nameRequired => 'nameRequired'.tr(context);

  // Booking related
  String bookingConfirmation(String mealType, String date) {
    return 'bookingConfirmation'.tr(context).replaceAll('{mealType}', mealType).replaceAll('{date}', date);
  }

  String itemsSelected(int count) {
    return 'itemsSelected'.trPlural(context, count).replaceAll('{count}', count.toString());
  }

  // Payment related
  String paymentSuccess(double amount) {
    return 'paymentSuccess'.tr(context).replaceAll('{amount}', amount.toStringAsFixed(2));
  }

  // Error messages
  String get somethingWentWrong => 'somethingWentWrong'.tr(context);
  String get noInternet => 'noInternet'.tr(context);
  String get tryAgain => 'tryAgain'.tr(context);

  // Success messages
  String get success => 'success'.tr(context);
  String get bookingSuccess => 'bookingSuccess'.tr(context);
  String get paymentSuccess => 'paymentSuccess'.tr(context);
  String get updateSuccess => 'updateSuccess'.tr(context);
}

// Provider for localization
class LocalizationProvider with ChangeNotifier {
  Locale _locale = const Locale('en', 'US');

  Locale get locale => _locale;
  bool get isBengali => _locale.languageCode == 'bn';

  void setLocale(Locale newLocale) {
    if (!LocalizationService.supportedLocales.contains(newLocale)) return;
    
    _locale = newLocale;
    notifyListeners();
  }

  void toggleLanguage() {
    _locale = isBengali ? const Locale('en', 'US') : const Locale('bn', 'BD');
    notifyListeners();
  }

  // Load saved locale from preferences
  Future<void> loadSavedLocale() async {
    // You can implement shared preferences here to load saved locale
    // For now, we'll use the device locale or default to English
    // final String? savedLocale = await SharedPreferences.getInstance().then((prefs) => prefs.getString('locale'));
    // if (savedLocale != null) {
    //   _locale = Locale(savedLocale);
    // }
    notifyListeners();
  }

  // Save locale to preferences
  Future<void> saveLocale(Locale locale) async {
    // await SharedPreferences.getInstance().then((prefs) => prefs.setString('locale', locale.languageCode));
  }
}