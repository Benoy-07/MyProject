class Feedback {
  final String id;
  final String userId;
  final String userName;
  final String? userEmail;
  final String? bookingId;
  final String? menuItemId;
  final String? menuItemName;
  final FeedbackType type;
  final int rating;
  final String comment;
  final List<String>? images;
  final bool isAnonymous;
  final FeedbackStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminResponse;
  final DateTime? adminResponseDate;
  final String? respondedBy;
  final Map<String, dynamic>? metadata;

  Feedback({
    required this.id,
    required this.userId,
    required this.userName,
    this.userEmail,
    this.bookingId,
    this.menuItemId,
    this.menuItemName,
    required this.type,
    required this.rating,
    required this.comment,
    this.images,
    this.isAnonymous = false,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.adminResponse,
    this.adminResponseDate,
    this.respondedBy,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'bookingId': bookingId,
      'menuItemId': menuItemId,
      'menuItemName': menuItemName,
      'type': type.toString().split('.').last,
      'rating': rating,
      'comment': comment,
      'images': images ?? [],
      'isAnonymous': isAnonymous,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'adminResponse': adminResponse,
      'adminResponseDate': adminResponseDate?.millisecondsSinceEpoch,
      'respondedBy': respondedBy,
      'metadata': metadata ?? {},
    };
  }

  factory Feedback.fromMap(Map<String, dynamic> map) {
    return Feedback(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'],
      bookingId: map['bookingId'],
      menuItemId: map['menuItemId'],
      menuItemName: map['menuItemName'],
      type: _parseFeedbackType(map['type']),
      rating: map['rating'] ?? 0,
      comment: map['comment'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      isAnonymous: map['isAnonymous'] ?? false,
      status: _parseFeedbackStatus(map['status']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      adminResponse: map['adminResponse'],
      adminResponseDate: map['adminResponseDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['adminResponseDate'])
          : null,
      respondedBy: map['respondedBy'],
      metadata: map['metadata'] ?? {},
    );
  }

  static FeedbackType _parseFeedbackType(String type) {
    switch (type) {
      case 'menu_item':
        return FeedbackType.menuItem;
      case 'service':
        return FeedbackType.service;
      case 'facility':
        return FeedbackType.facility;
      case 'staff':
        return FeedbackType.staff;
      case 'general':
        return FeedbackType.general;
      default:
        return FeedbackType.general;
    }
  }

  static FeedbackStatus _parseFeedbackStatus(String status) {
    switch (status) {
      case 'pending':
        return FeedbackStatus.pending;
      case 'reviewed':
        return FeedbackStatus.reviewed;
      case 'resolved':
        return FeedbackStatus.resolved;
      case 'closed':
        return FeedbackStatus.closed;
      default:
        return FeedbackStatus.pending;
    }
  }

  // Helper methods
  bool get hasAdminResponse => adminResponse != null && adminResponse!.isNotEmpty;
  bool get isResolved => status == FeedbackStatus.resolved || status == FeedbackStatus.closed;
  bool get isHighPriority => rating <= 2; // Low ratings are high priority

  String get displayType {
    switch (type) {
      case FeedbackType.menuItem:
        return 'Menu Item';
      case FeedbackType.service:
        return 'Service';
      case FeedbackType.facility:
        return 'Facility';
      case FeedbackType.staff:
        return 'Staff';
      case FeedbackType.general:
        return 'General';
    }
  }

  String get displayStatus {
    switch (status) {
      case FeedbackStatus.pending:
        return 'Pending Review';
      case FeedbackStatus.reviewed:
        return 'Under Review';
      case FeedbackStatus.resolved:
        return 'Resolved';
      case FeedbackStatus.closed:
        return 'Closed';
    }
  }

  String get starRating {
    return '⭐' * rating;
  }

  Feedback copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? bookingId,
    String? menuItemId,
    String? menuItemName,
    FeedbackType? type,
    int? rating,
    String? comment,
    List<String>? images,
    bool? isAnonymous,
    FeedbackStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminResponse,
    DateTime? adminResponseDate,
    String? respondedBy,
    Map<String, dynamic>? metadata,
  }) {
    return Feedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      bookingId: bookingId ?? this.bookingId,
      menuItemId: menuItemId ?? this.menuItemId,
      menuItemName: menuItemName ?? this.menuItemName,
      type: type ?? this.type,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminResponse: adminResponse ?? this.adminResponse,
      adminResponseDate: adminResponseDate ?? this.adminResponseDate,
      respondedBy: respondedBy ?? this.respondedBy,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum FeedbackType {
  menuItem,
  service,
  facility,
  staff,
  general,
}

enum FeedbackStatus {
  pending,
  reviewed,
  resolved,
  closed,
}

class FeedbackStats {
  final int totalFeedback;
  final int pendingFeedback;
  final int resolvedFeedback;
  final double averageRating;
  final Map<int, int> ratingDistribution; // rating -> count
  final Map<String, int> feedbackByType;
  final Map<String, int> feedbackByDay;

  const FeedbackStats({
    required this.totalFeedback,
    required this.pendingFeedback,
    required this.resolvedFeedback,
    required this.averageRating,
    required this.ratingDistribution,
    required this.feedbackByType,
    required this.feedbackByDay,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalFeedback': totalFeedback,
      'pendingFeedback': pendingFeedback,
      'resolvedFeedback': resolvedFeedback,
      'averageRating': averageRating,
      'ratingDistribution': ratingDistribution,
      'feedbackByType': feedbackByType,
      'feedbackByDay': feedbackByDay,
    };
  }

  factory FeedbackStats.fromMap(Map<String, dynamic> map) {
    return FeedbackStats(
      totalFeedback: map['totalFeedback'] ?? 0,
      pendingFeedback: map['pendingFeedback'] ?? 0,
      resolvedFeedback: map['resolvedFeedback'] ?? 0,
      averageRating: (map['averageRating'] ?? 0).toDouble(),
      ratingDistribution: Map<int, int>.from(map['ratingDistribution'] ?? {}),
      feedbackByType: Map<String, int>.from(map['feedbackByType'] ?? {}),
      feedbackByDay: Map<String, int>.from(map['feedbackByDay'] ?? {}),
    );
  }

  double get resolutionRate {
    return totalFeedback > 0 ? (resolvedFeedback / totalFeedback) * 100 : 0;
  }
}