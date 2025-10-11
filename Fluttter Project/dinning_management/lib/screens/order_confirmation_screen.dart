import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class OrderConfirmationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final tx = args?['tx'] ?? '';
    final amount = args?['amount'] ?? 0.0;
    final orderId = args?['orderId'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text('Order Confirmed')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 16),
            Text('Payment successful', style: TextStyle(fontSize: 20)),
            Text('Transaction: $tx'),
            Text('Order ID: $orderId'),
            Text('Amount: ৳${(amount as double).toStringAsFixed(2)}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Share.share('I just placed an order #$orderId!'),
              child: Text('Share'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/menu', (r) => false),
              child: Text('Back to Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
