import 'package:flutter/material.dart';
import '../models/menu_item.dart';

class MenuCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback onAdd;
  const MenuCard({required this.item, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Row(
        children: [
          Image.network(item.imageUrl, width: 100, height: 100, fit: BoxFit.cover),
          Expanded(
            child: ListTile(
              title: Text(item.name),
              subtitle: Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('৳${item.price.toStringAsFixed(2)}'),
                  SizedBox(height: 8),
                  ElevatedButton(onPressed: onAdd, child: Text('Add')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
