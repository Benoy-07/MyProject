// payment.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart'; // Assuming you have auth service

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService2>();
    final auth = context.read<AuthService>(); // Get auth service for user data
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Order Items
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: (item.imageUrl != null && item.imageUrl!.isNotEmpty && (item.imageUrl!.startsWith('http') || item.imageUrl!.startsWith('https')))
                          ? Image.network(
                              item.imageUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => const SizedBox(
                                width: 40,
                                height: 40,
                                child: Center(child: Icon(Icons.broken_image, size: 20)),
                              ),
                            )
                          : const Icon(Icons.fastfood),
                      title: Text(item.itemName),
                      subtitle: Text('Quantity: ${item.quantity}'),
                      trailing: Text('৳${(item.price * item.quantity).toStringAsFixed(0)}'),
                    ),
                  );
                },
              ),
            ),
            
            // Payment Method
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.credit_card, color: Colors.indigo),
                title: const Text('Card (demo)'),
                subtitle: const Text('Pay securely with card'),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
            const SizedBox(height: 24),
            
            // Total Amount
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    '৳${cart.total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Pay Now Button
            ElevatedButton(
              onPressed: cart.items.isEmpty
                    ? null
                    : () async {
                        try {
                          // Fetch full user data (from Firestore if available)
                          final userData = await auth.getUserDataForOrder();
                          if (userData == null) {
                            throw Exception('User not logged in');
                          }

                          // Show loading
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          // Place order with user data pulled from AuthService
                          await context.read<CartService2>().placeOrder(
                            userName: userData['displayName'] ?? userData['firstName'] ?? 'Customer',
                            userEmail: userData['email'] ?? 'No Email',
                            userHall: userData['hall'] ?? 'Unknown Hall',
                          );

                          // Hide loading
                          Navigator.pop(context);

                          // Show success dialog
                          showDialog<void>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Payment Successful!'),
                              content: const Text('Your order has been placed successfully.'),
                              icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/my-order',
                                      (route) => false,
                                    );
                                  },
                                  child: const Text('View Orders'),
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          // Hide loading (if dialog was shown)
                          try {
                            Navigator.pop(context);
                          } catch (_) {}

                          // Show error dialog
                          showDialog<void>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Payment Failed'),
                              content: Text('Error: $e'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Pay Now',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}