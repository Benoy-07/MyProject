import 'package:flutter/foundation.dart';
import '../models/budget_model.dart';
import '../models/booking_model.dart';
import '../models/payment_model.dart';
import '../services/budget_service.dart';

class BudgetProvider with ChangeNotifier {
  Budget? _budget;
  List<SpendingRecord> _spendingRecords = [];
  List<BudgetCategory> _categories = [];
  bool _isLoading = false;
  String _error = '';

  Budget? get budget => _budget;
  List<SpendingRecord> get spendingRecords => _spendingRecords;
  List<BudgetCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String get error => _error;

  double get remainingBudget => _budget?.remainingBudget ?? 0.0;
  double get usagePercentage => _budget?.usagePercentage ?? 0.0;
  bool get isOverBudget => _budget?.isOverBudget ?? false;
  BudgetAlertLevel get alertLevel => _budget?.alertLevel ?? BudgetAlertLevel.normal;

  // Initialize provider
  void initialize(String userId) {
    _loadUserBudget(userId);
    _loadSpendingRecords(userId);
    _initializeCategories();
  }

  // Load user budget
  Future<void> _loadUserBudget(String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // In a real app, you would load this from Firestore
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      
      _budget = Budget(
        userId: userId,
        monthlyLimit: 5000.0,
        currentSpending: 3250.0,
        periodStart: startOfMonth,
        periodEnd: endOfMonth,
        categories: _categories,
        alertLevel: BudgetAlertLevel.warning,
        lastReset: startOfMonth,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load budget: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load spending records
  Future<void> _loadSpendingRecords(String userId) async {
    try {
      // In a real app, you would load this from Firestore
      _spendingRecords = [
        SpendingRecord(
          id: '1',
          userId: userId,
          amount: 150.0,
          category: 'Meals',
          description: 'Lunch booking',
          spentAt: DateTime.now().subtract(const Duration(days: 1)),
          bookingId: 'booking_1',
          type: SpendingType.meal,
        ),
        SpendingRecord(
          id: '2',
          userId: userId,
          amount: 200.0,
          category: 'Meals',
          description: 'Dinner booking',
          spentAt: DateTime.now().subtract(const Duration(days: 2)),
          bookingId: 'booking_2',
          type: SpendingType.meal,
        ),
        SpendingRecord(
          id: '3',
          userId: userId,
          amount: 1200.0,
          category: 'Subscription',
          description: 'Monthly meal plan',
          spentAt: DateTime.now().subtract(const Duration(days: 5)),
          paymentId: 'payment_1',
          type: SpendingType.subscription,
        ),
        SpendingRecord(
          id: '4',
          userId: userId,
          amount: 500.0,
          category: 'Events',
          description: 'Cultural night event',
          spentAt: DateTime.now().subtract(const Duration(days: 7)),
          bookingId: 'event_1',
          type: SpendingType.event,
        ),
        SpendingRecord(
          id: '5',
          userId: userId,
          amount: 1200.0,
          category: 'Subscription',
          description: 'Monthly meal plan renewal',
          spentAt: DateTime.now().subtract(const Duration(days: 35)),
          paymentId: 'payment_2',
          type: SpendingType.subscription,
        ),
      ];
      
      notifyListeners();
    } catch (e) {
      print('Failed to load spending records: $e');
    }
  }

  // Initialize budget categories
  void _initializeCategories() {
    _categories = [
      BudgetCategory(
        name: 'Meals',
        allocatedAmount: 3000.0,
        spentAmount: 1750.0,
        color: '#FF6B35',
      ),
      BudgetCategory(
        name: 'Subscription',
        allocatedAmount: 1500.0,
        spentAmount: 1200.0,
        color: '#4ECDC4',
      ),
      BudgetCategory(
        name: 'Events',
        allocatedAmount: 500.0,
        spentAmount: 300.0,
        color: '#45B7D1',
      ),
    ];
  }

  // Update budget
  Future<bool> updateBudget(double monthlyLimit) async {
    if (_budget == null) return false;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _budget = _budget!.copyWith(
        monthlyLimit: monthlyLimit,
        lastUpdated: DateTime.now(),
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update budget: $e';
      notifyListeners();
      return false;
    }
  }

  // Add spending record
  Future<bool> addSpendingRecord(SpendingRecord record) async {
    try {
      _spendingRecords.insert(0, record);
      
      // Update budget spending
      if (_budget != null) {
        _budget = _budget!.copyWith(
          currentSpending: _budget!.currentSpending + record.amount,
          lastUpdated: DateTime.now(),
          alertLevel: BudgetService.checkBudgetStatus(_budget!),
        );
        
        // Update category spending
        final categoryIndex = _categories.indexWhere((c) => c.name == record.category);
        if (categoryIndex != -1) {
          final category = _categories[categoryIndex];
          _categories[categoryIndex] = category.copyWith(
            spentAmount: category.spentAmount + record.amount,
          );
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add spending record: $e';
      notifyListeners();
      return false;
    }
  }

  // Add spending from booking
  Future<bool> addSpendingFromBooking(Booking booking) async {
    try {
      final record = SpendingRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: booking.userId,
        amount: booking.totalAmount,
        category: 'Meals',
        description: '${booking.mealType} booking',
        spentAt: booking.bookingDate,
        bookingId: booking.id,
        type: SpendingType.meal,
      );
      
      return await addSpendingRecord(record);
    } catch (e) {
      _error = 'Failed to add spending from booking: $e';
      notifyListeners();
      return false;
    }
  }

  // Add spending from payment
  Future<bool> addSpendingFromPayment(Payment payment, SpendingType type) async {
    try {
      String category = '';
      String description = '';
      
      switch (type) {
        case SpendingType.subscription:
          category = 'Subscription';
          description = 'Meal plan subscription';
          break;
        case SpendingType.event:
          category = 'Events';
          description = 'Event booking';
          break;
        case SpendingType.meal:
          category = 'Meals';
          description = 'Meal booking';
          break;
        case SpendingType.other:
          category = 'Other';
          description = 'Other expense';
          break;
      }
      
      final record = SpendingRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: payment.userId,
        amount: payment.amount,
        category: category,
        description: description,
        spentAt: payment.paymentDate,
        paymentId: payment.id,
        type: type,
      );
      
      return await addSpendingRecord(record);
    } catch (e) {
      _error = 'Failed to add spending from payment: $e';
      notifyListeners();
      return false;
    }
  }

  // Get spending by category
  Map<String, double> getSpendingByCategory() {
    return BudgetService.getSpendingBreakdown(_spendingRecords);
  }

  // Get spending by date range
  List<SpendingRecord> getSpendingByDateRange(DateTime startDate, DateTime endDate) {
    return _spendingRecords.where((record) =>
      record.spentAt.isAfter(startDate) &&
      record.spentAt.isBefore(endDate)
    ).toList();
  }

  // Get recent spending (last 7 days)
  List<SpendingRecord> getRecentSpending() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _spendingRecords.where((record) =>
      record.spentAt.isAfter(weekAgo)
    ).toList();
  }

  // Get daily average spending
  double getDailyAverageSpending() {
    if (_budget == null) return 0.0;
    
    return BudgetService.calculateAverageDailySpending(
      _spendingRecords,
      _budget!.periodStart,
    );
  }

  // Get projected monthly spending
  double getProjectedMonthlySpending() {
    if (_budget == null) return 0.0;
    
    return BudgetService.calculateProjectedSpending(_budget!);
  }

  // Get spending trend
  String getSpendingTrend() {
    return BudgetService.getSpendingTrend(_spendingRecords);
  }

  // Get potential savings
  double getPotentialSavings() {
    if (_budget == null) return 0.0;
    
    return BudgetService.calculatePotentialSavings(_budget!);
  }

  // Get budget statistics
  Map<String, dynamic> getBudgetStats() {
    if (_budget == null) return {};
    
    return {
      'monthlyLimit': _budget!.monthlyLimit,
      'currentSpending': _budget!.currentSpending,
      'remainingBudget': _budget!.remainingBudget,
      'usagePercentage': _budget!.usagePercentage,
      'isOverBudget': _budget!.isOverBudget,
      'alertLevel': _budget!.alertLevel.toString().split('.').last,
      'daysRemaining': _budget!.daysRemainingInPeriod,
      'dailyAverage': getDailyAverageSpending(),
      'projectedSpending': getProjectedMonthlySpending(),
      'potentialSavings': getPotentialSavings(),
      'spendingTrend': getSpendingTrend(),
    };
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Refresh budget data
  Future<void> refreshBudget(String userId) async {
    _loadUserBudget(userId);
    _loadSpendingRecords(userId);
  }
}