import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService2>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
          tooltip: 'Back to home',
        ),
        title: const Text('Cart'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: cart.items.isEmpty
                  ? Center(child: Text('Your cart is empty', style: TextStyle(color: Colors.grey.shade700)))
                  : ListView.separated(
                      itemCount: cart.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final it = cart.items[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(backgroundColor: Colors.deepPurple.shade100, child: const Icon(Icons.fastfood, color: Colors.deepPurple)),
                            title: Text(it.name),
                            subtitle: Text('${it.quantity} × ৳${it.price.toStringAsFixed(0)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => context.read<CartService2>().changeQuantity(it, it.quantity - 1),
                                ),
                                Text('${it.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => context.read<CartService2>().changeQuantity(it, it.quantity + 1),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('৳${cart.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: cart.items.isEmpty ? null : () => context.read<CartService2>().clear(),
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: cart.items.isEmpty
                        ? null
                        : () async {
                            Navigator.pushNamed(context, '/payment');
                          },
                    child: const Text('Checkout'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
