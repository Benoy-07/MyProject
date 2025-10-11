import 'dart:convert';
import 'dart:ui';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/booking_model.dart';

class QRService {
  // Generate QR data for booking
  static String generateBookingQRData({
    required String bookingId,
    required String userId,
    required DateTime bookingDate,
    required String mealType,
  }) {
    final qrData = {
      'bookingId': bookingId,
      'userId': userId,
      'bookingDate': bookingDate.toIso8601String(),
      'mealType': mealType,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'meal_booking',
    };

    return json.encode(qrData);
  }

  // Generate QR data for event booking
  static String generateEventQRData({
    required String eventBookingId,
    required String userId,
    required String eventId,
    required DateTime eventDate,
  }) {
    final qrData = {
      'eventBookingId': eventBookingId,
      'userId': userId,
      'eventId': eventId,
      'eventDate': eventDate.toIso8601String(),
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'event_booking',
    };

    return json.encode(qrData);
  }

  // Validate QR code data
  static QRValidationResult validateQRData(String qrData) {
    try {
      final data = json.decode(qrData) as Map<String, dynamic>;
      
      // Check if required fields exist based on type
      final type = data['type'];
      
      switch (type) {
        case 'meal_booking':
          if (data.containsKey('bookingId') &&
              data.containsKey('userId') &&
              data.containsKey('bookingDate') &&
              data.containsKey('mealType')) {
            return QRValidationResult.valid(data: data);
          }
          break;
          
        case 'event_booking':
          if (data.containsKey('eventBookingId') &&
              data.containsKey('userId') &&
              data.containsKey('eventId') &&
              data.containsKey('eventDate')) {
            return QRValidationResult.valid(data: data);
          }
          break;
          
        default:
          return QRValidationResult.invalid(reason: 'Unknown QR code type');
      }
      
      return QRValidationResult.invalid(reason: 'Missing required fields');
    } catch (e) {
      return QRValidationResult.invalid(reason: 'Invalid QR code format');
    }
  }

  // Check if QR code is expired
  static bool isQRCodeExpired(Map<String, dynamic> qrData) {
    try {
      final type = qrData['type'];
      DateTime? relevantDate;
      
      switch (type) {
        case 'meal_booking':
          relevantDate = DateTime.parse(qrData['bookingDate']);
          break;
        case 'event_booking':
          relevantDate = DateTime.parse(qrData['eventDate']);
          break;
      }
      
      if (relevantDate != null) {
        final now = DateTime.now();
        // QR code is valid only for the day of the booking/event
        return relevantDate.year != now.year || 
               relevantDate.month != now.month || 
               relevantDate.day != now.day;
      }
      
      return true;
    } catch (e) {
      return true;
    }
  }

  // Check if QR code has already been used
  static Future<bool> isQRCodeAlreadyUsed(Map<String, dynamic> qrData) async {
    try {
      final type = qrData['type'];
      
      switch (type) {
        case 'meal_booking':
          final bookingId = qrData['bookingId'];
          // You would check from your database if this booking has been collected
          // For now, return false as placeholder
          return false;
          
        case 'event_booking':
          final eventBookingId = qrData['eventBookingId'];
          // You would check from your database if this event booking has been checked in
          // For now, return false as placeholder
          return false;
          
        default:
          return true;
      }
    } catch (e) {
      return true;
    }
  }

  // Process QR code scan
  static Future<QRScanResult> processQRScan(String qrData) async {
    final validation = validateQRData(qrData);
    
    if (!validation.isValid) {
      return QRScanResult.error(message: validation.reason!);
    }
    
    final data = validation.data!;
    
    // Check if QR code is expired
    if (isQRCodeExpired(data)) {
      return QRScanResult.error(message: 'QR code has expired');
    }
    
    // Check if QR code has already been used
    if (await isQRCodeAlreadyUsed(data)) {
      return QRScanResult.error(message: 'QR code has already been used');
    }
    
    // Process based on type
    final type = data['type'];
    
    switch (type) {
      case 'meal_booking':
        return QRScanResult.mealBooking(
          bookingId: data['bookingId'],
          userId: data['userId'],
          mealType: data['mealType'],
          bookingDate: DateTime.parse(data['bookingDate']),
        );
        
      case 'event_booking':
        return QRScanResult.eventBooking(
          eventBookingId: data['eventBookingId'],
          userId: data['userId'],
          eventId: data['eventId'],
          eventDate: DateTime.parse(data['eventDate']),
        );
        
      default:
        return QRScanResult.error(message: 'Unknown QR code type');
    }
  }

  // Generate QR image widget
  static QrImageView generateQRImage({
    required String data,
    double size = 200.0,
    Color foregroundColor = const Color(0xFF000000),
    Color backgroundColor = const Color(0xFFFFFFFF),
  }) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      gapless: false,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
    );
  }

  // Generate QR code for display
  static Map<String, dynamic> generateDisplayQRCode(Booking booking) {
    final qrData = generateBookingQRData(
      bookingId: booking.id,
      userId: booking.userId,
      bookingDate: booking.bookingDate,
      mealType: booking.mealType,
    );

    return {
      'data': qrData,
      'bookingId': booking.id,
      'mealType': booking.mealType,
      'bookingDate': booking.bookingDate,
      'totalAmount': booking.totalAmount,
    };
  }
}

class QRValidationResult {
  final bool isValid;
  final Map<String, dynamic>? data;
  final String? reason;

  QRValidationResult({
    required this.isValid,
    this.data,
    this.reason,
  });

  factory QRValidationResult.valid({required Map<String, dynamic> data}) {
    return QRValidationResult(isValid: true, data: data);
  }

  factory QRValidationResult.invalid({required String reason}) {
    return QRValidationResult(isValid: false, reason: reason);
  }
}

class QRScanResult {
  final bool success;
  final String? message;
  final QRScanType? type;
  final Map<String, dynamic>? data;

  QRScanResult({
    required this.success,
    this.message,
    this.type,
    this.data,
  });

  factory QRScanResult.mealBooking({
    required String bookingId,
    required String userId,
    required String mealType,
    required DateTime bookingDate,
  }) {
    return QRScanResult(
      success: true,
      type: QRScanType.mealBooking,
      data: {
        'bookingId': bookingId,
        'userId': userId,
        'mealType': mealType,
        'bookingDate': bookingDate,
      },
    );
  }

  factory QRScanResult.eventBooking({
    required String eventBookingId,
    required String userId,
    required String eventId,
    required DateTime eventDate,
  }) {
    return QRScanResult(
      success: true,
      type: QRScanType.eventBooking,
      data: {
        'eventBookingId': eventBookingId,
        'userId': userId,
        'eventId': eventId,
        'eventDate': eventDate,
      },
    );
  }

  factory QRScanResult.error({required String message}) {
    return QRScanResult(success: false, message: message);
  }
}

enum QRScanType {
  mealBooking,
  eventBooking,
}