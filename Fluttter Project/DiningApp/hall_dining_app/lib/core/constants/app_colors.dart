import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFFE55A2B);
  static const Color primaryLight = Color(0xFFFF8E63);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color secondaryDark = Color(0xFF26A69A);
  
  // Neutral Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF212529);
  static const Color onSurfaceVariant = Color(0xFF495057);
  
  // Semantic Colors
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textDisabled = Color(0xFFADB5BD);
  
  // Border Colors
  static const Color border = Color(0xFFDEE2E6);
  static const Color borderLight = Color(0xFFE9ECEF);
  
  // Status Colors
  static const Color pending = Color(0xFFFFC107);
  static const Color confirmed = Color(0xFF28A745);
  static const Color cancelled = Color(0xFFDC3545);
  static const Color delivered = Color(0xFF17A2B8);
  
  // Gradient
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
}