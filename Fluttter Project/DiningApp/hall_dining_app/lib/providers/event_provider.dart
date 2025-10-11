import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';
import '../services/payment_service.dart';

class EventProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Event> _events = [];
  List<Event> _upcomingEvents = [];
  List<EventBooking> _eventBookings = [];
  Event? _selectedEvent;
  bool _isLoading = false;
  String _error = '';

  List<Event> get events => _events;
  List<Event> get upcomingEvents => _upcomingEvents;
  List<EventBooking> get eventBookings => _eventBookings;
  Event? get selectedEvent => _selectedEvent;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Initialize provider
  void initialize() {
    _loadUpcomingEvents();
  }

  // Load upcoming events
  Future<void> _loadUpcomingEvents() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _firestoreService.getUpcomingEventsStream().listen((events) {
        _events = events;
        _upcomingEvents = events.where((event) => event.isUpcoming).toList();
        _isLoading = false;
        notifyListeners();
      }, onError: (error) {
        _error = 'Failed to load events: $error';
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Failed to load events: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Book event
  Future<EventBookingResult> bookEvent({
    required String eventId,
    required String userId,
    required String userName,
    required String userEmail,
    required int numberOfGuests,
    required PaymentMethod paymentMethod,
    String? specialRequirements,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final event = _events.firstWhere((e) => e.id == eventId);
      
      // Check if event can be booked
      if (!event.canBook) {
        _isLoading = false;
        _error = 'Event cannot be booked at this time';
        notifyListeners();
        return EventBookingResult.error(message: _error);
      }

      // Check if there are enough spots
      if (event.availableSpots < numberOfGuests) {
        _isLoading = false;
        _error = 'Not enough spots available';
        notifyListeners();
        return EventBookingResult.error(message: _error);
      }

      double totalAmount = 0.0;
      
      // Process payment if event is not free
      if (event.price != null && event.price! > 0) {
        totalAmount = event.price! * numberOfGuests;
        
        final paymentResult = await PaymentService.processStripePayment(
          amount: totalAmount,
          currency: 'bdt',
          bookingId: 'event_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
        );

        if (!paymentResult.success) {
          _isLoading = false;
          _error = paymentResult.message ?? 'Payment failed';
          notifyListeners();
          return EventBookingResult.error(message: _error);
        }
      }

      // Create event booking
      final booking = EventBooking(
        id: '', // Will be set by Firestore
        eventId: eventId,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        bookingDate: DateTime.now(),
        numberOfGuests: numberOfGuests,
        totalAmount: totalAmount,
        status: EventBookingStatus.confirmed,
        paymentId: totalAmount > 0 ? 'payment_${DateTime.now().millisecondsSinceEpoch}' : null,
        createdAt: DateTime.now(),
        specialRequirements: specialRequirements,
      );

      final bookingId = await _firestoreService.createEventBooking(booking);
      
      _isLoading = false;
      notifyListeners();
      return EventBookingResult.success(bookingId: bookingId);
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to book event: $e';
      notifyListeners();
      return EventBookingResult.error(message: _error);
    }
  }

  // Cancel event booking
  Future<bool> cancelEventBooking(String bookingId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // In a real app, you would update this in Firestore
      final bookingIndex = _eventBookings.indexWhere((b) => b.id == bookingId);
      if (bookingIndex != -1) {
        _eventBookings[bookingIndex] = _eventBookings[bookingIndex].copyWith(
          status: EventBookingStatus.cancelled,
          updatedAt: DateTime.now(),
        );
        
        // Update event attendees count
        final eventId = _eventBookings[bookingIndex].eventId;
        final eventIndex = _events.indexWhere((e) => e.id == eventId);
        if (eventIndex != -1) {
          final numberOfGuests = _eventBookings[bookingIndex].numberOfGuests;
          _events[eventIndex] = _events[eventIndex].copyWith(
            currentAttendees: _events[eventIndex].currentAttendees - numberOfGuests,
          );
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to cancel event booking: $e';
      notifyListeners();
      return false;
    }
  }

  // Set selected event
  void setSelectedEvent(Event event) {
    _selectedEvent = event;
    notifyListeners();
  }

  // Clear selected event
  void clearSelectedEvent() {
    _selectedEvent = null;
    notifyListeners();
  }

  // Get events by type
  List<Event> getEventsByType(EventType type) {
    return _events.where((event) => event.type == type).toList();
  }

  // Get featured events
  List<Event> getFeaturedEvents() {
    return _events.where((event) => event.isFeatured).toList();
  }

  // Search events
  List<Event> searchEvents(String query) {
    return _events.where((event) =>
      event.title.toLowerCase().contains(query.toLowerCase()) ||
      event.description.toLowerCase().contains(query.toLowerCase()) ||
      event.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }

  // Filter events
  List<Event> filterEvents({
    List<EventType>? types,
    bool? isFree,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _events.where((event) {
      // Filter by type
      if (types != null && types.isNotEmpty && !types.contains(event.type)) {
        return false;
      }
      
      // Filter by price
      if (isFree != null) {
        if (isFree && event.price != null && event.price! > 0) {
          return false;
        }
        if (!isFree && (event.price == null || event.price == 0)) {
          return false;
        }
      }
      
      // Filter by date range
      if (startDate != null && event.startDate.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && event.endDate.isAfter(endDate)) {
        return false;
      }
      
      return true;
    }).toList();
  }

  // Check if user has booked an event
  bool hasUserBookedEvent(String eventId, String userId) {
    return _eventBookings.any((booking) =>
      booking.eventId == eventId &&
      booking.userId == userId &&
      (booking.status == EventBookingStatus.confirmed || 
       booking.status == EventBookingStatus.pending)
    );
  }

  // Get event statistics
  Map<String, dynamic> getEventStats() {
    final totalEvents = _events.length;
    final upcomingEvents = _events.where((e) => e.isUpcoming).length;
    final ongoingEvents = _events.where((e) => e.isOngoing).length;
    final pastEvents = _events.where((e) => e.isPast).length;
    
    final totalAttendees = _events.fold(0, (sum, event) => sum + event.currentAttendees);
    final averageAttendance = totalEvents > 0 ? totalAttendees / totalEvents : 0;
    
    final typeDistribution = <String, int>{};
    for (final event in _events) {
      final type = event.displayType;
      typeDistribution[type] = (typeDistribution[type] ?? 0) + 1;
    }
    
    return {
      'totalEvents': totalEvents,
      'upcomingEvents': upcomingEvents,
      'ongoingEvents': ongoingEvents,
      'pastEvents': pastEvents,
      'totalAttendees': totalAttendees,
      'averageAttendance': averageAttendance,
      'typeDistribution': typeDistribution,
    };
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Refresh events
  Future<void> refreshEvents() async {
    _loadUpcomingEvents();
  }
}

class EventBookingResult {
  final bool success;
  final String? bookingId;
  final String? message;

  EventBookingResult({
    required this.success,
    this.bookingId,
    this.message,
  });

  factory EventBookingResult.success({required String bookingId}) {
    return EventBookingResult(success: true, bookingId: bookingId);
  }

  factory EventBookingResult.error({required String message}) {
    return EventBookingResult(success: false, message: message);
  }
}