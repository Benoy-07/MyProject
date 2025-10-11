import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<MenuItemModel>> streamMenuItems() {
    return _db.collection('menu').snapshots().map((snap) =>
      snap.docs.map((d) => MenuItemModel.fromMap(d.data(), d.id)).toList()
    );
  }

  Future<void> createBooking(Map<String, dynamic> booking) {
    return _db.collection('bookings').add(booking);
  }

  Future<void> createOrder(Map<String, dynamic> order) {
    return _db.collection('orders').add(order);
  }
}
