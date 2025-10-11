class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    return null;
  }
  
  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    return null;
  }
  
  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
    
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }
  
  // Number validation
  static String? validateNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (number <= 0) {
      return '${fieldName ?? 'Number'} must be greater than 0';
    }
    
    return null;
  }
  
  // Positive integer validation
  static String? validatePositiveInteger(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    
    final integer = int.tryParse(value);
    if (integer == null) {
      return 'Please enter a valid whole number';
    }
    
    if (integer <= 0) {
      return '${fieldName ?? 'Number'} must be greater than 0';
    }
    
    return null;
  }
  
  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
  
  // Credit card validation (basic)
  static String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }
    
    // Remove spaces and dashes
    final cleanedValue = value.replaceAll(RegExp(r'[\s-]'), '');
    
    if (cleanedValue.length < 13 || cleanedValue.length > 19) {
      return 'Please enter a valid card number';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanedValue)) {
      return 'Card number must contain only digits';
    }
    
    return null;
  }
  
  // Expiry date validation
  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }
    
    final expiryRegex = RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$');
    
    if (!expiryRegex.hasMatch(value)) {
      return 'Please enter a valid expiry date (MM/YY)';
    }
    
    final parts = value.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}'); // Assuming 21st century
    
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Card has expired';
    }
    
    return null;
  }
  
  // CVV validation
  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }
    
    if (value.length < 3 || value.length > 4) {
      return 'CVV must be 3 or 4 digits';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'CVV must contain only digits';
    }
    
    return null;
  }
}