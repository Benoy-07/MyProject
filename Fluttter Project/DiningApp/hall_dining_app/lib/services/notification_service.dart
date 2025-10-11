import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';
import '../services/firestore_service.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final FirestoreService _firestoreService = FirestoreService();

  // Initialize notifications
  static Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('Notification permission: ${settings.authorizationStatus}');

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Configure foreground message handling
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Configure background message handling
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    
    // Configure notification channel for Android
    await _setupNotificationChannel();
    
    // Get FCM token
    await _getFCMToken();
  }

  // Setup notification channel for Android
  static Future<void> _setupNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'hall_dining_channel',
      'Hall Dining Notifications',
      description: 'Notifications for meal bookings, payments, and updates',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Get FCM token
  static Future<void> _getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        // You might want to save this token to your backend or Firestore
        await _saveFCMToken(token);
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  // Save FCM token to Firestore
  static Future<void> _saveFCMToken(String token) async {
    // Implementation depends on your user management system
    // You might want to save it to the user's document in Firestore
  }

  // Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');
    
    _showLocalNotification(
      title: message.notification?.title ?? 'Hall Dining',
      body: message.notification?.body ?? '',
      payload: json.encode(message.data),
    );
  }

  // Handle background messages
  static void _handleBackgroundMessage(RemoteMessage message) {
    print('Received background message: ${message.messageId}');
    
    // You can handle navigation based on message data
    _handleNotificationData(message.data);
  }

  // Show local notification
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'hall_dining_channel',
      'Hall Dining Notifications',
      channelDescription: 'Notifications for meal bookings and updates',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Handle notification response
  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      final data = json.decode(response.payload!);
      _handleNotificationData(Map<String, dynamic>.from(data));
    }
  }

  // Handle iOS local notification
  static void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    // Handle iOS local notification when app is in foreground
    if (payload != null) {
      final data = json.decode(payload);
      _handleNotificationData(Map<String, dynamic>.from(data));
    }
  }

  // Handle notification data and navigate accordingly
  static void _handleNotificationData(Map<String, dynamic> data) {
    final type = data['type'];
    final id = data['id'];
    
    // You can implement navigation logic based on notification type and data
    switch (type) {
      case 'booking':
        // Navigate to booking details
        break;
      case 'payment':
        // Navigate to payment details
        break;
      case 'menu':
        // Navigate to menu
        break;
      case 'event':
        // Navigate to event details
        break;
      default:
        // Navigate to home
        break;
    }
  }

  // Schedule notification
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Scheduled notifications for meal reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.schedule(
      scheduledTime.millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      scheduledTime,
      details,
      payload: payload,
    );
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Send booking confirmation notification
  static Future<void> sendBookingConfirmation({
    required String userId,
    required String bookingId,
    required String mealType,
    required DateTime bookingDate,
  }) async {
    final title = 'Booking Confirmed!';
    final body = 'Your $mealType booking for ${_formatDate(bookingDate)} has been confirmed.';

    await _createNotificationInFirestore(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.booking,
      data: {'bookingId': bookingId, 'type': 'booking'},
    );

    await _showLocalNotification(
      title: title,
      body: body,
      payload: json.encode({'bookingId': bookingId, 'type': 'booking'}),
    );
  }

  // Send payment confirmation notification
  static Future<void> sendPaymentConfirmation({
    required String userId,
    required String paymentId,
    required double amount,
  }) async {
    final title = 'Payment Successful';
    final body = 'Payment of ৳${amount.toStringAsFixed(2)} has been processed successfully.';

    await _createNotificationInFirestore(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.payment,
      data: {'paymentId': paymentId, 'type': 'payment'},
    );

    await _showLocalNotification(
      title: title,
      body: body,
      payload: json.encode({'paymentId': paymentId, 'type': 'payment'}),
    );
  }

  // Send meal reminder notification
  static Future<void> sendMealReminder({
    required String userId,
    required String mealType,
    required DateTime mealTime,
  }) async {
    final title = 'Meal Reminder';
    final body = 'Your $mealType is ready! Don\'t forget to collect it.';

    await _createNotificationInFirestore(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.reminder,
      data: {'mealType': mealType, 'type': 'reminder'},
    );

    await _showLocalNotification(
      title: title,
      body: body,
      payload: json.encode({'mealType': mealType, 'type': 'reminder'}),
    );
  }

  // Send event reminder notification
  static Future<void> sendEventReminder({
    required String userId,
    required String eventTitle,
    required DateTime eventTime,
  }) async {
    final title = 'Event Reminder';
    final body = 'Don\'t forget: $eventTitle starts soon!';

    await _createNotificationInFirestore(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.event,
      data: {'eventTitle': eventTitle, 'type': 'event'},
    );

    await _showLocalNotification(
      title: title,
      body: body,
      payload: json.encode({'eventTitle': eventTitle, 'type': 'event'}),
    );
  }

  // Create notification in Firestore
  static Future<void> _createNotificationInFirestore({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      priority: NotificationPriority.normal,
      isRead: false,
      createdAt: DateTime.now(),
      data: data,
      targetUsers: [userId],
    );

    // You would save this to Firestore using FirestoreService
    // await _firestoreService.createNotification(notification);
  }

  // Helper method to format date
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Subscribe to topics
  static Future<void> subscribeToTopics(String userId) async {
    await _firebaseMessaging.subscribeToTopic('all_users');
    await _firebaseMessaging.subscribeToTopic('user_$userId');
  }

  // Unsubscribe from topics
  static Future<void> unsubscribeFromTopics(String userId) async {
    await _firebaseMessaging.unsubscribeFromTopic('all_users');
    await _firebaseMessaging.unsubscribeFromTopic('user_$userId');
  }
}