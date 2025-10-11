class PriceFormatter {
  // Format price with currency symbol
  static String formatPrice(double price, {String currency = '৳'}) {
    return '$currency${price.toStringAsFixed(2)}';
  }
  
  // Format price with thousands separator
  static String formatPriceWithSeparator(double price, {String currency = '৳'}) {
    final parts = price.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];
    
    String formattedInteger = '';
    for (int i = integerPart.length - 1, j = 0; i >= 0; i--, j++) {
      if (j > 0 && j % 3 == 0) {
        formattedInteger = ',$formattedInteger';
      }
      formattedInteger = integerPart[i] + formattedInteger;
    }
    
    return '$currency$formattedInteger.$decimalPart';
  }
  
  // Format price for display in a compact way
  static String formatCompactPrice(double price, {String currency = '৳'}) {
    if (price < 1000) {
      return formatPrice(price, currency: currency);
    } else if (price < 100000) {
      final value = price / 1000;
      return '${currency}${value.toStringAsFixed(1)}K';
    } else if (price < 10000000) {
      final value = price / 100000;
      return '${currency}${value.toStringAsFixed(1)}L';
    } else {
      final value = price / 10000000;
      return '${currency}${value.toStringAsFixed(1)}Cr';
    }
  }
  
  // Calculate discounted price
  static double calculateDiscountedPrice(double originalPrice, double discountPercent) {
    return originalPrice - (originalPrice * discountPercent / 100);
  }
  
  // Format discount percentage
  static String formatDiscount(double discountPercent) {
    return '${discountPercent.toStringAsFixed(0)}% OFF';
  }
  
  // Calculate tax amount
  static double calculateTax(double amount, double taxRate) {
    return amount * taxRate / 100;
  }
  
  // Calculate total with tax
  static double calculateTotalWithTax(double amount, double taxRate) {
    return amount + calculateTax(amount, taxRate);
  }
  
  // Format price range
  static String formatPriceRange(double minPrice, double maxPrice, {String currency = '৳'}) {
    return '${formatPrice(minPrice, currency: currency)} - ${formatPrice(maxPrice, currency: currency)}';
  }
  
  // Parse price from string
  static double? parsePrice(String priceString) {
    try {
      // Remove currency symbol and commas
      final cleanedString = priceString.replaceAll(RegExp(r'[^\d.]'), '');
      return double.parse(cleanedString);
    } catch (e) {
      return null;
    }
  }
  
  // Check if price is free
  static bool isFree(double price) {
    return price == 0;
  }
  
  // Format free price
  static String formatFree() {
    return 'Free';
  }
}