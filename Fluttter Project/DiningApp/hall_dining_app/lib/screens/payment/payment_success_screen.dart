import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final double amount;
  final String transactionId;

  const PaymentSuccessScreen({
    Key? key,
    required this.amount,
    required this.transactionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Success Icon
              Icon(
                Icons.check_circle,
                size: 100,
                color: AppColors.success,
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                languageProvider.isBengali ? 'পেমেন্ট সফল!' : 'Payment Successful!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),

              const SizedBox(height: 16),

              // Amount
              Text(
                '৳${amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),

              const SizedBox(height: 8),

              // Transaction ID
              Text(
                '${languageProvider.isBengali ? 'লেনদেন আইডি' : 'Transaction ID'}: #${transactionId.substring(0, 8)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
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
                        leading: const Icon(Icons.email, color: AppColors.info),
                        title: Text(
                          languageProvider.isBengali ? 'ইমেইল প্রাপ্তি' : 'Email Receipt',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          languageProvider.isBengali
                              ? 'একটি কনফার্মেশন ইমেইল পাঠানো হয়েছে'
                              : 'A confirmation email has been sent',
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.qr_code, color: AppColors.info),
                        title: Text(
                          languageProvider.isBengali ? 'কিউআর কোড' : 'QR Code',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          languageProvider.isBengali
                              ? 'আপনার বুকিংয়ের জন্য কিউআর কোড তৈরি করা হয়েছে'
                              : 'QR code has been generated for your booking',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Done Button
              CustomButton(
                text: languageProvider.isBengali ? 'সম্পন্ন' : 'Done',
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
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
      ),
    );
  }
}