import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/loyalty_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';

class RedeemScreen extends StatefulWidget {
  const RedeemScreen({Key? key}) : super(key: key);

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  final _pointsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pointsController.addListener(_updatePoints);
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  void _updatePoints() {
    final points = int.tryParse(_pointsController.text) ?? 0;
    Provider.of<LoyaltyProvider>(context, listen: false).setPointsToRedeem(points);
  }

  Future<void> _redeemPoints() async {
    final loyaltyProvider = Provider.of<LoyaltyProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (loyaltyProvider.pointsToRedeem == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.isBengali
                ? 'অনুগ্রহ করে রিডিম করার জন্য পয়েন্ট নির্বাচন করুন'
                : 'Please select points to redeem',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // In a real app, you would link this to a booking
    final success = await loyaltyProvider.redeemPoints(
      loyaltyProvider.pointsToRedeem,
      'temp_booking_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageProvider.isBengali
                  ? 'পয়েন্ট সফলভাবে রিডিম করা হয়েছে!'
                  : 'Points redeemed successfully!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loyaltyProvider.error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loyaltyProvider = Provider.of<LoyaltyProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final userLoyalty = loyaltyProvider.userLoyalty;
    final program = loyaltyProvider.loyaltyProgram;

    if (userLoyalty == null || program == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final maxRedeemable = userLoyalty.availablePoints.clamp(0, program.maxRedemptionPerOrder);
    final discount = loyaltyProvider.calculateDiscount(loyaltyProvider.pointsToRedeem);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.isBengali ? 'পয়েন্ট রিডিম করুন' : 'Redeem Points',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available Points
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.card_giftcard, color: AppColors.primary, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            languageProvider.isBengali ? 'উপলব্ধ পয়েন্ট' : 'Available Points',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            userLoyalty.availablePoints.toString(),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Points Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.isBengali ? 'রিডিম করার পয়েন্ট' : 'Points to Redeem',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _pointsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: languageProvider.isBengali ? 'পয়েন্ট সংখ্যা লিখুন' : 'Enter points amount',
                        suffixText: languageProvider.isBengali ? 'পয়েন্ট' : 'points',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${languageProvider.isBengali ? 'সর্বোচ্চ' : 'Maximum'}: $maxRedeemable ${languageProvider.isBengali ? 'পয়েন্ট' : 'points'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Select Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.isBengali ? 'দ্রুত নির্বাচন' : 'Quick Select',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [100, 250, 500, 1000].where((points) => points <= maxRedeemable).map((points) {
                        return FilterChip(
                          label: Text('$points'),
                          selected: loyaltyProvider.pointsToRedeem == points,
                          onSelected: (selected) {
                            _pointsController.text = points.toString();
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: loyaltyProvider.pointsToRedeem == points ? Colors.white : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Discount Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.isBengali ? 'ডিসকাউন্ট সারাংশ' : 'Discount Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow(
                      languageProvider.isBengali ? 'রিডিম করা পয়েন্ট' : 'Points to Redeem',
                      '${loyaltyProvider.pointsToRedeem} ${languageProvider.isBengali ? 'পয়েন্ট' : 'points'}',
                    ),
                    _buildSummaryRow(
                      languageProvider.isBengali ? 'ডিসকাউন্টের হার' : 'Discount Rate',
                      '৳${program.discountPerPoint} ${languageProvider.isBengali ? 'প্রতি পয়েন্ট' : 'per point'}',
                    ),
                    const Divider(),
                    _buildSummaryRow(
                      languageProvider.isBengali ? 'মোট ডিসকাউন্ট' : 'Total Discount',
                      '৳${discount.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.success),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              languageProvider.isBengali
                                  ? 'এই ডিসকাউন্ট আপনার পরবর্তী অর্ডারে প্রয়োগ করা হবে'
                                  : 'This discount will be applied to your next order',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Redeem Button
            // CustomButton(
            //   text: languageProvider.isBengali ? 'পয়েন্ট রিডিম করুন' : 'Redeem Points',
            //   onPressed: loyaltyProvider.pointsToRedeem > 0 ? _redeemPoints : null,
            //   isLoading: loyaltyProvider.isLoading,
            // ),

            const SizedBox(height: 16),

            // Terms and Conditions
            Text(
              languageProvider.isBengali
                  ? '• পয়েন্ট রিডিম করা যাবে শুধুমাত্র বৈধ অর্ডারের জন্য\n• রিডিম করা পয়েন্ট ফেরত দেওয়া যাবে না\n• প্রতিটি অর্ডারে সর্বোচ্চ ${program.maxRedemptionPerOrder} পয়েন্ট রিডিম করা যাবে'
                  : '• Points can only be redeemed for valid orders\n• Redeemed points cannot be refunded\n• Maximum ${program.maxRedemptionPerOrder} points can be redeemed per order',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                : null,
          ),
          Text(
            value,
            style: isTotal
                ? const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.success,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}