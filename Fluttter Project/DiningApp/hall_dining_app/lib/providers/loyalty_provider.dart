import 'package:flutter/foundation.dart';
import '../models/loyalty_model.dart';
import '../models/booking_model.dart';
import '../models/payment_model.dart';
import '../services/loyalty_service.dart';

class LoyaltyProvider with ChangeNotifier {
  UserLoyalty? _userLoyalty;
  LoyaltyProgram? _loyaltyProgram;
  bool _isLoading = false;
  String _error = '';
  int _pointsToRedeem = 0;

  UserLoyalty? get userLoyalty => _userLoyalty;
  LoyaltyProgram? get loyaltyProgram => _loyaltyProgram;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get pointsToRedeem => _pointsToRedeem;

  bool get canRedeemPoints => _userLoyalty?.canRedeem ?? false;
  double get potentialDiscount => _userLoyalty?.potentialDiscount ?? 0.0;

  // Initialize provider
  void initialize() {
    _loadLoyaltyProgram();
  }

  // Load loyalty program
  Future<void> _loadLoyaltyProgram() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // In a real app, you would load this from Firestore
      _loyaltyProgram = LoyaltyProgram(
        id: '1',
        name: 'Hall Dining Rewards',
        description: 'Earn points on every meal and redeem for discounts',
        pointsPerMeal: 10,
        pointsPerTaka: 1,
        discountPerPoint: 0.1,
        minPointsForRedemption: 100,
        maxRedemptionPerOrder: 1000,
        isActive: true,
        createdAt: DateTime.now(),
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load loyalty program: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user loyalty data
  Future<void> loadUserLoyalty(String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // In a real app, you would load this from Firestore
      // For now, we'll create a mock user loyalty
      _userLoyalty = UserLoyalty(
        userId: userId,
        totalPoints: 350,
        availablePoints: 350,
        usedPoints: 150,
        pendingPoints: 0,
        lastUpdated: DateTime.now(),
        tier: LoyaltyTier.bronze,
        transactions: [
          LoyaltyTransaction(
            id: '1',
            userId: userId,
            type: LoyaltyTransactionType.earn,
            points: 50,
            balanceBefore: 0,
            balanceAfter: 50,
            description: 'Points from meal booking',
            transactionDate: DateTime.now().subtract(const Duration(days: 30)),
            status: LoyaltyTransactionStatus.completed,
          ),
          LoyaltyTransaction(
            id: '2',
            userId: userId,
            type: LoyaltyTransactionType.earn,
            points: 100,
            balanceBefore: 50,
            balanceAfter: 150,
            description: 'Points from meal booking',
            transactionDate: DateTime.now().subtract(const Duration(days: 15)),
            status: LoyaltyTransactionStatus.completed,
          ),
          LoyaltyTransaction(
            id: '3',
            userId: userId,
            type: LoyaltyTransactionType.earn,
            points: 200,
            balanceBefore: 150,
            balanceAfter: 350,
            description: 'Points from meal booking',
            transactionDate: DateTime.now().subtract(const Duration(days: 7)),
            status: LoyaltyTransactionStatus.completed,
          ),
        ],
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user loyalty: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate points from booking
  int calculatePointsFromBooking(Booking booking) {
    if (_loyaltyProgram == null) return 0;
    
    return LoyaltyService.calculatePointsFromBooking(booking, _loyaltyProgram!);
  }

  // Add points from booking
  Future<bool> addPointsFromBooking(Booking booking) async {
    if (_userLoyalty == null || _loyaltyProgram == null) return false;

    try {
      final pointsEarned = calculatePointsFromBooking(booking);
      
      final transaction = LoyaltyTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _userLoyalty!.userId,
        type: LoyaltyTransactionType.earn,
        points: pointsEarned,
        balanceBefore: _userLoyalty!.availablePoints,
        balanceAfter: _userLoyalty!.availablePoints + pointsEarned,
        description: 'Points from ${booking.mealType} booking',
        referenceId: booking.id,
        transactionDate: DateTime.now(),
        status: LoyaltyTransactionStatus.completed,
      );

      // Update user loyalty
      _userLoyalty = _userLoyalty!.copyWith(
        totalPoints: _userLoyalty!.totalPoints + pointsEarned,
        availablePoints: _userLoyalty!.availablePoints + pointsEarned,
        lastUpdated: DateTime.now(),
        transactions: [..._userLoyalty!.transactions, transaction],
        tier: LoyaltyService.calculateLoyaltyTier(_userLoyalty!.totalPoints + pointsEarned),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add points: $e';
      notifyListeners();
      return false;
    }
  }

  // Redeem points
  Future<bool> redeemPoints(int points, String bookingId) async {
    if (_userLoyalty == null || _loyaltyProgram == null) return false;

    if (!LoyaltyService.canRedeemPoints(points, _loyaltyProgram!)) {
      _error = 'Not enough points to redeem';
      notifyListeners();
      return false;
    }

    if (points > _userLoyalty!.availablePoints) {
      _error = 'Insufficient points';
      notifyListeners();
      return false;
    }

    try {
      final transaction = LoyaltyTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _userLoyalty!.userId,
        type: LoyaltyTransactionType.redeem,
        points: points,
        balanceBefore: _userLoyalty!.availablePoints,
        balanceAfter: _userLoyalty!.availablePoints - points,
        description: 'Points redeemed for booking discount',
        referenceId: bookingId,
        transactionDate: DateTime.now(),
        status: LoyaltyTransactionStatus.completed,
      );

      // Update user loyalty
      _userLoyalty = _userLoyalty!.copyWith(
        availablePoints: _userLoyalty!.availablePoints - points,
        usedPoints: _userLoyalty!.usedPoints + points,
        lastUpdated: DateTime.now(),
        transactions: [..._userLoyalty!.transactions, transaction],
      );
      
      _pointsToRedeem = 0;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to redeem points: $e';
      notifyListeners();
      return false;
    }
  }

  // Calculate discount from points
  double calculateDiscount(int points) {
    if (_loyaltyProgram == null) return 0.0;
    
    return LoyaltyService.calculateDiscountFromPoints(points, _loyaltyProgram!);
  }

  // Set points to redeem
  void setPointsToRedeem(int points) {
    if (_userLoyalty == null) return;
    
    _pointsToRedeem = points.clamp(0, _userLoyalty!.availablePoints);
    notifyListeners();
  }

  // Get maximum redeemable points for an order
  int getMaxRedeemablePoints(double orderAmount) {
    if (_loyaltyProgram == null) return 0;
    
    final maxByProgram = _loyaltyProgram!.maxRedemptionPerOrder;
    final maxByUser = _userLoyalty?.availablePoints ?? 0;
    final maxByOrder = (orderAmount / _loyaltyProgram!.discountPerPoint).floor();
    
    return [maxByProgram, maxByUser, maxByOrder].reduce((a, b) => a < b ? a : b);
  }

  // Get points needed for next tier
  int getPointsToNextTier() {
    if (_userLoyalty == null) return 0;
    
    return LoyaltyService.pointsToNextTier(
      _userLoyalty!.totalPoints,
      _userLoyalty!.tier,
    );
  }

  // Get tier progress percentage
  double getTierProgressPercentage() {
    if (_userLoyalty == null) return 0.0;
    
    final currentPoints = _userLoyalty!.totalPoints;
    int nextTierThreshold;
    
    switch (_userLoyalty!.tier) {
      case LoyaltyTier.bronze:
        nextTierThreshold = 500;
        break;
      case LoyaltyTier.silver:
        nextTierThreshold = 2000;
        break;
      case LoyaltyTier.gold:
        nextTierThreshold = 5000;
        break;
      case LoyaltyTier.platinum:
        return 100.0; // Already at highest tier
    }
    
    return (currentPoints / nextTierThreshold) * 100;
  }

  // Get loyalty statistics
  Map<String, dynamic> getLoyaltyStats() {
    if (_userLoyalty == null) return {};
    
    return {
      'totalPoints': _userLoyalty!.totalPoints,
      'availablePoints': _userLoyalty!.availablePoints,
      'usedPoints': _userLoyalty!.usedPoints,
      'tier': _userLoyalty!.tierName,
      'pointsToNextTier': getPointsToNextTier(),
      'tierProgress': getTierProgressPercentage(),
      'potentialDiscount': _userLoyalty!.potentialDiscount,
    };
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Clear points to redeem
  void clearPointsToRedeem() {
    _pointsToRedeem = 0;
    notifyListeners();
  }

  // Refresh loyalty data
  Future<void> refreshLoyalty(String userId) async {
    _loadLoyaltyProgram();
    loadUserLoyalty(userId);
  }

  // Get tier benefits
  String getTierBenefits(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return '5% discount on meals, priority seating';
      case LoyaltyTier.silver:
        return '10% discount on meals, priority seating, exclusive events';
      case LoyaltyTier.gold:
        return '15% discount on meals, priority seating, exclusive events, free dessert monthly';
      case LoyaltyTier.platinum:
        return '20% discount on meals, VIP seating, exclusive events, free dessert weekly';
    }
  }
}