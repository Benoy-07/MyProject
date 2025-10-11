import '../models/budget_model.dart';
import '../models/booking_model.dart';
import '../models/payment_model.dart';

class BudgetService {
  // Calculate daily spending limit
  static double calculateDailySpendingLimit(Budget budget) {
    final daysInPeriod = budget.periodEnd.difference(budget.periodStart).inDays;
    return budget.monthlyLimit / daysInPeriod;
  }

  // Calculate projected monthly spending
  static double calculateProjectedSpending(Budget budget) {
    final daysPassed = DateTime.now().difference(budget.periodStart).inDays;
    final daysInPeriod = budget.periodEnd.difference(budget.periodStart).inDays;
    
    if (daysPassed <= 0) return 0;
    
    return (budget.currentSpending / daysPassed) * daysInPeriod;
  }

  // Check if spending is within budget
  static BudgetAlertLevel checkBudgetStatus(Budget budget) {
    final usagePercentage = (budget.currentSpending / budget.monthlyLimit) * 100;
    
    if (usagePercentage >= 90) return BudgetAlertLevel.critical;
    if (usagePercentage >= 75) return BudgetAlertLevel.warning;
    return BudgetAlertLevel.normal;
  }

  // Calculate savings if user stays within budget
  static double calculatePotentialSavings(Budget budget) {
    final projectedSpending = calculateProjectedSpending(budget);
    return projectedSpending > budget.monthlyLimit ? projectedSpending - budget.monthlyLimit : 0;
  }

  // Get spending breakdown by category
  static Map<String, double> getSpendingBreakdown(List<SpendingRecord> records) {
    final breakdown = <String, double>{};
    
    for (final record in records) {
      breakdown[record.category] = (breakdown[record.category] ?? 0) + record.amount;
    }
    
    return breakdown;
  }

  // Calculate average daily spending
  static double calculateAverageDailySpending(List<SpendingRecord> records, DateTime startDate) {
    final days = DateTime.now().difference(startDate).inDays;
    if (days <= 0) return 0;
    
    final totalSpending = records.fold(0.0, (sum, record) => sum + record.amount);
    return totalSpending / days;
  }

  // Get spending trend (increasing, decreasing, stable)
  static String getSpendingTrend(List<SpendingRecord> records) {
    if (records.length < 2) return 'stable';
    
    final recentRecords = records.take(7).toList(); // Last 7 days
    if (recentRecords.length < 2) return 'stable';
    
    double total = 0;
    for (int i = 1; i < recentRecords.length; i++) {
      total += recentRecords[i].amount - recentRecords[i-1].amount;
    }
    
    final averageChange = total / (recentRecords.length - 1);
    
    if (averageChange > 10) return 'increasing';
    if (averageChange < -10) return 'decreasing';
    return 'stable';
  }
}