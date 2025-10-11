class ApiEndpoints {
  // Base URLs
  static const String baseUrl = 'https://your-api-domain.com/api';
  static const String firebaseBaseUrl = 'https://your-project.firebaseio.com';
  
  // Authentication Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  
  // User Endpoints
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/update';
  static const String changePassword = '/users/change-password';
  
  // Menu Endpoints
  static const String menus = '/menus';
  static const String todaysMenu = '/menus/today';
  static const String menuByDate = '/menus/date';
  static const String menuCategories = '/menus/categories';
  
  // Booking Endpoints
  static const String bookings = '/bookings';
  static const String createBooking = '/bookings/create';
  static const String cancelBooking = '/bookings/cancel';
  static const String bookingHistory = '/bookings/history';
  static const String upcomingBookings = '/bookings/upcoming';
  
  // Payment Endpoints
  static const String payments = '/payments';
  static const String initiatePayment = '/payments/initiate';
  static const String verifyPayment = '/payments/verify';
  static const String paymentHistory = '/payments/history';
  
  // Subscription Endpoints
  static const String subscriptions = '/subscriptions';
  static const String subscriptionPlans = '/subscriptions/plans';
  static const String subscribe = '/subscriptions/subscribe';
  static const String cancelSubscription = '/subscriptions/cancel';
  
  // Feedback Endpoints
  static const String feedback = '/feedback';
  static const String submitFeedback = '/feedback/submit';
  static const String feedbackHistory = '/feedback/history';
  
  // Notification Endpoints
  static const String notifications = '/notifications';
  static const String markAsRead = '/notifications/read';
  static const String notificationPreferences = '/notifications/preferences';
  
  // Admin Endpoints
  static const String adminStats = '/admin/stats';
  static const String adminUsers = '/admin/users';
  static const String adminBookings = '/admin/bookings';
  static const String adminMenuManagement = '/admin/menus';
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String menusCollection = 'menus';
  static const String bookingsCollection = 'bookings';
  static const String paymentsCollection = 'payments';
  static const String subscriptionsCollection = 'subscriptions';
  static const String feedbackCollection = 'feedback';
  static const String notificationsCollection = 'notifications';
  
  // Storage Paths
  static const String menuImagesPath = 'menu_images/';
  static const String userAvatarsPath = 'user_avatars/';
  static const String qrCodesPath = 'qr_codes/';
}

class ApiTimeout {
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
}

class ApiHeaders {
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}