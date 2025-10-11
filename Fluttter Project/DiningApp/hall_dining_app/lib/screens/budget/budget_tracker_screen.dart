import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hall_dining_app/models/booking_model.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/booking_provider.dart';
import '../../core/widgets/custom_button.dart';

class BudgetTrackerScreen extends StatefulWidget {
  const BudgetTrackerScreen({super.key});

  @override
  State<BudgetTrackerScreen> createState() => _BudgetTrackerScreenState();
}

class _BudgetTrackerScreenState extends State<BudgetTrackerScreen> {
  double _monthlyBudget = 5000.0;
  bool _isEditingBudget = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isNotEmpty) {
        Provider.of<BookingProvider>(context, listen: false).loadUserBookings(userId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to view bookings')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final monthlySpending = _calculateMonthlySpending(bookingProvider.bookings);
    final remainingBudget = _monthlyBudget - monthlySpending;
    final percentageUsed = (monthlySpending / _monthlyBudget * 100).clamp(0.0, 100.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              setState(() => _isEditingBudget = true);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Budget Overview Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Monthly Budget',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '৳$_monthlyBudget',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Budget Progress
                    LinearProgressIndicator(
                      value: percentageUsed / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentageUsed > 80 ? Colors.red : 
                        percentageUsed > 60 ? Colors.orange : Colors.green,
                      ),
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${percentageUsed.toStringAsFixed(1)}% used',
                          style: TextStyle(
                            color: percentageUsed > 80 ? Colors.red : 
                                  percentageUsed > 60 ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '৳${monthlySpending.toStringAsFixed(2)} / ৳$_monthlyBudget',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Budget Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Remaining',
                          '৳${remainingBudget.toStringAsFixed(2)}',
                          remainingBudget > 0 ? Colors.green : Colors.red,
                        ),
                        _buildStatItem(
                          'Spent',
                          '৳${monthlySpending.toStringAsFixed(2)}',
                          Colors.orange,
                        ),
                        _buildStatItem(
                          'Daily Avg',
                          '৳${(monthlySpending / DateTime.now().day).toStringAsFixed(2)}',
                          Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Spending Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending Trend',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _buildSpendingChart(bookingProvider.bookings),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Meal Type Breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending by Meal Type',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildMealTypeBreakdown(bookingProvider.bookings),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Recent Transactions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            // View all transactions
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildRecentTransactions(bookingProvider.bookings),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Budget Edit Bottom Sheet
      floatingActionButton: _isEditingBudget ? null : FloatingActionButton(
        onPressed: () {
          setState(() => _isEditingBudget = true);
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSpendingChart(List<Booking> bookings) {
    final dailySpending = _calculateDailySpending(bookings);
    
    if (dailySpending.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text('No spending data available'),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: dailySpending.asMap().entries.map((entry) {
          final index = entry.key;
          final spending = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: spending.amount,
                color: Colors.blue,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: _getLeftTitles,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => _getBottomTitles(value, meta, dailySpending),
            ),
          ),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    return Text(
      value.toInt().toString(),
      style: const TextStyle(fontSize: 12),
    );
  }

  Widget _getBottomTitles(double value, TitleMeta meta, List<DailySpending> dailySpending) {
    if (value.toInt() < dailySpending.length) {
      return Text(
        dailySpending[value.toInt()].day,
        style: const TextStyle(fontSize: 10),
      );
    }
    return const Text('');
  }

  Widget _buildMealTypeBreakdown(List<Booking> bookings) {
    final breakdown = _calculateMealTypeBreakdown(bookings);
    
    if (breakdown.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Column(
      children: breakdown.entries.map((entry) {
        final percentage = (entry.value / _calculateMonthlySpending(bookings) * 100);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  entry.key.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 5,
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getMealTypeColor(entry.key),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentTransactions(List<Booking> bookings) {
    final recentBookings = bookings.take(5).toList();
    
    if (recentBookings.isEmpty) {
      return const Center(
        child: Column(
          children: [
            Icon(Icons.receipt, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text('No transactions yet'),
          ],
        ),
      );
    }

    return Column(
      children: recentBookings.map((booking) => ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getMealTypeColor(booking.mealType).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getMealIcon(booking.mealType),
            color: _getMealTypeColor(booking.mealType),
          ),
        ),
        title: Text('${booking.mealType.toUpperCase()} • ${_formatDate(booking.bookingDate)}'),
        subtitle: Text('${booking.items.length} items'),
        trailing: Text(
          '৳${booking.totalAmount}',
          style: TextStyle(
            color: booking.status == 'cancelled' ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      )).toList(),
    );
  }

  double _calculateMonthlySpending(List<Booking> bookings) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    
    return bookings
        .where((booking) => 
            booking.bookingDate.isAfter(firstDayOfMonth) && 
            booking.status != 'cancelled')
        .fold(0.0, (sum, booking) => sum + booking.totalAmount);
  }

  List<DailySpending> _calculateDailySpending(List<Booking> bookings) {
    final Map<String, double> dailyMap = {};
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = '${date.day}/${date.month}';
      dailyMap[key] = 0.0;
    }
    
    for (final booking in bookings) {
      if (booking.status != 'cancelled') {
        final key = '${booking.bookingDate.day}/${booking.bookingDate.month}';
        dailyMap[key] = (dailyMap[key] ?? 0.0) + booking.totalAmount;
      }
    }
    
    return dailyMap.entries
        .map((entry) => DailySpending(entry.key, entry.value))
        .toList();
  }

  Map<String, double> _calculateMealTypeBreakdown(List<Booking> bookings) {
    final Map<String, double> breakdown = {
      'breakfast': 0.0,
      'lunch': 0.0,
      'dinner': 0.0,
    };
    
    for (final booking in bookings) {
      if (booking.status != 'cancelled') {
        breakdown[booking.mealType] = 
            (breakdown[booking.mealType] ?? 0.0) + booking.totalAmount;
      }
    }
    
    return breakdown..removeWhere((key, value) => value == 0.0);
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType) {
      case 'breakfast': return Colors.orange;
      case 'lunch': return Colors.green;
      case 'dinner': return Colors.purple;
      default: return Colors.blue;
    }
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'breakfast': return Icons.breakfast_dining;
      case 'lunch': return Icons.lunch_dining;
      case 'dinner': return Icons.dinner_dining;
      default: return Icons.restaurant;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

class DailySpending {
  final String day;
  final double amount;

  DailySpending(this.day, this.amount);
}