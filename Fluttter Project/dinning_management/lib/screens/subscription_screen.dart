import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool available = false;

  @override
  void initState() {
    super.initState();
    initIAP();
  }

  Future<void> initIAP() async {
    available = await _iap.isAvailable();
    setState(() {});
    // query product details and handle purchases according to docs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: Center(
        child: Column(
          children: [
            Text(available ? 'Store available' : 'Store unavailable'),
            ElevatedButton(onPressed: () {
              // TODO: implement purchase flow using InAppPurchase
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Subscription flow placeholder')));
            }, child: const Text('Subscribe for Premium')),
          ],
        ),
      ),
    );
  }
}
