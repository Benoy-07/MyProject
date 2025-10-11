class Booking {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final DateTime bookingDate;
  final String mealType; // breakfast, lunch, dinner
  final List<BookingItem> items;
  final int totalQuantity;
  final double subtotal;
  final double tax;
  final double totalAmount;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? paymentId;
  final String? qrCodeData;
  final DateTime? collectedAt;
  final String? collectedBy;
  final String? cancellationReason;
  final DateTime? cancellationDate;
  final Map<String, dynamic>? specialInstructions;

  Booking({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.bookingDate,
    required this.mealType,
    required this.items,
    required this.totalQuantity,
    required this.subtotal,
    required this.tax,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.paymentId,
    this.qrCodeData,
    this.collectedAt,
    this.collectedBy,
    this.cancellationReason,
    this.cancellationDate,
    this.specialInstructions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'bookingDate': bookingDate.millisecondsSinceEpoch,
      'mealType': mealType,
      'items': items.map((item) => item.toMap()).toList(),
      'totalQuantity': totalQuantity,
      'subtotal': subtotal,
      'tax': tax,
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'paymentId': paymentId,
      'qrCodeData': qrCodeData,
      'collectedAt': collectedAt?.millisecondsSinceEpoch,
      'collectedBy': collectedBy,
      'cancellationReason': cancellationReason,
      'cancellationDate': cancellationDate?.millisecondsSinceEpoch,
      'specialInstructions': specialInstructions ?? {},
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userName: map['userName'] ?? '',
      bookingDate: DateTime.fromMillisecondsSinceEpoch(map['bookingDate']),
      mealType: map['mealType'] ?? '',
      items: List<BookingItem>.from(
        (map['items'] ?? []).map((item) => BookingItem.fromMap(item)),
      ),
      totalQuantity: map['totalQuantity'] ?? 0,
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      tax: (map['tax'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: _parseBookingStatus(map['status']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      paymentId: map['paymentId'],
      qrCodeData: map['qrCodeData'],
      collectedAt: map['collectedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['collectedAt'])
          : null,
      collectedBy: map['collectedBy'],
      cancellationReason: map['cancellationReason'],
      cancellationDate: map['cancellationDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['cancellationDate'])
          : null,
      specialInstructions: map['specialInstructions'] ?? {},
    );
  }

  static BookingStatus _parseBookingStatus(String status) {
    switch (status) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'preparing':
        return BookingStatus.preparing;
      case 'ready':
        return BookingStatus.ready;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'expired':
        return BookingStatus.expired;
      default:
        return BookingStatus.pending;
    }
  }

  // Helper methods
  bool get canCancel => status == BookingStatus.pending || status == BookingStatus.confirmed;
  bool get canModify => status == BookingStatus.pending;
  bool get isCollected => status == BookingStatus.completed;
  bool get isActive => ![
    BookingStatus.cancelled,
    BookingStatus.expired,
    BookingStatus.completed,
  ].contains(status);

  String get formattedBookingDate {
    return '${bookingDate.day}/${bookingDate.month}/${bookingDate.year}';
  }

  String get displayStatus {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.preparing:
        return 'Preparing';
      case BookingStatus.ready:
        return 'Ready for Pickup';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.expired:
        return 'Expired';
    }
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? userName,
    DateTime? bookingDate,
    String? mealType,
    List<BookingItem>? items,
    int? totalQuantity,
    double? subtotal,
    double? tax,
    double? totalAmount,
    BookingStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? paymentId,
    String? qrCodeData,
    DateTime? collectedAt,
    String? collectedBy,
    String? cancellationReason,
    DateTime? cancellationDate,
    Map<String, dynamic>? specialInstructions,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      bookingDate: bookingDate ?? this.bookingDate,
      mealType: mealType ?? this.mealType,
      items: items ?? this.items,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentId: paymentId ?? this.paymentId,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      collectedAt: collectedAt ?? this.collectedAt,
      collectedBy: collectedBy ?? this.collectedBy,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancellationDate: cancellationDate ?? this.cancellationDate,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}

class BookingItem {
  final String menuItemId;
  final String menuItemName;
  final double unitPrice;
  final int quantity;
  final String? imageUrl;
  final Map<String, dynamic>? customizations;
  final String? specialInstructions;

  BookingItem({
    required this.menuItemId,
    required this.menuItemName,
    required this.unitPrice,
    required this.quantity,
    this.imageUrl,
    this.customizations,
    this.specialInstructions,
  });

  Map<String, dynamic> toMap() {
    return {
      'menuItemId': menuItemId,
      'menuItemName': menuItemName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'customizations': customizations ?? {},
      'specialInstructions': specialInstructions,
    };
  }

  factory BookingItem.fromMap(Map<String, dynamic> map) {
    return BookingItem(
      menuItemId: map['menuItemId'] ?? '',
      menuItemName: map['menuItemName'] ?? '',
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      imageUrl: map['imageUrl'],
      customizations: map['customizations'] ?? {},
      specialInstructions: map['specialInstructions'],
    );
  }

  double get totalPrice => unitPrice * quantity;

  BookingItem copyWith({
    String? menuItemId,
    String? menuItemName,
    double? unitPrice,
    int? quantity,
    String? imageUrl,
    Map<String, dynamic>? customizations,
    String? specialInstructions,
  }) {
    return BookingItem(
      menuItemId: menuItemId ?? this.menuItemId,
      menuItemName: menuItemName ?? this.menuItemName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      customizations: customizations ?? this.customizations,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}

enum BookingStatus {
  pending,
  confirmed,
  preparing,
  ready,
  completed,
  cancelled,
  expired,
}

class BookingStats {
  final int totalBookings;
  final int pendingBookings;
  final int completedBookings;
  final int cancelledBookings;
  final double totalRevenue;
  final double averageOrderValue;
  final Map<String, int> bookingsByMealType;
  final Map<String, int> bookingsByDay;

  const BookingStats({
    required this.totalBookings,
    required this.pendingBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.bookingsByMealType,
    required this.bookingsByDay,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalBookings': totalBookings,
      'pendingBookings': pendingBookings,
      'completedBookings': completedBookings,
      'cancelledBookings': cancelledBookings,
      'totalRevenue': totalRevenue,
      'averageOrderValue': averageOrderValue,
      'bookingsByMealType': bookingsByMealType,
      'bookingsByDay': bookingsByDay,
    };
  }

  factory BookingStats.fromMap(Map<String, dynamic> map) {
    return BookingStats(
      totalBookings: map['totalBookings'] ?? 0,
      pendingBookings: map['pendingBookings'] ?? 0,
      completedBookings: map['completedBookings'] ?? 0,
      cancelledBookings: map['cancelledBookings'] ?? 0,
      totalRevenue: (map['totalRevenue'] ?? 0).toDouble(),
      averageOrderValue: (map['averageOrderValue'] ?? 0).toDouble(),
      bookingsByMealType: Map<String, int>.from(map['bookingsByMealType'] ?? {}),
      bookingsByDay: Map<String, int>.from(map['bookingsByDay'] ?? {}),
    );
  }
}