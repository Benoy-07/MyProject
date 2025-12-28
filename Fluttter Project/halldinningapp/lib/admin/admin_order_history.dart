// admin_order_history.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminOrderHistory extends StatefulWidget {
  const AdminOrderHistory({super.key});

  @override
  State<AdminOrderHistory> createState() => _AdminOrderHistoryState();
}

class _AdminOrderHistoryState extends State<AdminOrderHistory> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedFilter = 'all'; // all, pending, confirmed, prepared, served, cancelled
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, String>> _statusFilters = [
    {'value': 'all', 'label': 'All Orders'},
    {'value': 'pending', 'label': 'Pending'},
    {'value': 'confirmed', 'label': 'Confirmed'},
    {'value': 'prepared', 'label': 'Prepared'},
    {'value': 'served', 'label': 'Served'},
    {'value': 'cancelled', 'label': 'Cancelled'},
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'prepared':
        return Colors.purple;
      case 'served':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'prepared':
        return 'Prepared';
      case 'served':
        return 'Served';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Order ID', order['id'] ?? 'N/A'),
              _buildDetailRow('Customer', order['userName'] ?? 'Unknown'),
              _buildDetailRow('Email', order['userEmail'] ?? 'N/A'),
              _buildDetailRow('Hall', order['userHall'] ?? 'N/A'),
              _buildDetailRow('Meal Type', order['mealType'] ?? 'N/A'),
              _buildDetailRow('Date', order['date'] ?? 'N/A'),
              _buildDetailRow('Order Time', _formatTimestamp(order['orderTime'])),
              _buildDetailRow('Status', _getStatusLabel(order['status'] ?? 'pending')),
              _buildDetailRow('Payment Status', order['paymentStatus'] ?? 'pending'),
              _buildDetailRow('Total Amount', '৳${(order['totalAmount'] ?? 0).toStringAsFixed(0)}'),
              
              const SizedBox(height: 16),
              const Text(
                'Order Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._buildOrderItems(order['items']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  List<Widget> _buildOrderItems(dynamic items) {
    if (items == null || items is! List) {
      return [const Text('No items found')];
    }

    return items.map<Widget>((item) {
      final itemMap = item is Map ? Map<String, dynamic>.from(item) : {};
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                itemMap['itemName'] ?? 'Unknown Item',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Text(
              'Qty: ${itemMap['quantity'] ?? 1}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(width: 8),
            Text(
              '৳${(itemMap['price'] ?? 0).toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      return DateFormat('MMM dd, yyyy - HH:mm').format(timestamp.toDate());
    }
    return timestamp.toString();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filters and Date Selection
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Date Selection
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.deepOrange),
                      const SizedBox(width: 8),
                      const Text('Select Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton(
                        onPressed: _selectDate,
                        child: Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Status Filter
                  Row(
                    children: [
                      const Icon(Icons.filter_list, color: Colors.deepOrange),
                      const SizedBox(width: 8),
                      const Text('Filter by:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _selectedFilter,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFilter = newValue!;
                          });
                        },
                        items: _statusFilters.map((Map<String, String> filter) {
                          return DropdownMenuItem<String>(
                            value: filter['value'],
                            child: Text(filter['label']!),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildOrderStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final orderDocs = snapshot.data?.docs ?? [];

                // Client-side filtering for 'all' status
                final filteredDocs = _selectedFilter == 'all' 
                  ? orderDocs 
                  : orderDocs.where((doc) {
                      final order = doc.data() as Map<String, dynamic>;
                      return order['status'] == _selectedFilter;
                    }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No orders found'),
                        Text('for selected date and filter'),
                      ],
                    ),
                  );
                }

                // Sort by orderTime descending on client side
                filteredDocs.sort((a, b) {
                  final Timestamp? timeA = (a.data() as Map<String, dynamic>)['orderTime'];
                  final Timestamp? timeB = (b.data() as Map<String, dynamic>)['orderTime'];
                  
                  if (timeA == null || timeB == null) return 0;
                  return timeB.compareTo(timeA);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final order = doc.data() as Map<String, dynamic>;
                    final orderId = doc.id;
                    
                    final String userName = order['userName'] ?? 'Unknown Customer';
                    final String userEmail = order['userEmail'] ?? 'No email';
                    final String mealType = order['mealType'] ?? 'Unknown';
                    final String status = order['status'] ?? 'pending';
                    final String paymentStatus = order['paymentStatus'] ?? 'pending';
                    final double totalAmount = (order['totalAmount'] ?? 0).toDouble();
                    final Timestamp? orderTime = order['orderTime'];
                    final List<dynamic> items = order['items'] ?? [];

                    // Derive a display name for the first ordered item (fallbacks applied)
                    String firstItemName = 'Unknown';
                    if (items.isNotEmpty) {
                      final first = items[0];
                      if (first is Map<String, dynamic>) {
                        firstItemName = (first['itemName'] ?? first['name'] ?? first['item'] ?? '').toString();
                      } else if (first != null) {
                        firstItemName = first.toString();
                      }
                      if (firstItemName.trim().isEmpty) firstItemName = 'Unknown';
                    }

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order Header
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        userEmail,
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    _getStatusLabel(status),
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                  backgroundColor: _getStatusColor(status),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Order Details
                            Row(
                              children: [
                                // Show first ordered item's name instead of meal type (helps admin see which item was ordered)
                                Chip(
                                  label: Text(
                                    firstItemName,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: Colors.blue.shade100,
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(
                                    '${items.length} items',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: Colors.green.shade100,
                                ),
                                const Spacer(),
                                Text(
                                  '৳${totalAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Order Time and Actions
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  orderTime != null 
                                      ? DateFormat('MMM dd, HH:mm').format(orderTime.toDate())
                                      : 'N/A',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                const Spacer(),
                                
                                // Action Buttons
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility, size: 20),
                                      onPressed: () => _showOrderDetails({
                                        ...order,
                                        'id': orderId,
                                      }),
                                      tooltip: 'View Details',
                                    ),
                                    if (status == 'pending' || status == 'confirmed') ...[
                                      IconButton(
                                        icon: const Icon(Icons.check_circle, size: 20, color: Colors.green),
                                        onPressed: () => _updateOrderStatus(orderId, 'prepared'),
                                        tooltip: 'Mark as Prepared',
                                      ),
                                    ],
                                    if (status == 'prepared') ...[
                                      IconButton(
                                        icon: const Icon(Icons.done_all, size: 20, color: Colors.green),
                                        onPressed: () => _updateOrderStatus(orderId, 'served'),
                                        tooltip: 'Mark as Served',
                                      ),
                                    ],
                                    if (status == 'pending') ...[
                                      IconButton(
                                        icon: const Icon(Icons.cancel, size: 20, color: Colors.red),
                                        onPressed: () => _updateOrderStatus(orderId, 'cancelled'),
                                        tooltip: 'Cancel Order',
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _buildOrderStream() {
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    // Simplified query - only filter by date, do client-side filtering for status
    return _firestore
        .collection('orders')
        .where('date', isEqualTo: dateString)
        .snapshots();
  }
}