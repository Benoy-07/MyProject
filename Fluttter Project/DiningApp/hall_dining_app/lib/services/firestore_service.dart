import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_model.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';
import '../models/subscription_model.dart';
import '../models/feedback_model.dart';
import '../models/event_model.dart';
import '../models/notification_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Operations
  Future<void> updateUser(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<AppUser?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Stream<AppUser?> getUserStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            return AppUser.fromMap(snapshot.data() as Map<String, dynamic>);
          }
          return null;
        });
  }

  // Menu Operations
  Stream<List<DailyMenu>> getTodaysMenuStream() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return _firestore
        .collection('menus')
        .where('date', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)
        .where('date', isLessThanOrEqualTo: endOfDay.millisecondsSinceEpoch)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DailyMenu.fromMap(doc.data()))
              .toList();
        });
  }

  Future<List<DailyMenu>> getWeeklyMenu(DateTime startDate) async {
    try {
      final endDate = startDate.add(const Duration(days: 7));
      
      QuerySnapshot snapshot = await _firestore
          .collection('menus')
          .where('date', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .where('date', isLessThan: endDate.millisecondsSinceEpoch)
          .orderBy('date')
          .get();

      return snapshot.docs
          .map((doc) => DailyMenu.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get weekly menu: $e');
    }
  }

  Future<void> addMenu(DailyMenu menu) async {
    try {
      await _firestore.collection('menus').doc(menu.id).set(menu.toMap());
    } catch (e) {
      throw Exception('Failed to add menu: $e');
    }
  }

  Future<void> updateMenu(DailyMenu menu) async {
    try {
      await _firestore.collection('menus').doc(menu.id).update(menu.toMap());
    } catch (e) {
      throw Exception('Failed to update menu: $e');
    }
  }

  Future<void> addMenuItem(MenuItem item) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final docId = todayStart.toIso8601String();
      final docRef = _firestore.collection('menus').doc(docId);

      final doc = await docRef.get();
      Map<String, dynamic> data = doc.exists ? doc.data()! : {
        'id': docId,
        'date': todayStart.millisecondsSinceEpoch,
        'breakfast': [],
        'lunch': [],
        'dinner': [],
        'isSpecialDay': false,
        'createdAt': now.millisecondsSinceEpoch,
      };

      final List<Map<String, dynamic>> categoryItems =
          List<Map<String, dynamic>>.from(data[item.category] ?? []);
      categoryItems.add(item.toMap());

      await docRef.set({
        ...data,
        item.category: categoryItems,
        'updatedAt': now.millisecondsSinceEpoch,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to add menu item: $e');
    }
  }

  Future<void> updateMenuItem(MenuItem item) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final docId = todayStart.toIso8601String();
      final docRef = _firestore.collection('menus').doc(docId);

      final doc = await docRef.get();
      if (!doc.exists) {
        throw Exception('Menu document does not exist for today');
      }

      final data = doc.data()!;
      final List<Map<String, dynamic>> categoryItems =
          List<Map<String, dynamic>>.from(data[item.category] ?? []);

      final index = categoryItems.indexWhere((element) => element['id'] == item.id);
      if (index == -1) {
        throw Exception('Menu item not found');
      }

      categoryItems[index] = item.toMap();

      await docRef.update({
        item.category: categoryItems,
        'updatedAt': now.millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update menu item: $e');
    }
  }

  Future<void> deleteMenuItem(String itemId) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final docId = todayStart.toIso8601String();
      final docRef = _firestore.collection('menus').doc(docId);

      final doc = await docRef.get();
      if (!doc.exists) {
        throw Exception('Menu document does not exist for today');
      }

      final data = doc.data()!;
      final categories = ['breakfast', 'lunch', 'dinner'];

      for (final category in categories) {
        final List<Map<String, dynamic>> categoryItems =
            List<Map<String, dynamic>>.from(data[category] ?? []);
        final index = categoryItems.indexWhere((element) => element['id'] == itemId);
        if (index != -1) {
          categoryItems.removeAt(index);
          await docRef.update({
            category: categoryItems,
            'updatedAt': now.millisecondsSinceEpoch,
          });
          return;
        }
      }
      throw Exception('Menu item not found');
    } catch (e) {
      throw Exception('Failed to delete menu item: $e');
    }
  }

  // Booking Operations
  Future<String> createBooking(Booking booking) async {
    try {
      final docRef = _firestore.collection('bookings').doc();
      booking = booking.copyWith(id: docRef.id);
      await docRef.set(booking.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  Stream<List<Booking>> getUserBookingsStream(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Booking.fromMap(doc.data()))
              .toList();
        });
  }

  Stream<List<Booking>> getUpcomingBookingsStream(String userId) {
    final now = DateTime.now();
    
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('bookingDate', isGreaterThanOrEqualTo: now)
        .where('status', whereIn: ['pending', 'confirmed', 'preparing'])
        .orderBy('bookingDate')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Booking.fromMap(doc.data()))
              .toList();
        });
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  Future<void> cancelBooking(String bookingId, String reason) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancellationDate': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Payment Operations
  Future<String> createPayment(Payment payment) async {
    try {
      final docRef = _firestore.collection('payments').doc();
      payment = payment.copyWith(id: docRef.id);
      await docRef.set(payment.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  Future<void> updatePaymentStatus(String paymentId, PaymentStatus status) async {
    try {
      await _firestore.collection('payments').doc(paymentId).update({
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  Stream<List<Payment>> getUserPaymentsStream(String userId) {
    return _firestore
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Payment.fromMap(doc.data()))
              .toList();
        });
  }

  // Subscription Operations
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('subscription_plans')
          .where('isActive', isEqualTo: true)
          .orderBy('price')
          .get();

      return snapshot.docs
          .map((doc) => SubscriptionPlan.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get subscription plans: $e');
    }
  }

  Future<UserSubscription?> getUserSubscription(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('user_subscriptions')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['active', 'pending'])
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserSubscription.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user subscription: $e');
    }
  }

  Future<String> createSubscription(UserSubscription subscription) async {
    try {
      final docRef = _firestore.collection('user_subscriptions').doc();
      await docRef.set(subscription.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create subscription: $e');
    }
  }

  // Feedback Operations
  Future<String> submitFeedback(Feedback feedback) async {
    try {
      final docRef = _firestore.collection('feedback').doc();
      feedback = feedback.copyWith(id: docRef.id);
      await docRef.set(feedback.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }

  Stream<List<Feedback>> getUserFeedbackStream(String userId) {
    return _firestore
        .collection('feedback')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Feedback.fromMap(doc.data()))
              .toList();
        });
  }

  // Event Operations
  Stream<List<Event>> getUpcomingEventsStream() {
    final now = DateTime.now();
    
    return _firestore
        .collection('events')
        .where('startDate', isGreaterThanOrEqualTo: now)
        .where('isActive', isEqualTo: true)
        .orderBy('startDate')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Event.fromMap(doc.data()))
              .toList();
        });
  }

  Future<String> createEventBooking(EventBooking booking) async {
    try {
      final docRef = _firestore.collection('event_bookings').doc();
      booking = booking.copyWith(id: docRef.id);
      await docRef.set(booking.toMap());
      
      // Update event attendees count
      await _firestore.collection('events').doc(booking.eventId).update({
        'currentAttendees': FieldValue.increment(booking.numberOfGuests),
      });
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create event booking: $e');
    }
  }

  // Notification Operations
  Stream<List<AppNotification>> getUserNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('targetUsers', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AppNotification.fromMap(doc.data()))
              .toList();
        });
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Admin Operations
  Stream<List<Booking>> getAllBookingsStream() {
    return _firestore
        .collection('bookings')
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Booking.fromMap(doc.data()))
              .toList();
        });
  }

  Stream<List<Feedback>> getAllFeedbackStream() {
    return _firestore
        .collection('feedback')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Feedback.fromMap(doc.data()))
              .toList();
        });
  }

  // Analytics Operations
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get total users
      final usersSnapshot = await _firestore.collection('users').count().get();
      final totalUsers = usersSnapshot.count;

      // Get today's bookings
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final bookingsSnapshot = await _firestore
          .collection('bookings')
          .where('bookingDate', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)
          .where('bookingDate', isLessThanOrEqualTo: endOfDay.millisecondsSinceEpoch)
          .get();

      final todaysBookings = bookingsSnapshot.docs.length;

      // Get total revenue
      final paymentsSnapshot = await _firestore
          .collection('payments')
          .where('status', isEqualTo: 'completed')
          .get();

      double totalRevenue = 0;
      for (var doc in paymentsSnapshot.docs) {
        final payment = Payment.fromMap(doc.data());
        totalRevenue += payment.amount;
      }

      return {
        'totalUsers': totalUsers,
        'todaysBookings': todaysBookings,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      throw Exception('Failed to get dashboard stats: $e');
    }
  }
}