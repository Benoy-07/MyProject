import 'package:flutter/material.dart';

class BudgetTrackerScreen extends StatefulWidget {
  @override
  _BudgetTrackerScreenState createState() => _BudgetTrackerScreenState();
}

class _BudgetTrackerScreenState extends State<BudgetTrackerScreen> {
  double monthlyBudget = 10000;
  double spent = 0;

  @override
  Widget build(BuildContext context) {
    final remaining = monthlyBudget - spent;
    return Scaffold(
      appBar: AppBar(title: Text('Budget Tracker')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Monthly budget: ৳${monthlyBudget.toStringAsFixed(2)}'),
            Text('Spent: ৳${spent.toStringAsFixed(2)}'),
            Text('Remaining: ৳${remaining.toStringAsFixed(2)}'),
            SizedBox(height: 12),
            ElevatedButton(onPressed: () => setState(() => spent += 150.0), child: Text('Add sample expense ৳150')),
          ],
        ),
      ),
    );
  }
}
