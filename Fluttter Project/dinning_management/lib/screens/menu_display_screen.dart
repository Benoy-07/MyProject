import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/menu_card.dart';
import '../models/menu_item.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class MenuDisplayScreen extends StatefulWidget {
  @override
  _MenuDisplayScreenState createState() => _MenuDisplayScreenState();
}

class _MenuDisplayScreenState extends State<MenuDisplayScreen> {
  final FirestoreService _fs = FirestoreService();
  List<MenuItemModel> cart = [];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
        actions: [
          IconButton(icon: Icon(Icons.history), onPressed: () => Navigator.pushNamed(context, '/history')),
          IconButton(icon: Icon(Icons.account_circle), onPressed: () => Navigator.pushNamed(context, '/profile')),
        ],
      ),
      body: StreamBuilder<List<MenuItemModel>>(
        stream: _fs.streamMenuItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final menu = snapshot.data!;
          return ListView.builder(
            itemCount: menu.length,
            itemBuilder: (ctx, i) {
              final item = menu[i];
              return MenuCard(
                item: item,
                onAdd: () {
                  setState(() => cart.add(item));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} added')));
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: cart.isEmpty ? null : () {
          Navigator.pushNamed(context, '/booking', arguments: cart);
        },
        label: Text('Book / Checkout (${cart.length})'),
        icon: Icon(Icons.shopping_cart),
      ),
    );
  }
}
