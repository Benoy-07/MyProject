import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import 'package:uuid/uuid.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _ps = PaymentService();
  bool loading = false;
  String method = 'card';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final total = args?['total'] ?? 0.0;
    return Scaffold(
      appBar: AppBar(title: Text('Payment')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Amount to pay: ৳${(total as double).toStringAsFixed(2)}'),
            ListTile(
              title: const Text('Card'),
              leading: Radio(value: 'card', groupValue: method, onChanged: (v) => setState(() => method = v!)),
            ),
            ListTile(
              title: const Text('Mobile Wallet'),
              leading: Radio(value: 'wallet', groupValue: method, onChanged: (v) => setState(() => method = v!)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : () async {
                setState(() => loading = true);
                final res = await _ps.processPayment(amount: total, currency: 'BDT', method: method);
                setState(() => loading = false);
                if (res['status'] == 'success') {
                  Navigator.pushReplacementNamed(context, '/confirm', arguments: {
                    'tx': res['transactionId'],
                    'amount': total,
                    'orderId': Uuid().v4(),
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed')));
                }
              },
              child: loading ? CircularProgressIndicator(color: Colors.white) : Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}
