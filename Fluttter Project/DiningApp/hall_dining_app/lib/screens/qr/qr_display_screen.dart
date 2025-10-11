import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/booking_model.dart';
import '../../core/widgets/custom_button.dart';

class QrDisplayScreen extends StatelessWidget {
  final Booking booking;

  const QrDisplayScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final qrData = 'HALL_DINING:${booking.id}:${booking.userId}:${booking.date?.millisecondsSinceEpoch}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal QR Code'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // QR Code
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 250,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Scan at meal counter',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Booking Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Booking Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Booking ID', booking.id.substring(0, 8)),
                    _buildDetailRow('Meal Type', booking.mealType.toUpperCase()),
                    _buildDetailRow('Date', _formatDate(booking.date)),
                    _buildDetailRow('Time', _getMealTime(booking.mealType)),
                    _buildDetailRow('Total Items', '${booking.items.length}'),
                    _buildDetailRow('Amount', '৳${booking.totalAmount}'),
                    const SizedBox(height: 12),
                    Chip(
                      label: Text(
                        booking.status.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _getStatusColor(booking.status as String),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Action Buttons
            Column(
              children: [
                CustomButton(
                  text: 'Share QR Code',
                  onPressed: () {
                    _shareQrCode(context);
                  },
                  backgroundColor: Colors.blue,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Instructions
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'How to use:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Present this QR code at the meal counter\n'
                      '• Ensure your phone brightness is high\n'
                      '• QR code will be scanned for verification\n'
                      '• Keep this code safe until meal is collected',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.blue;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getMealTime(String mealType) {
    switch (mealType) {
      case 'breakfast': return '8:00 AM - 10:00 AM';
      case 'lunch': return '12:00 PM - 2:00 PM';
      case 'dinner': return '7:00 PM - 9:00 PM';
      default: return 'TBD';
    }
  }

  void _shareQrCode(BuildContext context) {
    // TODO: Implement QR code sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR code sharing feature coming soon!')),
    );
  }
}