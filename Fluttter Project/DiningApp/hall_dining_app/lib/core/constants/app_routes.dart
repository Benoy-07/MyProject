class AppRoutes {
  // Auth Routes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  
  // Main App Routes
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  
  // Menu Routes
  static const String menu = '/menu';
  static const String menuDetail = '/menu/detail';
  static const String menuList = '/menu/list';
  
  // Booking Routes
  static const String booking = '/booking';
  static const String bookingConfirmation = '/booking/confirmation';
  static const String bookingHistory = '/booking/history';
  static const String bookingDetail = '/booking/detail';
  
  // Payment Routes
  static const String payment = '/payment';
  static const String paymentSuccess = '/payment/success';
  static const String paymentFailed = '/payment/failed';
  
  // Subscription Routes
  static const String subscriptionPlans = '/subscription/plans';
  static const String subscriptionDetail = '/subscription/detail';
  static const String subscriptionHistory = '/subscription/history';
  
  // Profile Routes
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  
  // Feedback Routes
  static const String feedback = '/feedback';
  static const String feedbackList = '/feedback/list';
  static const String feedbackDetail = '/feedback/detail';
  
  // Event Routes
  static const String events = '/events';
  static const String eventDetail = '/events/detail';
  static const String eventBooking = '/events/booking';
  
  // Loyalty Routes
  static const String loyalty = '/loyalty';
  static const String redeemPoints = '/loyalty/redeem';
  static const String loyaltyHistory = '/loyalty/history';
  
  // Budget Routes
  static const String budgetTracker = '/budget/tracker';
  static const String budgetSettings = '/budget/settings';
  
  // QR Code Routes
  static const String qrDisplay = '/qr/display';
  static const String qrScanner = '/qr/scanner';
  
  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminMenuManagement = '/admin/menu';
  static const String adminBookingManagement = '/admin/bookings';
  static const String adminUserManagement = '/admin/users';
  static const String adminAnalytics = '/admin/analytics';
  
  // Settings Routes
  static const String settings = '/settings';
  static const String notificationSettings = '/settings/notifications';
  static const String languageSettings = '/settings/language';
  static const String privacySettings = '/settings/privacy';
  
  // Utility method to get route name without parameters
  static String getRouteName(String fullRoute) {
    final uri = Uri.parse(fullRoute);
    return uri.path;
  }
  
  // Route parameters keys
  static const String paramMenuId = 'menuId';
  static const String paramBookingId = 'bookingId';
  static const String paramPaymentId = 'paymentId';
  static const String paramEventId = 'eventId';
  static const String paramUserId = 'userId';
}