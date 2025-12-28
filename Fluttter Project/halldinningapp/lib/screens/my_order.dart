import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_auth_service.dart';

class MyOrderPage extends StatefulWidget {
  const MyOrderPage({super.key});

  @override
  State<MyOrderPage> createState() => _MyOrderPageState();
}

class _MyOrderPageState extends State<MyOrderPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _userEmail = FirebaseAuthService.getUserEmail();
  }

  @override
  Widget build(BuildContext context) {
    // Use authStateChanges stream so UI updates when user logs in/out
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = authSnap.data;
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('My Orders')),
            body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Please login to see your orders'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/firebase-login'),
                  child: const Text('Login'),
                ),
              ]),
            ),
          );
        }

        // Decide query field: prefer email if available, else use uid
        // NOTE: performing a server-side `where` + `orderBy` on different fields often
        // requires a composite index. To avoid forcing the user to create an index,
        // we only filter on the server and perform ordering locally.
        final email = user.email;
        Query orderQuery;
        if (email != null && email.isNotEmpty) {
          orderQuery = _firestore.collection('orders').where('userEmail', isEqualTo: email);
        } else {
          // fallback to uid if orders store uid (field name 'userUid' or 'userId')
          orderQuery = _firestore.collection('orders').where('userUid', isEqualTo: user.uid);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Orders'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.black87,
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: orderQuery.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final docs = snapshot.data?.docs ?? [];
              // Sort results by `orderTime` locally (descending) to avoid composite-index requirement
              try {
                docs.sort((a, b) {
                  final ma = a.data() as Map<String, dynamic>;
                  final mb = b.data() as Map<String, dynamic>;
                  final ta = ma['orderTime'];
                  final tb = mb['orderTime'];
                  Timestamp? tsa = ta is Timestamp ? ta : null;
                  Timestamp? tsb = tb is Timestamp ? tb : null;
                  if (tsa == null && tsb == null) return 0;
                  if (tsa == null) return 1;
                  if (tsb == null) return -1;
                  return tsb.toDate().compareTo(tsa.toDate());
                });
              } catch (_) {
                // If sorting fails, just continue with server order
              }
              if (docs.isEmpty) {
                return Center(child: Text('No orders found', style: TextStyle(color: Colors.grey.shade700)));
              }
                // Group orders by date string (YYYY-MM-DD) and sort descending
                final Map<String, List<QueryDocumentSnapshot>> grouped = {};
                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final dateStr = (data['date'] as String?) ?? 'Unknown Date';
                  grouped.putIfAbsent(dateStr, () => []).add(doc);
                }

                final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: dates.length,
                  itemBuilder: (context, idx) {
                    final date = dates[idx];
                    final items = grouped[date]!;

                    // Format the date for display if possible
                    String prettyDate = date;
                    try {
                      final dt = DateTime.parse(date);
                      prettyDate = DateFormat('MMM dd, yyyy (EEE)').format(dt);
                    } catch (_) {}

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            prettyDate,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...items.map((orderDoc) {
                          final data = orderDoc.data() as Map<String, dynamic>;
                          final status = (data['status'] ?? 'pending').toString();
                          final total = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
                          final itemsList = (data['items'] as List<dynamic>?) ?? [];

                          // derive orderTime string
                          String timeStr = '';
                          try {
                            final ts = data['orderTime'];
                            if (ts is Timestamp) {
                              timeStr = DateFormat('hh:mm a').format(ts.toDate());
                            }
                          } catch (_) {}

                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(backgroundColor: Colors.teal.shade50, child: const Icon(Icons.receipt_long, color: Colors.teal)),
                              title: Text('Order ${orderDoc.id.substring(0, 6)}'),
                              subtitle: Text('${itemsList.length} items • ৳${total.toStringAsFixed(0)}${timeStr.isNotEmpty ? ' • $timeStr' : ''}'),
                              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                _buildStatusChip(status),
                                const SizedBox(width: 6),
                                if (status == 'pending')
                                  IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                                    tooltip: 'Cancel order',
                                    onPressed: () => _confirmCancel(orderDoc.id),
                                  ),
                              ]),
                              onTap: () => _showOrderDetails(orderDoc.id, data),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                );
        },
            ),
          );
        },
      );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label = status[0].toUpperCase() + status.substring(1);
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'prepared':
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'served':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(label: Text(label, style: const TextStyle(color: Colors.white)), backgroundColor: color);
  }

  void _showOrderDetails(String id, Map<String, dynamic> data) {
    final items = (data['items'] as List<dynamic>?) ?? [];
    final total = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order $id', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              ...items.map((it) {
                final map = it as Map<String, dynamic>;
                return ListTile(
                  title: Text(map['itemName'] ?? map['item'] ?? 'Item'),
                  trailing: Text('${map['quantity'] ?? 1} × ৳${((map['price'] ?? 0) as num).toStringAsFixed(0)}'),
                );
              }).toList(),
              const SizedBox(height: 8),
              Text('Total: ৳${total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmCancel(String orderId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this pending order?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Yes')),
        ],
      ),
    );

    if (ok == true) {
      try {
        await _firestore.collection('orders').doc(orderId).update({'status': 'cancelled', 'updatedAt': FieldValue.serverTimestamp()});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order cancelled')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to cancel: $e')));
      }
    }
  }
}
