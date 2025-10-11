import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../payment/payment_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final String bookingId;
  final double totalAmount;

  const BookingConfirmationScreen({
    Key? key,
    required this.bookingId,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.isBengali ? 'বুকিং নিশ্চিতকরণ' : 'Booking Confirmation',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Success Icon
            Icon(
              Icons.check_circle,
              size: 80,
              color: AppColors.success,
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              languageProvider.isBengali ? 'বুকিং সফল!' : 'Booking Successful!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Booking ID
            Text(
              '${languageProvider.isBengali ? 'বুকিং আইডি' : 'Booking ID'}: #${bookingId.substring(0, 8)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            
            const SizedBox(height: 8),
            
            // Amount
            Text(
              '${languageProvider.isBengali ? 'মোট Amount' : 'Total Amount'}: ৳${totalAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: AppColors.info),
                      title: Text(
                        languageProvider.isBengali ? 'পরবর্তী ধাপ' : 'Next Steps',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        languageProvider.isBengali
                            ? 'আপনার বুকিং সম্পূর্ণ করতে এখন পেমেন্ট করুন'
                            : 'Make payment now to complete your booking',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Payment Button
            CustomButton(
              text: languageProvider.isBengali ? 'এখনই Pay করুন' : 'Pay Now',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      totalAmount: totalAmount,
                      bookingId: bookingId,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // View Bookings Button
            CustomButton(
              text: languageProvider.isBengali ? 'বুকিং দেখুন' : 'View Bookings',
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              type: ButtonType.outline,
            ),
          ],
        ),
      ),
    );
  }
}