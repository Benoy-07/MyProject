import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final samples = [
      {'title': 'New Menu Added', 'body': 'Check out tomorrow\'s breakfast specials.'},
      {'title': 'Order Update', 'body': 'Your order is being prepared.'},
      {'title': 'Promo', 'body': 'Get 10% off on your next meal.'},
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.cyan.shade50, Colors.indigo.shade50])),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 10,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final data = samples[index % samples.length];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.indigo.shade100, child: const Icon(Icons.notifications, color: Colors.indigo)),
                title: Text(data['title']!),
                subtitle: Text(data['body']!),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(data['title']!),
                      content: Text(data['body']!),
                      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
