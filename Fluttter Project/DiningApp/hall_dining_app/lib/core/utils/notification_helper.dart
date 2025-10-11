import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hall_dining_app/core/utils/date_formatter.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initializationSettings);
  }

  // Show simple notification
  static Future<void> showSimpleNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'hall_dining_channel',
      'Hall Dining Notifications',
      channelDescription: 'Notifications for meal bookings and updates',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details);
  }

  // Show scheduled notification
  static Future<void> showScheduledNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
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

    await _notifications.schedule(
      id,
      title,
      body,
      scheduledTime,
      details,
    );
  }

  // Show notification with payload
  static Future<void> showNotificationWithPayload({
    required String title,
    required String body,
    required String payload,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'payload_channel',
      'Notifications with Payload',
      channelDescription: 'Notifications that carry additional data',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Check notification permissions
  static Future<bool> checkPermissions() async {
    final settings = await _notifications.getNotificationAppLaunchDetails();
    return settings?.didNotificationLaunchApp ?? false;
  }

  // Meal booking reminder notification
  static Future<void> showMealReminder({
    required String mealType,
    required DateTime mealTime,
    int id = 0,
  }) async {
    final title = 'Meal Reminder';
    final body = 'Your $mealType is ready! Don\'t forget to collect it.';
    
    await showScheduledNotification(
      title: title,
      body: body,
      scheduledTime: mealTime.subtract(const Duration(minutes: 30)),
      id: id,
    );
  }

  // Payment confirmation notification
  static Future<void> showPaymentConfirmation({
    required double amount,
    required String bookingId,
    int id = 0,
  }) async {
    final title = 'Payment Confirmed';
    final body = 'Payment of ৳${amount.toStringAsFixed(2)} for booking #${bookingId.substring(0, 8)} has been confirmed.';
    
    await showSimpleNotification(
      title: title,
      body: body,
      id: id,
    );
  }

  // Booking confirmation notification
  static Future<void> showBookingConfirmation({
    required String mealType,
    required DateTime date,
    required String bookingId,
    int id = 0,
  }) async {
    final title = 'Booking Confirmed';
    final body = 'Your $mealType booking for ${DateFormatter.formatDisplayDate(date)} has been confirmed. Booking ID: #${bookingId.substring(0, 8)}';
    
    await showSimpleNotification(
      title: title,
      body: body,
      id: id,
    );
  }
}