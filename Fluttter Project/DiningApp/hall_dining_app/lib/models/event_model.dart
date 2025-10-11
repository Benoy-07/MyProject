class Event {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final DateTime startDate;
  final DateTime endDate;
  final String? imageUrl;
  final String location;
  final double? price;
  final int maxAttendees;
  final int currentAttendees;
  final bool isActive;
  final bool requiresBooking;
  final DateTime bookingDeadline;
  final List<EventMenu> specialMenu;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final Map<String, dynamic>? metadata;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
    required this.location,
    this.price,
    required this.maxAttendees,
    this.currentAttendees = 0,
    this.isActive = true,
    this.requiresBooking = true,
    required this.bookingDeadline,
    this.specialMenu = const [],
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      'location': location,
      'price': price,
      'maxAttendees': maxAttendees,
      'currentAttendees': currentAttendees,
      'isActive': isActive,
      'requiresBooking': requiresBooking,
      'bookingDeadline': bookingDeadline.millisecondsSinceEpoch,
      'specialMenu': specialMenu.map((menu) => menu.toMap()).toList(),
      'tags': tags,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'createdBy': createdBy,
      'metadata': metadata ?? {},
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: _parseEventType(map['type']),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      imageUrl: map['imageUrl'],
      location: map['location'] ?? '',
      price: map['price']?.toDouble(),
      maxAttendees: map['maxAttendees'] ?? 0,
      currentAttendees: map['currentAttendees'] ?? 0,
      isActive: map['isActive'] ?? true,
      requiresBooking: map['requiresBooking'] ?? true,
      bookingDeadline: DateTime.fromMillisecondsSinceEpoch(map['bookingDeadline']),
      specialMenu: List<EventMenu>.from(
        (map['specialMenu'] ?? []).map((menu) => EventMenu.fromMap(menu)),
      ),
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      createdBy: map['createdBy'],
      metadata: map['metadata'] ?? {},
    );
  }

  static EventType _parseEventType(String type) {
    switch (type) {
      case 'cultural':
        return EventType.cultural;
      case 'religious':
        return EventType.religious;
      case 'social':
        return EventType.social;
      case 'educational':
        return EventType.educational;
      case 'sports':
        return EventType.sports;
      case 'food_festival':
        return EventType.foodFestival;
      default:
        return EventType.social;
    }
  }

  // Helper methods
  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isOngoing => 
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  bool get isPast => endDate.isBefore(DateTime.now());
  bool get hasSpotsAvailable => currentAttendees < maxAttendees;
  bool get canBook => 
      isActive && 
      hasSpotsAvailable && 
      DateTime.now().isBefore(bookingDeadline);
  bool get isFeatured => tags.contains('featured') || (metadata?.containsKey('isFeatured') ?? false);

  int get availableSpots => maxAttendees - currentAttendees;

  String get displayType {
    switch (type) {
      case EventType.cultural:
        return 'Cultural Event';
      case EventType.religious:
        return 'Religious Event';
      case EventType.social:
        return 'Social Gathering';
      case EventType.educational:
        return 'Educational';
      case EventType.sports:
        return 'Sports Event';
      case EventType.foodFestival:
        return 'Food Festival';
    }
  }

  String get priceDisplay {
    if (price == null || price == 0) return 'Free';
    return '৳${price!.toStringAsFixed(2)}';
  }

  Duration get duration => endDate.difference(startDate);

  Event copyWith({
    String? id,
    String? title,
    String? description,
    EventType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? imageUrl,
    String? location,
    double? price,
    int? maxAttendees,
    int? currentAttendees,
    bool? isActive,
    bool? requiresBooking,
    DateTime? bookingDeadline,
    List<EventMenu>? specialMenu,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    Map<String, dynamic>? metadata,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      price: price ?? this.price,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      currentAttendees: currentAttendees ?? this.currentAttendees,
      isActive: isActive ?? this.isActive,
      requiresBooking: requiresBooking ?? this.requiresBooking,
      bookingDeadline: bookingDeadline ?? this.bookingDeadline,
      specialMenu: specialMenu ?? this.specialMenu,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      metadata: metadata ?? this.metadata,
    );
  }
}

class EventMenu {
  final String id;
  final String name;
  final String description;
  final double? price;
  final String category;
  final bool isIncludedInPrice;
  final List<String> dietaryTags;

  EventMenu({
    required this.id,
    required this.name,
    required this.description,
    this.price,
    required this.category,
    this.isIncludedInPrice = false,
    this.dietaryTags = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'isIncludedInPrice': isIncludedInPrice,
      'dietaryTags': dietaryTags,
    };
  }

  factory EventMenu.fromMap(Map<String, dynamic> map) {
    return EventMenu(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble(),
      category: map['category'] ?? '',
      isIncludedInPrice: map['isIncludedInPrice'] ?? false,
      dietaryTags: List<String>.from(map['dietaryTags'] ?? []),
    );
  }
}

class EventBooking {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String userEmail;
  final DateTime bookingDate;
  final int numberOfGuests;
  final double totalAmount;
  final EventBookingStatus status;
  final String? paymentId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? specialRequirements;
  final List<String>? attendedGuests;
  final DateTime? checkedInAt;
  final String? checkedInBy;

  EventBooking({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.bookingDate,
    this.numberOfGuests = 1,
    this.totalAmount = 0.0,
    required this.status,
    this.paymentId,
    required this.createdAt,
    this.updatedAt,
    this.specialRequirements,
    this.attendedGuests,
    this.checkedInAt,
    this.checkedInBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'bookingDate': bookingDate.millisecondsSinceEpoch,
      'numberOfGuests': numberOfGuests,
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'paymentId': paymentId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'specialRequirements': specialRequirements,
      'attendedGuests': attendedGuests ?? [],
      'checkedInAt': checkedInAt?.millisecondsSinceEpoch,
      'checkedInBy': checkedInBy,
    };
  }

  factory EventBooking.fromMap(Map<String, dynamic> map) {
    return EventBooking(
      id: map['id'] ?? '',
      eventId: map['eventId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      bookingDate: DateTime.fromMillisecondsSinceEpoch(map['bookingDate']),
      numberOfGuests: map['numberOfGuests'] ?? 1,
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: _parseEventBookingStatus(map['status']),
      paymentId: map['paymentId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      specialRequirements: map['specialRequirements'],
      attendedGuests: List<String>.from(map['attendedGuests'] ?? []),
      checkedInAt: map['checkedInAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['checkedInAt'])
          : null,
      checkedInBy: map['checkedInBy'],
    );
  }

  static EventBookingStatus _parseEventBookingStatus(String status) {
    switch (status) {
      case 'confirmed':
        return EventBookingStatus.confirmed;
      case 'pending':
        return EventBookingStatus.pending;
      case 'cancelled':
        return EventBookingStatus.cancelled;
      case 'attended':
        return EventBookingStatus.attended;
      case 'noShow':
        return EventBookingStatus.noShow;
      default:
        return EventBookingStatus.pending;
    }
  }

  // Helper methods
  bool get canCancel => status == EventBookingStatus.confirmed || 
                        status == EventBookingStatus.pending;
  bool get isAttended => status == EventBookingStatus.attended;
  bool get isConfirmed => status == EventBookingStatus.confirmed;

  String get displayStatus {
    switch (status) {
      case EventBookingStatus.confirmed:
        return 'Confirmed';
      case EventBookingStatus.pending:
        return 'Pending';
      case EventBookingStatus.cancelled:
        return 'Cancelled';
      case EventBookingStatus.attended:
        return 'Attended';
      case EventBookingStatus.noShow:
        return 'No Show';
    }
  }

  EventBooking copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? userName,
    String? userEmail,
    DateTime? bookingDate,
    int? numberOfGuests,
    double? totalAmount,
    EventBookingStatus? status,
    String? paymentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? specialRequirements,
    List<String>? attendedGuests,
    DateTime? checkedInAt,
    String? checkedInBy,
  }) {
    return EventBooking(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      bookingDate: bookingDate ?? this.bookingDate,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentId: paymentId ?? this.paymentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      attendedGuests: attendedGuests ?? this.attendedGuests,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      checkedInBy: checkedInBy ?? this.checkedInBy,
    );
  }
}

enum EventType {
  cultural,
  religious,
  social,
  educational,
  sports,
  foodFestival,
}

enum EventBookingStatus {
  confirmed,
  pending,
  cancelled,
  attended,
  noShow,
}

enum PaymentMethod {
  cash,
  card,
  online, stripe, sslcommerz, nagad, bkash,
}