class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? actionUrl;
  final String? senderId;
  final List<String>? targetUsers;
  final DateTime? expiresAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
    this.data,
    this.imageUrl,
    this.actionUrl,
    this.senderId,
    this.targetUsers,
    this.expiresAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'isRead': isRead,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'readAt': readAt?.millisecondsSinceEpoch,
      'data': data ?? {},
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'senderId': senderId,
      'targetUsers': targetUsers ?? [],
      'expiresAt': expiresAt?.millisecondsSinceEpoch,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: _parseNotificationType(map['type']),
      priority: _parseNotificationPriority(map['priority']),
      isRead: map['isRead'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      readAt: map['readAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['readAt'])
          : null,
      data: map['data'] ?? {},
      imageUrl: map['imageUrl'],
      actionUrl: map['actionUrl'],
      senderId: map['senderId'],
      targetUsers: List<String>.from(map['targetUsers'] ?? []),
      expiresAt: map['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expiresAt'])
          : null,
    );
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'booking':
        return NotificationType.booking;
      case 'payment':
        return NotificationType.payment;
      case 'menu':
        return NotificationType.menu;
      case 'event':
        return NotificationType.event;
      case 'system':
        return NotificationType.system;
      case 'promotion':
        return NotificationType.promotion;
      case 'reminder':
        return NotificationType.reminder;
      default:
        return NotificationType.system;
    }
  }

  static NotificationPriority _parseNotificationPriority(String priority) {
    switch (priority) {
      case 'low':
        return NotificationPriority.low;
      case 'normal':
        return NotificationPriority.normal;
      case 'high':
        return NotificationPriority.high;
      case 'urgent':
        return NotificationPriority.urgent;
      default:
        return NotificationPriority.normal;
    }
  }

  // Helper methods
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get hasAction => actionUrl != null && actionUrl!.isNotEmpty;

  String get displayPriority {
    switch (priority) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }

  String get displayType {
    switch (type) {
      case NotificationType.booking:
        return 'Booking';
      case NotificationType.payment:
        return 'Payment';
      case NotificationType.menu:
        return 'Menu Update';
      case NotificationType.event:
        return 'Event';
      case NotificationType.system:
        return 'System';
      case NotificationType.promotion:
        return 'Promotion';
      case NotificationType.reminder:
        return 'Reminder';
    }
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
    String? senderId,
    List<String>? targetUsers,
    DateTime? expiresAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      senderId: senderId ?? this.senderId,
      targetUsers: targetUsers ?? this.targetUsers,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

enum NotificationType {
  booking,
  payment,
  menu,
  event,
  system,
  promotion,
  reminder,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

class NotificationPreferences {
  final bool bookingNotifications;
  final bool paymentNotifications;
  final bool menuUpdateNotifications;
  final bool eventNotifications;
  final bool promotionNotifications;
  final bool reminderNotifications;
  final bool systemNotifications;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;

  const NotificationPreferences({
    this.bookingNotifications = true,
    this.paymentNotifications = true,
    this.menuUpdateNotifications = true,
    this.eventNotifications = true,
    this.promotionNotifications = true,
    this.reminderNotifications = true,
    this.systemNotifications = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingNotifications': bookingNotifications,
      'paymentNotifications': paymentNotifications,
      'menuUpdateNotifications': menuUpdateNotifications,
      'eventNotifications': eventNotifications,
      'promotionNotifications': promotionNotifications,
      'reminderNotifications': reminderNotifications,
      'systemNotifications': systemNotifications,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'smsNotifications': smsNotifications,
    };
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      bookingNotifications: map['bookingNotifications'] ?? true,
      paymentNotifications: map['paymentNotifications'] ?? true,
      menuUpdateNotifications: map['menuUpdateNotifications'] ?? true,
      eventNotifications: map['eventNotifications'] ?? true,
      promotionNotifications: map['promotionNotifications'] ?? true,
      reminderNotifications: map['reminderNotifications'] ?? true,
      systemNotifications: map['systemNotifications'] ?? true,
      emailNotifications: map['emailNotifications'] ?? true,
      pushNotifications: map['pushNotifications'] ?? true,
      smsNotifications: map['smsNotifications'] ?? false,
    );
  }

  NotificationPreferences copyWith({
    bool? bookingNotifications,
    bool? paymentNotifications,
    bool? menuUpdateNotifications,
    bool? eventNotifications,
    bool? promotionNotifications,
    bool? reminderNotifications,
    bool? systemNotifications,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
  }) {
    return NotificationPreferences(
      bookingNotifications: bookingNotifications ?? this.bookingNotifications,
      paymentNotifications: paymentNotifications ?? this.paymentNotifications,
      menuUpdateNotifications: menuUpdateNotifications ?? this.menuUpdateNotifications,
      eventNotifications: eventNotifications ?? this.eventNotifications,
      promotionNotifications: promotionNotifications ?? this.promotionNotifications,
      reminderNotifications: reminderNotifications ?? this.reminderNotifications,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
    );
  }
}