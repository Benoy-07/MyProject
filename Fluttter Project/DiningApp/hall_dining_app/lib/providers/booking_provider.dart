import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../models/menu_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class BookingProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Booking> _bookings = [];
  List<Booking> _upcomingBookings = [];
  List<Booking> _bookingHistory = [];
  Booking? _selectedBooking;
  bool _isLoading = false;
  String _error = '';
  DateTime _selectedBookingDate = DateTime.now();
  String _selectedMealType = 'lunch';

  List<Booking> get bookings => _bookings;
  List<Booking> get upcomingBookings => _upcomingBookings;
  List<Booking> get bookingHistory => _bookingHistory;
  Booking? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get selectedBookingDate => _selectedBookingDate;
  String get selectedMealType => _selectedMealType;

  // Initialize provider
  void initialize(String userId) {
    _loadUserBookings(userId);
    _loadUpcomingBookings(userId);
  }

  // Load user bookings
  Future<void> _loadUserBookings(String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _firestoreService.getUserBookingsStream(userId).listen((bookings) {
        _bookings = bookings;
        _bookingHistory = bookings.where((booking) => 
          booking.status == BookingStatus.completed || 
          booking.status == BookingStatus.cancelled
        ).toList();
        _isLoading = false;
        notifyListeners();
      }, onError: (error) {
        _error = 'Failed to load bookings: $error';
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Failed to load bookings: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load upcoming bookings
  Future<void> _loadUpcomingBookings(String userId) async {
    try {
      _firestoreService.getUpcomingBookingsStream(userId).listen((bookings) {
        _upcomingBookings = bookings;
        notifyListeners();
      });
    } catch (e) {
      print('Failed to load upcoming bookings: $e');
    }
  }

  // Create new booking
  Future<BookingResult> createBooking({
    required String userId,
    required String userEmail,
    required String userName,
    required DateTime bookingDate,
    required String mealType,
    required List<MenuItem> items,
    required double subtotal,
    required double tax,
    required double totalAmount,
    Map<String, dynamic>? specialInstructions,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final bookingItems = items.map((item) => BookingItem(
        menuItemId: item.id,
        menuItemName: item.name,
        unitPrice: item.price,
        quantity: 1,
        imageUrl: item.imageUrl,
      )).toList();

      final booking = Booking(
        id: '', // Will be set by Firestore
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        bookingDate: bookingDate,
        mealType: mealType,
        items: bookingItems,
        totalQuantity: items.length,
        subtotal: subtotal,
        tax: tax,
        totalAmount: totalAmount,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        specialInstructions: specialInstructions,
      );

      final bookingId = await _firestoreService.createBooking(booking);
      
      _isLoading = false;
      
      // Send notification
      await NotificationService.sendBookingConfirmation(
        userId: userId,
        bookingId: bookingId,
        mealType: mealType,
        bookingDate: bookingDate,
      );

      notifyListeners();
      return BookingResult.success(bookingId: bookingId);
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to create booking: $e';
      notifyListeners();
      return BookingResult.error(message: _error);
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId, String reason) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.cancelBooking(bookingId, reason);
      
      // Update local state
      final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
      if (bookingIndex != -1) {
        _bookings[bookingIndex] = _bookings[bookingIndex].copyWith(
          status: BookingStatus.cancelled,
          cancellationReason: reason,
          cancellationDate: DateTime.now(),
        );
        
        _upcomingBookings.removeWhere((b) => b.id == bookingId);
        _bookingHistory = _bookings.where((booking) => 
          booking.status == BookingStatus.completed || 
          booking.status == BookingStatus.cancelled
        ).toList();
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to cancel booking: $e';
      notifyListeners();
      return false;
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      await _firestoreService.updateBookingStatus(bookingId, status);
      
      // Update local state
      final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
      if (bookingIndex != -1) {
        _bookings[bookingIndex] = _bookings[bookingIndex].copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        
        if (status == BookingStatus.completed) {
          _upcomingBookings.removeWhere((b) => b.id == bookingId);
          _bookingHistory = _bookings.where((booking) => 
            booking.status == BookingStatus.completed || 
            booking.status == BookingStatus.cancelled
          ).toList();
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update booking status: $e';
      notifyListeners();
      return false;
    }
  }

  // Set selected booking
  void setSelectedBooking(Booking booking) {
    _selectedBooking = booking;
    notifyListeners();
  }

  // Clear selected booking
  void clearSelectedBooking() {
    _selectedBooking = null;
    notifyListeners();
  }

  // Set selected booking date
  void setSelectedBookingDate(DateTime date) {
    _selectedBookingDate = date;
    notifyListeners();
  }

  // Set selected meal type
  void setSelectedMealType(String mealType) {
    _selectedMealType = mealType;
    notifyListeners();
  }

  // Get bookings by date range
  List<Booking> getBookingsByDateRange(DateTime startDate, DateTime endDate) {
    return _bookings.where((booking) =>
      booking.bookingDate.isAfter(startDate) &&
      booking.bookingDate.isBefore(endDate)
    ).toList();
  }

  // Get bookings by status
  List<Booking> getBookingsByStatus(BookingStatus status) {
    return _bookings.where((booking) => booking.status == status).toList();
  }

  // Get today's bookings
  List<Booking> getTodaysBookings() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return _bookings.where((booking) =>
      booking.bookingDate.isAfter(todayStart) &&
      booking.bookingDate.isBefore(todayEnd)
    ).toList();
  }

  // Check if user has booking for specific date and meal type
  bool hasBookingForMeal(DateTime date, String mealType) {
    return _bookings.any((booking) =>
      booking.bookingDate.year == date.year &&
      booking.bookingDate.month == date.month &&
      booking.bookingDate.day == date.day &&
      booking.mealType == mealType &&
      (booking.status == BookingStatus.pending ||
       booking.status == BookingStatus.confirmed ||
       booking.status == BookingStatus.preparing)
    );
  }

  // Get booking statistics
  Map<String, dynamic> getBookingStats() {
    final totalBookings = _bookings.length;
    final completedBookings = _bookings.where((b) => b.status == BookingStatus.completed).length;
    final cancelledBookings = _bookings.where((b) => b.status == BookingStatus.cancelled).length;
    final pendingBookings = _bookings.where((b) => b.status == BookingStatus.pending).length;
    
    final totalSpent = _bookings
        .where((b) => b.status == BookingStatus.completed)
        .fold(0.0, (sum, booking) => sum + booking.totalAmount);
    
    return {
      'totalBookings': totalBookings,
      'completedBookings': completedBookings,
      'cancelledBookings': cancelledBookings,
      'pendingBookings': pendingBookings,
      'totalSpent': totalSpent,
      'averageOrderValue': completedBookings > 0 ? totalSpent / completedBookings : 0,
    };
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Refresh bookings
  Future<void> refreshBookings(String userId) async {
    _loadUserBookings(userId);
    _loadUpcomingBookings(userId);
  }
}

class BookingResult {
  final bool success;
  final String? bookingId;
  final String? message;

  BookingResult({
    required this.success,
    this.bookingId,
    this.message,
  });

  factory BookingResult.success({required String bookingId}) {
    return BookingResult(success: true, bookingId: bookingId);
  }

  factory BookingResult.error({required String message}) {
    return BookingResult(success: false, message: message);
  }
}