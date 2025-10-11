import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/qr_service.dart';

class QRDisplayScreen extends StatelessWidget {
  final String bookingId;
  final String userId;
  final DateTime bookingDate;
  final String mealType;

  const QRDisplayScreen({
    Key? key,
    required this.bookingId,
    required this.userId,
    required this.bookingDate,
    required this.mealType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final qrData = QRService.generateBookingQRData(
      bookingId: bookingId,
      userId: userId,
      bookingDate: bookingDate,
      mealType: mealType,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking QR Code'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Meal: ${mealType.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${_formatDate(bookingDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Booking ID: ${bookingId.substring(0, 8)}...',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Show this QR code at the dining counter',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}