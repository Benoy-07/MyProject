class Budget {
  final String userId;
  final double monthlyLimit;
  final double currentSpending;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<BudgetCategory> categories;
  final BudgetAlertLevel alertLevel;
  final DateTime lastReset;

  Budget({
    required this.userId,
    required this.monthlyLimit,
    this.currentSpending = 0.0,
    required this.periodStart,
    required this.periodEnd,
    this.categories = const [],
    this.alertLevel = BudgetAlertLevel.normal,
    required this.lastReset,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'monthlyLimit': monthlyLimit,
      'currentSpending': currentSpending,
      'periodStart': periodStart.millisecondsSinceEpoch,
      'periodEnd': periodEnd.millisecondsSinceEpoch,
      'categories': categories.map((c) => c.toMap()).toList(),
      'alertLevel': alertLevel.toString().split('.').last,
      'lastReset': lastReset.millisecondsSinceEpoch,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      userId: map['userId'] ?? '',
      monthlyLimit: (map['monthlyLimit'] ?? 0).toDouble(),
      currentSpending: (map['currentSpending'] ?? 0).toDouble(),
      periodStart: DateTime.fromMillisecondsSinceEpoch(map['periodStart']),
      periodEnd: DateTime.fromMillisecondsSinceEpoch(map['periodEnd']),
      categories: List<BudgetCategory>.from(
        (map['categories'] ?? []).map((c) => BudgetCategory.fromMap(c)),
      ),
      alertLevel: _parseBudgetAlertLevel(map['alertLevel']),
      lastReset: DateTime.fromMillisecondsSinceEpoch(map['lastReset']),
    );
  }

  static BudgetAlertLevel _parseBudgetAlertLevel(String level) {
    switch (level) {
      case 'normal':
        return BudgetAlertLevel.normal;
      case 'warning':
        return BudgetAlertLevel.warning;
      case 'critical':
        return BudgetAlertLevel.critical;
      default:
        return BudgetAlertLevel.normal;
    }
  }

  // Helper methods
  double get remainingBudget => monthlyLimit - currentSpending;
  double get usagePercentage => monthlyLimit > 0 ? (currentSpending / monthlyLimit) * 100 : 0;
  bool get isOverBudget => currentSpending > monthlyLimit;
  
  int get daysRemainingInPeriod {
    final now = DateTime.now();
    if (periodEnd.isBefore(now)) return 0;
    return periodEnd.difference(now).inDays;
  }

  double get dailyAverageSpending {
    final daysPassed = DateTime.now().difference(periodStart).inDays;
    return daysPassed > 0 ? currentSpending / daysPassed : 0;
  }

  double get projectedMonthlySpending {
    final daysInMonth = periodEnd.difference(periodStart).inDays;
    final daysPassed = DateTime.now().difference(periodStart).inDays;
    return daysPassed > 0 ? (currentSpending / daysPassed) * daysInMonth : 0;
  }

  BudgetAlertLevel calculateAlertLevel() {
    final percentage = usagePercentage;
    if (percentage >= 90) return BudgetAlertLevel.critical;
    if (percentage >= 75) return BudgetAlertLevel.warning;
    return BudgetAlertLevel.normal;
  }

  Budget copyWith({
    String? userId,
    double? monthlyLimit,
    double? currentSpending,
    DateTime? periodStart,
    DateTime? periodEnd,
    List<BudgetCategory>? categories,
    BudgetAlertLevel? alertLevel,
    DateTime? lastReset, required DateTime lastUpdated,
  }) {
    return Budget(
      userId: userId ?? this.userId,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      currentSpending: currentSpending ?? this.currentSpending,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      categories: categories ?? this.categories,
      alertLevel: alertLevel ?? this.alertLevel,
      lastReset: lastReset ?? this.lastReset,
    );
  }
}

class BudgetCategory {
  final String name;
  final double allocatedAmount;
  final double spentAmount;
  final String color;

  BudgetCategory({
    required this.name,
    required this.allocatedAmount,
    this.spentAmount = 0.0,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'allocatedAmount': allocatedAmount,
      'spentAmount': spentAmount,
      'color': color,
    };
  }

  factory BudgetCategory.fromMap(Map<String, dynamic> map) {
    return BudgetCategory(
      name: map['name'] ?? '',
      allocatedAmount: (map['allocatedAmount'] ?? 0).toDouble(),
      spentAmount: (map['spentAmount'] ?? 0).toDouble(),
      color: map['color'] ?? '#000000',
    );
  }

  double get remainingAmount => allocatedAmount - spentAmount;
  double get usagePercentage => allocatedAmount > 0 ? (spentAmount / allocatedAmount) * 100 : 0;
  bool get isOverBudget => spentAmount > allocatedAmount;

  BudgetCategory copyWith({
    String? name,
    double? allocatedAmount,
    double? spentAmount,
    String? color,
  }) {
    return BudgetCategory(
      name: name ?? this.name,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      color: color ?? this.color,
    );
  }
}

class SpendingRecord {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final String description;
  final DateTime spentAt;
  final String? bookingId;
  final String? paymentId;
  final SpendingType type;

  SpendingRecord({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.description,
    required this.spentAt,
    this.bookingId,
    this.paymentId,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'category': category,
      'description': description,
      'spentAt': spentAt.millisecondsSinceEpoch,
      'bookingId': bookingId,
      'paymentId': paymentId,
      'type': type.toString().split('.').last,
    };
  }

  factory SpendingRecord.fromMap(Map<String, dynamic> map) {
    return SpendingRecord(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      spentAt: DateTime.fromMillisecondsSinceEpoch(map['spentAt']),
      bookingId: map['bookingId'],
      paymentId: map['paymentId'],
      type: _parseSpendingType(map['type']),
    );
  }

  static SpendingType _parseSpendingType(String type) {
    switch (type) {
      case 'meal':
        return SpendingType.meal;
      case 'subscription':
        return SpendingType.subscription;
      case 'event':
        return SpendingType.event;
      case 'other':
        return SpendingType.other;
      default:
        return SpendingType.meal;
    }
  }
}

enum BudgetAlertLevel {
  normal,
  warning,
  critical,
}

enum SpendingType {
  meal,
  subscription,
  event,
  other,
}