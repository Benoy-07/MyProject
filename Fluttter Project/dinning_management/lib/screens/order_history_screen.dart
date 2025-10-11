import 'package:flutter/material.dart';
import '../services/local_db_service.dart';
import 'dart:convert';

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    final res = await LocalDbService.getOrders();
    setState(() => orders = res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (_, i) {
          final o = orders[i];
          final date = DateTime.fromMillisecondsSinceEpoch(o['date']);
          final items = jsonDecode(o['items']);
          return ListTile(
            title: Text('Order ${o['id']}'),
            subtitle: Text('${items.length} items — ৳${o['total']}'),
            trailing: Text('${date.day}/${date.month}/${date.year}'),
          );
        },
      ),
    );
  }
}
