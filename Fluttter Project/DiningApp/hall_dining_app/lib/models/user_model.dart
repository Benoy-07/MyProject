class AppUser {
  final String uid;
  final String email;
  final String name;
  final String role; // 'student', 'admin', 'staff'
  final String? profileImage;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? phoneNumber;
  final String? hall;
  final String? roomNumber;
  final int loyaltyPoints;
  final Map<String, dynamic>? preferences;
  final bool isActive;
  final List<String> dietaryRestrictions;
  final double totalSpent;
  final int totalBookings;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.profileImage,
    required this.createdAt,
    this.updatedAt,
    this.phoneNumber,
    this.hall,
    this.roomNumber,
    this.loyaltyPoints = 0,
    this.preferences,
    this.isActive = true,
    this.dietaryRestrictions = const [],
    this.totalSpent = 0.0,
    this.totalBookings = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'profileImage': profileImage,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'phoneNumber': phoneNumber,
      'hall': hall,
      'roomNumber': roomNumber,
      'loyaltyPoints': loyaltyPoints,
      'preferences': preferences ?? {},
      'isActive': isActive,
      'dietaryRestrictions': dietaryRestrictions,
      'totalSpent': totalSpent,
      'totalBookings': totalBookings,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'student',
      profileImage: map['profileImage'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      phoneNumber: map['phoneNumber'],
      hall: map['hall'],
      roomNumber: map['roomNumber'],
      loyaltyPoints: map['loyaltyPoints'] ?? 0,
      preferences: map['preferences'] ?? {},
      isActive: map['isActive'] ?? true,
      dietaryRestrictions: List<String>.from(map['dietaryRestrictions'] ?? []),
      totalSpent: (map['totalSpent'] ?? 0).toDouble(),
      totalBookings: map['totalBookings'] ?? 0,
    );
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? phoneNumber,
    String? hall,
    String? roomNumber,
    int? loyaltyPoints,
    Map<String, dynamic>? preferences,
    bool? isActive,
    List<String>? dietaryRestrictions,
    double? totalSpent,
    int? totalBookings,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      hall: hall ?? this.hall,
      roomNumber: roomNumber ?? this.roomNumber,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      preferences: preferences ?? this.preferences,
      isActive: isActive ?? this.isActive,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      totalSpent: totalSpent ?? this.totalSpent,
      totalBookings: totalBookings ?? this.totalBookings,
    );
  }
}

class UserPreferences {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final String language;
  final String theme;
  final bool lowBalanceAlert;
  final double budgetLimit;
  final List<String> favoriteCategories;

  const UserPreferences({
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.language = 'en',
    this.theme = 'light',
    this.lowBalanceAlert = true,
    this.budgetLimit = 1000.0,
    this.favoriteCategories = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'smsNotifications': smsNotifications,
      'language': language,
      'theme': theme,
      'lowBalanceAlert': lowBalanceAlert,
      'budgetLimit': budgetLimit,
      'favoriteCategories': favoriteCategories,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      emailNotifications: map['emailNotifications'] ?? true,
      pushNotifications: map['pushNotifications'] ?? true,
      smsNotifications: map['smsNotifications'] ?? false,
      language: map['language'] ?? 'en',
      theme: map['theme'] ?? 'light',
      lowBalanceAlert: map['lowBalanceAlert'] ?? true,
      budgetLimit: (map['budgetLimit'] ?? 1000.0).toDouble(),
      favoriteCategories: List<String>.from(map['favoriteCategories'] ?? []),
    );
  }

  UserPreferences copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    String? language,
    String? theme,
    bool? lowBalanceAlert,
    double? budgetLimit,
    List<String>? favoriteCategories,
  }) {
    return UserPreferences(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      lowBalanceAlert: lowBalanceAlert ?? this.lowBalanceAlert,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
    );
  }
}