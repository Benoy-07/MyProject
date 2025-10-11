import 'package:flutter/material.dart';
import 'package:hall_dining_app/models/event_model.dart';
import 'package:provider/provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String bookingId;

  const PaymentScreen({
    Key? key,
    required this.totalAmount,
    required this.bookingId,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    paymentProvider.initialize(authProvider.user!.uid);
  }

  Future<void> _processPayment() async {
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (authProvider.user == null) return;

    final result = await paymentProvider.processPayment(
      amount: widget.totalAmount,
      bookingId: widget.bookingId,
      userId: authProvider.user!.uid,
      userEmail: authProvider.user!.email!,
      userPhone: authProvider.user!.phoneNumber ?? '+8801XXXXXXXXX',
      method: paymentProvider.selectedMethod,
    );

    if (result.success) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              amount: widget.totalAmount,
              transactionId: result.transactionId!,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Payment failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.isBengali ? 'পেমেন্ট' : 'Payment',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.isBengali ? 'অর্ডার সারাংশ' : 'Order Summary',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      languageProvider.isBengali ? 'বুকিং আইডি' : 'Booking ID',
                      '#${widget.bookingId.substring(0, 8)}',
                    ),
                    _buildSummaryRow(
                      languageProvider.isBengali ? 'মোট Amount' : 'Total Amount',
                      '৳${widget.totalAmount.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Payment Methods
            Text(
              languageProvider.isBengali ? 'পেমেন্ট পদ্ধতি নির্বাচন করুন' : 'Select Payment Method',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: [
                  _buildPaymentMethod(
                    Icons.credit_card,
                    languageProvider.isBengali ? 'ক্রেডিট/ডেবিট কার্ড' : 'Credit/Debit Card',
                    'Stripe এর মাধ্যমে সুরক্ষিত',
                    PaymentMethod.stripe,
                    languageProvider,
                  ),
                  _buildPaymentMethod(
                    Icons.payment,
                    'SSLCommerz',
                    languageProvider.isBengali ? 'স্থানীয় পেমেন্ট গেটওয়ে' : 'Local payment gateway',
                    PaymentMethod.sslcommerz,
                    languageProvider,
                  ),
                  _buildPaymentMethod(
                    Icons.phone_android,
                    'Nagad',
                    languageProvider.isBengali ? 'মোবাইল ফাইন্যান্স' : 'Mobile finance',
                    PaymentMethod.nagad,
                    languageProvider,
                  ),
                  _buildPaymentMethod(
                    Icons.phone_iphone,
                    'bKash',
                    languageProvider.isBengali ? 'মোবাইল ফাইন্যান্স' : 'Mobile finance',
                    PaymentMethod.bkash,
                    languageProvider,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pay Button
            // CustomButton(
            //   text: languageProvider.isBengali ? 'এখনই Pay করুন' : 'Pay Now',
            //   onPressed: paymentProvider.isProcessing ? null : _processPayment,
            //   isLoading: paymentProvider.isProcessing,
            // ),

            if (paymentProvider.error.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                paymentProvider.error,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(
    IconData icon,
    String title,
    String subtitle,
    PaymentMethod method,
    LanguageProvider languageProvider,
  ) {
    final paymentProvider = Provider.of<PaymentProvider>(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile<PaymentMethod>(
        value: method,
        groupValue: paymentProvider.selectedMethod,
        onChanged: (PaymentMethod? value) {
          if (value != null) {
            paymentProvider.setSelectedMethod(value);
          }
        },
        title: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}