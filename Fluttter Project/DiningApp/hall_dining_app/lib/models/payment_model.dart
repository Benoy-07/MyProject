class Payment {
  final String id;
  final String userId;
  final String bookingId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? transactionId;
  final String? paymentGatewayResponse;
  final DateTime paymentDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? failureReason;
  final Map<String, dynamic>? metadata;

  Payment({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionId,
    this.paymentGatewayResponse,
    required this.paymentDate,
    required this.createdAt,
    this.updatedAt,
    this.failureReason,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bookingId': bookingId,
      'amount': amount,
      'method': method.toString().split('.').last,
      'status': status.toString().split('.').last,
      'transactionId': transactionId,
      'paymentGatewayResponse': paymentGatewayResponse,
      'paymentDate': paymentDate.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'failureReason': failureReason,
      'metadata': metadata ?? {},
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      bookingId: map['bookingId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      method: _parsePaymentMethod(map['method']),
      status: _parsePaymentStatus(map['status']),
      transactionId: map['transactionId'],
      paymentGatewayResponse: map['paymentGatewayResponse'],
      paymentDate: DateTime.fromMillisecondsSinceEpoch(map['paymentDate']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      failureReason: map['failureReason'],
      metadata: map['metadata'] ?? {},
    );
  }

  static PaymentMethod _parsePaymentMethod(String method) {
    switch (method) {
      case 'stripe':
        return PaymentMethod.stripe;
      case 'sslcommerz':
        return PaymentMethod.sslcommerz;
      case 'nagad':
        return PaymentMethod.nagad;
      case 'bkash':
        return PaymentMethod.bkash;
      case 'cash':
        return PaymentMethod.cash;
      case 'wallet':
        return PaymentMethod.wallet;
      default:
        return PaymentMethod.stripe;
    }
  }

  static PaymentStatus _parsePaymentStatus(String status) {
    switch (status) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'partially_refunded':
        return PaymentStatus.partiallyRefunded;
      default:
        return PaymentStatus.pending;
    }
  }

  // Helper methods
  bool get isSuccessful => status == PaymentStatus.completed;
  bool get isPending => status == PaymentStatus.pending;
  bool get isFailed => status == PaymentStatus.failed;
  bool get canRetry => status == PaymentStatus.failed;

  String get displayStatus {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.partiallyRefunded:
        return 'Partially Refunded';
    }
  }

  String get displayMethod {
    switch (method) {
      case PaymentMethod.stripe:
        return 'Credit/Debit Card';
      case PaymentMethod.sslcommerz:
        return 'SSLCommerz';
      case PaymentMethod.nagad:
        return 'Nagad';
      case PaymentMethod.bkash:
        return 'bKash';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.wallet:
        return 'Wallet';
    }
  }

  Payment copyWith({
    String? id,
    String? userId,
    String? bookingId,
    double? amount,
    PaymentMethod? method,
    PaymentStatus? status,
    String? transactionId,
    String? paymentGatewayResponse,
    DateTime? paymentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? failureReason,
    Map<String, dynamic>? metadata,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookingId: bookingId ?? this.bookingId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      paymentGatewayResponse: paymentGatewayResponse ?? this.paymentGatewayResponse,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      failureReason: failureReason ?? this.failureReason,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum PaymentMethod {
  stripe,
  sslcommerz,
  nagad,
  bkash,
  cash,
  wallet,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  partiallyRefunded,
}

class PaymentCard {
  final String id;
  final String userId;
  final String lastFourDigits;
  final String brand; // visa, mastercard, etc.
  final int expMonth;
  final int expYear;
  final bool isDefault;
  final DateTime createdAt;

  PaymentCard({
    required this.id,
    required this.userId,
    required this.lastFourDigits,
    required this.brand,
    required this.expMonth,
    required this.expYear,
    this.isDefault = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'lastFourDigits': lastFourDigits,
      'brand': brand,
      'expMonth': expMonth,
      'expYear': expYear,
      'isDefault': isDefault,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory PaymentCard.fromMap(Map<String, dynamic> map) {
    return PaymentCard(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      lastFourDigits: map['lastFourDigits'] ?? '',
      brand: map['brand'] ?? '',
      expMonth: map['expMonth'] ?? 0,
      expYear: map['expYear'] ?? 0,
      isDefault: map['isDefault'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  String get maskedNumber => '**** **** **** $lastFourDigits';
  String get expiryDate => '$expMonth/${expYear.toString().substring(2)}';

  PaymentCard copyWith({
    String? id,
    String? userId,
    String? lastFourDigits,
    String? brand,
    int? expMonth,
    int? expYear,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return PaymentCard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      brand: brand ?? this.brand,
      expMonth: expMonth ?? this.expMonth,
      expYear: expYear ?? this.expYear,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Wallet {
  final String userId;
  final double balance;
  final double pendingBalance;
  final DateTime lastUpdated;
  final List<WalletTransaction> transactions;

  Wallet({
    required this.userId,
    required this.balance,
    this.pendingBalance = 0.0,
    required this.lastUpdated,
    this.transactions = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'balance': balance,
      'pendingBalance': pendingBalance,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'transactions': transactions.map((t) => t.toMap()).toList(),
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      userId: map['userId'] ?? '',
      balance: (map['balance'] ?? 0).toDouble(),
      pendingBalance: (map['pendingBalance'] ?? 0).toDouble(),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated']),
      transactions: List<WalletTransaction>.from(
        (map['transactions'] ?? []).map((t) => WalletTransaction.fromMap(t)),
      ),
    );
  }

  bool get hasSufficientBalance => balance > 0;

  Wallet copyWith({
    String? userId,
    double? balance,
    double? pendingBalance,
    DateTime? lastUpdated,
    List<WalletTransaction>? transactions,
  }) {
    return Wallet(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      transactions: transactions ?? this.transactions,
    );
  }
}

class WalletTransaction {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String description;
  final String? referenceId;
  final DateTime transactionDate;
  final TransactionStatus status;

  WalletTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
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
      'amount': amount,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'description': description,
      'referenceId': referenceId,
      'transactionDate': transactionDate.millisecondsSinceEpoch,
      'status': status.toString().split('.').last,
    };
  }

  factory WalletTransaction.fromMap(Map<String, dynamic> map) {
    return WalletTransaction(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: _parseTransactionType(map['type']),
      amount: (map['amount'] ?? 0).toDouble(),
      balanceBefore: (map['balanceBefore'] ?? 0).toDouble(),
      balanceAfter: (map['balanceAfter'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      referenceId: map['referenceId'],
      transactionDate: DateTime.fromMillisecondsSinceEpoch(map['transactionDate']),
      status: _parseTransactionStatus(map['status']),
    );
  }

  static TransactionType _parseTransactionType(String type) {
    switch (type) {
      case 'topup':
        return TransactionType.topup;
      case 'payment':
        return TransactionType.payment;
      case 'refund':
        return TransactionType.refund;
      case 'bonus':
        return TransactionType.bonus;
      case 'withdrawal':
        return TransactionType.withdrawal;
      default:
        return TransactionType.payment;
    }
  }

  static TransactionStatus _parseTransactionStatus(String status) {
    switch (status) {
      case 'pending':
        return TransactionStatus.pending;
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      default:
        return TransactionStatus.pending;
    }
  }

  bool get isCredit => type == TransactionType.topup || 
                        type == TransactionType.refund || 
                        type == TransactionType.bonus;

  WalletTransaction copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    double? amount,
    double? balanceBefore,
    double? balanceAfter,
    String? description,
    String? referenceId,
    DateTime? transactionDate,
    TransactionStatus? status,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      balanceBefore: balanceBefore ?? this.balanceBefore,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      description: description ?? this.description,
      referenceId: referenceId ?? this.referenceId,
      transactionDate: transactionDate ?? this.transactionDate,
      status: status ?? this.status,
    );
  }
}

enum TransactionType {
  topup,
  payment,
  refund,
  bonus,
  withdrawal,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
}

class PaymentResult {
  final bool success;
  final String? transactionId;
  final PaymentStatus status;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  PaymentResult({
    required this.success,
    this.transactionId,
    required this.status,
    this.errorMessage,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'transactionId': transactionId,
      'status': status.toString().split('.').last,
      'errorMessage': errorMessage,
      'metadata': metadata ?? {},
    };
  }

  factory PaymentResult.fromMap(Map<String, dynamic> map) {
    return PaymentResult(
      success: map['success'] ?? false,
      transactionId: map['transactionId'],
      status: _parsePaymentStatus(map['status']),
      errorMessage: map['errorMessage'],
      metadata: map['metadata'] ?? {},
    );
  }

  get message => null;

  static PaymentStatus _parsePaymentStatus(String status) {
    switch (status) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'partially_refunded':
        return PaymentStatus.partiallyRefunded;
      default:
        return PaymentStatus.pending;
    }
  }

  PaymentResult copyWith({
    bool? success,
    String? transactionId,
    PaymentStatus? status,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentResult(
      success: success ?? this.success,
      transactionId: transactionId ?? this.transactionId,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }
}