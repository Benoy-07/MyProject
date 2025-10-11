class LoyaltyProgram {
  final String id;
  final String name;
  final String description;
  final int pointsPerMeal;
  final int pointsPerTaka;
  final double discountPerPoint;
  final int minPointsForRedemption;
  final int maxRedemptionPerOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LoyaltyProgram({
    required this.id,
    required this.name,
    required this.description,
    this.pointsPerMeal = 10,
    this.pointsPerTaka = 1,
    this.discountPerPoint = 0.1,
    this.minPointsForRedemption = 100,
    this.maxRedemptionPerOrder = 1000,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pointsPerMeal': pointsPerMeal,
      'pointsPerTaka': pointsPerTaka,
      'discountPerPoint': discountPerPoint,
      'minPointsForRedemption': minPointsForRedemption,
      'maxRedemptionPerOrder': maxRedemptionPerOrder,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory LoyaltyProgram.fromMap(Map<String, dynamic> map) {
    return LoyaltyProgram(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      pointsPerMeal: map['pointsPerMeal'] ?? 10,
      pointsPerTaka: map['pointsPerTaka'] ?? 1,
      discountPerPoint: (map['discountPerPoint'] ?? 0.1).toDouble(),
      minPointsForRedemption: map['minPointsForRedemption'] ?? 100,
      maxRedemptionPerOrder: map['maxRedemptionPerOrder'] ?? 1000,
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }

  double calculateDiscount(int points) {
    final usablePoints = points.clamp(0, maxRedemptionPerOrder);
    return usablePoints * discountPerPoint;
  }

  int calculatePoints(double amount) {
    return (amount * pointsPerTaka).floor();
  }
}

class UserLoyalty {
  final String userId;
  final int totalPoints;
  final int availablePoints;
  final int usedPoints;
  final int pendingPoints;
  final DateTime lastUpdated;
  final LoyaltyTier tier;
  final List<LoyaltyTransaction> transactions;

  UserLoyalty({
    required this.userId,
    required this.totalPoints,
    required this.availablePoints,
    this.usedPoints = 0,
    this.pendingPoints = 0,
    required this.lastUpdated,
    this.tier = LoyaltyTier.bronze,
    this.transactions = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'availablePoints': availablePoints,
      'usedPoints': usedPoints,
      'pendingPoints': pendingPoints,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'tier': tier.toString().split('.').last,
      'transactions': transactions.map((t) => t.toMap()).toList(),
    };
  }

  factory UserLoyalty.fromMap(Map<String, dynamic> map) {
    return UserLoyalty(
      userId: map['userId'] ?? '',
      totalPoints: map['totalPoints'] ?? 0,
      availablePoints: map['availablePoints'] ?? 0,
      usedPoints: map['usedPoints'] ?? 0,
      pendingPoints: map['pendingPoints'] ?? 0,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated']),
      tier: _parseLoyaltyTier(map['tier']),
      transactions: List<LoyaltyTransaction>.from(
        (map['transactions'] ?? []).map((t) => LoyaltyTransaction.fromMap(t)),
      ),
    );
  }

  static LoyaltyTier _parseLoyaltyTier(String tier) {
    switch (tier) {
      case 'bronze':
        return LoyaltyTier.bronze;
      case 'silver':
        return LoyaltyTier.silver;
      case 'gold':
        return LoyaltyTier.gold;
      case 'platinum':
        return LoyaltyTier.platinum;
      default:
        return LoyaltyTier.bronze;
    }
  }

  bool get canRedeem => availablePoints >= 100; // Minimum redemption points
  double get potentialDiscount => availablePoints * 0.1; // 0.1 Taka per point

  String get tierName {
    switch (tier) {
      case LoyaltyTier.bronze:
        return 'Bronze';
      case LoyaltyTier.silver:
        return 'Silver';
      case LoyaltyTier.gold:
        return 'Gold';
      case LoyaltyTier.platinum:
        return 'Platinum';
    }
  }

  UserLoyalty copyWith({
    String? userId,
    int? totalPoints,
    int? availablePoints,
    int? usedPoints,
    int? pendingPoints,
    DateTime? lastUpdated,
    LoyaltyTier? tier,
    List<LoyaltyTransaction>? transactions,
  }) {
    return UserLoyalty(
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      availablePoints: availablePoints ?? this.availablePoints,
      usedPoints: usedPoints ?? this.usedPoints,
      pendingPoints: pendingPoints ?? this.pendingPoints,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      tier: tier ?? this.tier,
      transactions: transactions ?? this.transactions,
    );
  }
}

class LoyaltyTransaction {
  final String id;
  final String userId;
  final LoyaltyTransactionType type;
  final int points;
  final int balanceBefore;
  final int balanceAfter;
  final String description;
  final String? referenceId;
  final DateTime transactionDate;
  final LoyaltyTransactionStatus status;

  LoyaltyTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.points,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.description,
    this.referenceId,
    required this.transactionDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'points': points,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'description': description,
      'referenceId': referenceId,
      'transactionDate': transactionDate.millisecondsSinceEpoch,
      'status': status.toString().split('.').last,
    };
  }

  factory LoyaltyTransaction.fromMap(Map<String, dynamic> map) {
    return LoyaltyTransaction(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: _parseLoyaltyTransactionType(map['type']),
      points: map['points'] ?? 0,
      balanceBefore: map['balanceBefore'] ?? 0,
      balanceAfter: map['balanceAfter'] ?? 0,
      description: map['description'] ?? '',
      referenceId: map['referenceId'],
      transactionDate: DateTime.fromMillisecondsSinceEpoch(map['transactionDate']),
      status: _parseLoyaltyTransactionStatus(map['status']),
    );
  }

  static LoyaltyTransactionType _parseLoyaltyTransactionType(String type) {
    switch (type) {
      case 'earn':
        return LoyaltyTransactionType.earn;
      case 'redeem':
        return LoyaltyTransactionType.redeem;
      case 'expire':
        return LoyaltyTransactionType.expire;
      case 'adjustment':
        return LoyaltyTransactionType.adjustment;
      default:
        return LoyaltyTransactionType.earn;
    }
  }

  static LoyaltyTransactionStatus _parseLoyaltyTransactionStatus(String status) {
    switch (status) {
      case 'pending':
        return LoyaltyTransactionStatus.pending;
      case 'completed':
        return LoyaltyTransactionStatus.completed;
      case 'failed':
        return LoyaltyTransactionStatus.failed;
      default:
        return LoyaltyTransactionStatus.pending;
    }
  }

  bool get isEarned => type == LoyaltyTransactionType.earn;
  bool get isRedeemed => type == LoyaltyTransactionType.redeem;
}

enum LoyaltyTier {
  bronze,
  silver,
  gold,
  platinum,
}

enum LoyaltyTransactionType {
  earn,
  redeem,
  expire,
  adjustment,
}

enum LoyaltyTransactionStatus {
  pending,
  completed,
  failed,
}