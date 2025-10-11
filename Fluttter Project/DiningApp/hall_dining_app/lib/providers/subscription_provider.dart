class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final BillingCycle billingCycle;
  final int duration; // in days
  final int totalMeals;
  final List<String> includedMeals; // breakfast, lunch, dinner
  final List<PlanFeature> features;
  final bool isActive;
  final int maxDailyBookings;
  final double discountPercentage;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.billingCycle,
    required this.duration,
    required this.totalMeals,
    required this.includedMeals,
    required this.features,
    this.isActive = true,
    this.maxDailyBookings = 3,
    this.discountPercentage = 0.0,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'billingCycle': billingCycle.toString().split('.').last,
      'duration': duration,
      'totalMeals': totalMeals,
      'includedMeals': includedMeals,
      'features': features.map((f) => f.toMap()).toList(),
      'isActive': isActive,
      'maxDailyBookings': maxDailyBookings,
      'discountPercentage': discountPercentage,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory SubscriptionPlan.fromMap(Map<String, dynamic> map) {
    return SubscriptionPlan(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      billingCycle: _parseBillingCycle(map['billingCycle']),
      duration: map['duration'] ?? 30,
      totalMeals: map['totalMeals'] ?? 90,
      includedMeals: List<String>.from(map['includedMeals'] ?? []),
      features: List<PlanFeature>.from(
        (map['features'] ?? []).map((f) => PlanFeature.fromMap(f)),
      ),
      isActive: map['isActive'] ?? true,
      maxDailyBookings: map['maxDailyBookings'] ?? 3,
      discountPercentage: (map['discountPercentage'] ?? 0).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }

  static BillingCycle _parseBillingCycle(String cycle) {
    switch (cycle) {
      case 'daily':
        return BillingCycle.daily;
      case 'weekly':
        return BillingCycle.weekly;
      case 'monthly':
        return BillingCycle.monthly;
      case 'quarterly':
        return BillingCycle.quarterly;
      case 'yearly':
        return BillingCycle.yearly;
      default:
        return BillingCycle.monthly;
    }
  }

  // Helper methods
  bool get includesBreakfast => includedMeals.contains('breakfast');
  bool get includesLunch => includedMeals.contains('lunch');
  bool get includesDinner => includedMeals.contains('dinner');

  double get pricePerMeal {
    return totalMeals > 0 ? price / totalMeals : 0;
  }

  String get displayBillingCycle {
    switch (billingCycle) {
      case BillingCycle.daily:
        return 'Daily';
      case BillingCycle.weekly:
        return 'Weekly';
      case BillingCycle.monthly:
        return 'Monthly';
      case BillingCycle.quarterly:
        return 'Quarterly';
      case BillingCycle.yearly:
        return 'Yearly';
    }
  }

  String get displayDuration {
    if (duration >= 365) {
      final years = (duration / 365).floor();
      return '$years year${years > 1 ? 's' : ''}';
    } else if (duration >= 30) {
      final months = (duration / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    } else if (duration >= 7) {
      final weeks = (duration / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''}';
    } else {
      return '$duration day${duration > 1 ? 's' : ''}';
    }
  }

  SubscriptionPlan copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    BillingCycle? billingCycle,
    int? duration,
    int? totalMeals,
    List<String>? includedMeals,
    List<PlanFeature>? features,
    bool? isActive,
    int? maxDailyBookings,
    double? discountPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      billingCycle: billingCycle ?? this.billingCycle,
      duration: duration ?? this.duration,
      totalMeals: totalMeals ?? this.totalMeals,
      includedMeals: includedMeals ?? this.includedMeals,
      features: features ?? this.features,
      isActive: isActive ?? this.isActive,
      maxDailyBookings: maxDailyBookings ?? this.maxDailyBookings,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PlanFeature {
  final String name;
  final String description;
  final bool isAvailable;

  const PlanFeature({
    required this.name,
    required this.description,
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'isAvailable': isAvailable,
    };
  }

  factory PlanFeature.fromMap(Map<String, dynamic> map) {
    return PlanFeature(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  PlanFeature copyWith({
    String? name,
    String? description,
    bool? isAvailable,
  }) {
    return PlanFeature(
      name: name ?? this.name,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

class UserSubscription {
  final String id;
  final String userId;
  final String planId;
  final String planName;
  final double planPrice;
  final BillingCycle billingCycle;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? nextBillingDate;
  final SubscriptionStatus status;
  final int mealsUsed;
  final int totalMeals;
  final bool autoRenew;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final List<SubscriptionUsage> usageHistory;

  UserSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.planName,
    required this.planPrice,
    required this.billingCycle,
    required this.startDate,
    required this.endDate,
    this.nextBillingDate,
    required this.status,
    this.mealsUsed = 0,
    required this.totalMeals,
    this.autoRenew = true,
    required this.createdAt,
    this.updatedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.usageHistory = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'planId': planId,
      'planName': planName,
      'planPrice': planPrice,
      'billingCycle': billingCycle.toString().split('.').last,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'nextBillingDate': nextBillingDate?.millisecondsSinceEpoch,
      'status': status.toString().split('.').last,
      'mealsUsed': mealsUsed,
      'totalMeals': totalMeals,
      'autoRenew': autoRenew,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'cancelledAt': cancelledAt?.millisecondsSinceEpoch,
      'cancellationReason': cancellationReason,
      'usageHistory': usageHistory.map((u) => u.toMap()).toList(),
    };
  }

  factory UserSubscription.fromMap(Map<String, dynamic> map) {
    return UserSubscription(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      planId: map['planId'] ?? '',
      planName: map['planName'] ?? '',
      planPrice: (map['planPrice'] ?? 0).toDouble(),
      billingCycle: _parseBillingCycle(map['billingCycle']),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      nextBillingDate: map['nextBillingDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['nextBillingDate'])
          : null,
      status: _parseSubscriptionStatus(map['status']),
      mealsUsed: map['mealsUsed'] ?? 0,
      totalMeals: map['totalMeals'] ?? 0,
      autoRenew: map['autoRenew'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      cancelledAt: map['cancelledAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['cancelledAt'])
          : null,
      cancellationReason: map['cancellationReason'],
      usageHistory: List<SubscriptionUsage>.from(
        (map['usageHistory'] ?? []).map((u) => SubscriptionUsage.fromMap(u)),
      ),
    );
  }

  static BillingCycle _parseBillingCycle(String cycle) {
    switch (cycle) {
      case 'daily':
        return BillingCycle.daily;
      case 'weekly':
        return BillingCycle.weekly;
      case 'monthly':
        return BillingCycle.monthly;
      case 'quarterly':
        return BillingCycle.quarterly;
      case 'yearly':
        return BillingCycle.yearly;
      default:
        return BillingCycle.monthly;
    }
  }

  static SubscriptionStatus _parseSubscriptionStatus(String status) {
    switch (status) {
      case 'active':
        return SubscriptionStatus.active;
      case 'inactive':
        return SubscriptionStatus.inactive;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'pending':
        return SubscriptionStatus.pending;
      default:
        return SubscriptionStatus.inactive;
    }
  }

  // Helper methods
  int get mealsRemaining => totalMeals - mealsUsed;
  double get usagePercentage => totalMeals > 0 ? (mealsUsed / totalMeals) * 100 : 0;
  bool get isActive => status == SubscriptionStatus.active;
  bool get isExpired => status == SubscriptionStatus.expired;
  bool get canRenew => status == SubscriptionStatus.expired || status == SubscriptionStatus.cancelled;

  int get daysRemaining {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 0;
    return endDate.difference(now).inDays;
  }

  bool canBookMeal(String mealType) {
    if (!isActive) return false;
    if (mealsUsed >= totalMeals) return false;
    
    // Check if user hasn't exceeded daily booking limit for this meal type
    final today = DateTime.now();
    final todayUsage = usageHistory.where((usage) =>
      usage.usageDate.year == today.year &&
      usage.usageDate.month == today.month &&
      usage.usageDate.day == today.day &&
      usage.mealType == mealType
    ).length;
    
    return todayUsage < 1; // Allow one booking per meal type per day
  }

  UserSubscription copyWith({
    String? id,
    String? userId,
    String? planId,
    String? planName,
    double? planPrice,
    BillingCycle? billingCycle,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextBillingDate,
    SubscriptionStatus? status,
    int? mealsUsed,
    int? totalMeals,
    bool? autoRenew,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    List<SubscriptionUsage>? usageHistory,
  }) {
    return UserSubscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      planPrice: planPrice ?? this.planPrice,
      billingCycle: billingCycle ?? this.billingCycle,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      status: status ?? this.status,
      mealsUsed: mealsUsed ?? this.mealsUsed,
      totalMeals: totalMeals ?? this.totalMeals,
      autoRenew: autoRenew ?? this.autoRenew,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      usageHistory: usageHistory ?? this.usageHistory,
    );
  }
}

class SubscriptionUsage {
  final String id;
  final String subscriptionId;
  final String bookingId;
  final String mealType;
  final DateTime usageDate;
  final double mealValue;

  SubscriptionUsage({
    required this.id,
    required this.subscriptionId,
    required this.bookingId,
    required this.mealType,
    required this.usageDate,
    this.mealValue = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subscriptionId': subscriptionId,
      'bookingId': bookingId,
      'mealType': mealType,
      'usageDate': usageDate.millisecondsSinceEpoch,
      'mealValue': mealValue,
    };
  }

  factory SubscriptionUsage.fromMap(Map<String, dynamic> map) {
    return SubscriptionUsage(
      id: map['id'] ?? '',
      subscriptionId: map['subscriptionId'] ?? '',
      bookingId: map['bookingId'] ?? '',
      mealType: map['mealType'] ?? '',
      usageDate: DateTime.fromMillisecondsSinceEpoch(map['usageDate']),
      mealValue: (map['mealValue'] ?? 0).toDouble(),
    );
  }

  SubscriptionUsage copyWith({
    String? id,
    String? subscriptionId,
    String? bookingId,
    String? mealType,
    DateTime? usageDate,
    double? mealValue,
  }) {
    return SubscriptionUsage(
      id: id ?? this.id,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      bookingId: bookingId ?? this.bookingId,
      mealType: mealType ?? this.mealType,
      usageDate: usageDate ?? this.usageDate,
      mealValue: mealValue ?? this.mealValue,
    );
  }
}

enum BillingCycle {
  daily,
  weekly,
  monthly,
  quarterly,
  yearly,
}

enum SubscriptionStatus {
  active,
  inactive,
  cancelled,
  expired,
  pending,
}