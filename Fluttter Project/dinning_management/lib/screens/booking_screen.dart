import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/firestore_service.dart';
import '../services/local_db_service.dart';
import 'dart:convert';
//import 'package:uuid/uuid.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime selected = DateTime.now();
  int guests = 1;
  final FirestoreService _fs = FirestoreService();
  List<MenuItemModel> cart = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is List<MenuItemModel>) {
      cart = args;
    }
  }

  double get total => cart.fold(0.0, (s, e) => s + e.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text('Selected: ${selected.toLocal()}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final dt = await showDatePicker(context: context, initialDate: selected, firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(days: 365)));
                if (dt != null) setState(() => selected = dt);
              },
            ),
            Row(
              children: [
                Text('Guests:'),
                IconButton(onPressed: () => setState(() => guests = (guests - 1).clamp(1, 50)), icon: Icon(Icons.remove)),
                Text('$guests'),
                IconButton(onPressed: () => setState(() => guests = (guests + 1).clamp(1, 50)), icon: Icon(Icons.add)),
              ],
            ),
            SizedBox(height: 16),
            Text('Items (${cart.length})'),
            Expanded(
              child: ListView.builder(
                itemCount: cart.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(cart[i].name),
                  trailing: Text('৳${cart[i].price}'),
                ),
              ),
            ),
            Text('Total: ৳${total.toStringAsFixed(2)}'),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                // create booking in firestore
                final bookingData = {
                  'items': cart.map((e) => e.toMap()).toList(),
                  'total': total,
                  'guests': guests,
                  'date': selected.toIso8601String(),
                  'status': 'pending',
                };
                await _fs.createBooking(bookingData);

                // save to local orders DB as short-term placeholder
                // final id = Uuid().v4();
                final id = DateTime.now().millisecondsSinceEpoch.toString();

                await LocalDbService.insertOrder(id, jsonEncode(bookingData), total);

                Navigator.pushNamed(context, '/payment', arguments: {
                  'id': id,
                  'total': total,
                });
              },
              child: Text('Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
