import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';

class NotificationProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<AppNotification> _notifications = [];
  List<AppNotification> _unreadNotifications = [];
  NotificationPreferences _preferences = const NotificationPreferences();
  bool _isLoading = false;
  String _error = '';
  bool _hasNewNotifications = false;

  List<AppNotification> get notifications => _notifications;
  List<AppNotification> get unreadNotifications => _unreadNotifications;
  NotificationPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasNewNotifications => _hasNewNotifications;
  int get unreadCount => _unreadNotifications.length;

  // Initialize provider
  void initialize(String userId) {
    _loadUserNotifications(userId);
    _loadNotificationPreferences();
  }

  // Load user notifications
  Future<void> _loadUserNotifications(String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _firestoreService.getUserNotificationsStream(userId).listen((notifications) {
        _notifications = notifications;
        _unreadNotifications = notifications.where((n) => !n.isRead).toList();
        _hasNewNotifications = _unreadNotifications.isNotEmpty;
        _isLoading = false;
        notifyListeners();
      }, onError: (error) {
        _error = 'Failed to load notifications: $error';
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Failed to load notifications: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load notification preferences
  Future<void> _loadNotificationPreferences() async {
    try {
      // In a real app, you would load this from Firestore or SharedPreferences
      // For now, we'll use default preferences
      _preferences = const NotificationPreferences();
      notifyListeners();
    } catch (e) {
      print('Failed to load notification preferences: $e');
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _firestoreService.markNotificationAsRead(notificationId);
      
      // Update local state
      final notificationIndex = _notifications.indexWhere((n) => n.id == notificationId);
      if (notificationIndex != -1) {
        _notifications[notificationIndex] = _notifications[notificationIndex].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
        
        _unreadNotifications.removeWhere((n) => n.id == notificationId);
        _hasNewNotifications = _unreadNotifications.isNotEmpty;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to mark notification as read: $e';
      notifyListeners();
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    _isLoading = true;
    notifyListeners();

    try {
      for (final notification in _unreadNotifications) {
        await _firestoreService.markNotificationAsRead(notification.id);
      }
      
      // Update local state
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }
      }
      
      _unreadNotifications.clear();
      _hasNewNotifications = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to mark all notifications as read: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      // In a real app, you would delete from Firestore
      // For now, we'll just update local state
      _notifications.removeWhere((n) => n.id == notificationId);
      _unreadNotifications.removeWhere((n) => n.id == notificationId);
      _hasNewNotifications = _unreadNotifications.isNotEmpty;
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete notification: $e';
      notifyListeners();
      return false;
    }
  }

  // Clear all notifications
  Future<bool> clearAllNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, you would delete from Firestore
      // For now, we'll just clear local state
      _notifications.clear();
      _unreadNotifications.clear();
      _hasNewNotifications = false;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to clear all notifications: $e';
      notifyListeners();
      return false;
    }
  }

  // Update notification preferences
  Future<bool> updatePreferences(NotificationPreferences newPreferences) async {
    _isLoading = true;
    notifyListeners();

    try {
      _preferences = newPreferences;
      
      // Save to Firestore or SharedPreferences
      // await _savePreferencesToFirestore(newPreferences);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update preferences: $e';
      notifyListeners();
      return false;
    }
  }

  // Get notifications by type
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Get unread notifications by type
  List<AppNotification> getUnreadNotificationsByType(NotificationType type) {
    return _unreadNotifications.where((n) => n.type == type).toList();
  }

  // Check if notification type is enabled
  bool isNotificationTypeEnabled(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return _preferences.bookingNotifications;
      case NotificationType.payment:
        return _preferences.paymentNotifications;
      case NotificationType.menu:
        return _preferences.menuUpdateNotifications;
      case NotificationType.event:
        return _preferences.eventNotifications;
      case NotificationType.promotion:
        return _preferences.promotionNotifications;
      case NotificationType.reminder:
        return _preferences.reminderNotifications;
      case NotificationType.system:
        return _preferences.systemNotifications;
    }
  }

  // Get notification statistics
  Map<String, dynamic> getNotificationStats() {
    return {
      'totalNotifications': _notifications.length,
      'unreadNotifications': _unreadNotifications.length,
      'readNotifications': _notifications.length - _unreadNotifications.length,
      'hasNewNotifications': _hasNewNotifications,
    };
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Refresh notifications
  Future<void> refreshNotifications(String userId) async {
    _loadUserNotifications(userId);
  }
}