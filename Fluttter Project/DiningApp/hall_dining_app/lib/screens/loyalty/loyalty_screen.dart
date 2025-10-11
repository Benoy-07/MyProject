import 'package:flutter/material.dart';
import 'package:hall_dining_app/core/widgets/custom_button.dart';
import 'package:hall_dining_app/models/loyalty_model.dart';
import 'package:provider/provider.dart';
import '../../providers/loyalty_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/loading_widget.dart';
import 'redeem_screen.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({Key? key}) : super(key: key);

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  @override
  void initState() {
    super.initState();
    _loadLoyaltyData();
  }

  Future<void> _loadLoyaltyData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final loyaltyProvider = Provider.of<LoyaltyProvider>(context, listen: false);
    
    loyaltyProvider.initialize();
    await loyaltyProvider.loadUserLoyalty(authProvider.user!.uid);
  }

  @override
  Widget build(BuildContext context) {
    final loyaltyProvider = Provider.of<LoyaltyProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.isBengali ? 'লয়্যালটি প্রোগ্রাম' : 'Loyalty Program',
        ),
      ),
      body: loyaltyProvider.isLoading
          ? const LoadingWidget(message: 'Loading loyalty program...')
          : _buildLoyaltyContent(loyaltyProvider, languageProvider),
    );
  }

  Widget _buildLoyaltyContent(LoyaltyProvider loyaltyProvider, LanguageProvider languageProvider) {
    final userLoyalty = loyaltyProvider.userLoyalty;
    final program = loyaltyProvider.loyaltyProgram;

    if (userLoyalty == null || program == null) {
      return Center(
        child: Text(
          languageProvider.isBengali ? 'লয়্যালটি ডেটা লোড করতে ব্যর্থ' : 'Failed to load loyalty data',
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Points Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    languageProvider.isBengali ? 'আপনার লয়্যালটি পয়েন্ট' : 'Your Loyalty Points',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userLoyalty.availablePoints.toString(),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPointsStat(
                        userLoyalty.totalPoints.toString(),
                        languageProvider.isBengali ? 'মোট পয়েন্ট' : 'Total Points',
                      ),
                      _buildPointsStat(
                        userLoyalty.usedPoints.toString(),
                        languageProvider.isBengali ? 'ব্যবহৃত পয়েন্ট' : 'Points Used',
                      ),
                      _buildPointsStat(
                        userLoyalty.availablePoints.toString(),
                        languageProvider.isBengali ? 'উপলব্ধ পয়েন্ট' : 'Available Points',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Tier Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.workspace_premium, color: _getTierColor(userLoyalty.tier)),
                      const SizedBox(width: 8),
                      Text(
                        '${languageProvider.isBengali ? 'বর্তমান স্তর' : 'Current Tier'}: ${userLoyalty.tierName}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: loyaltyProvider.getTierProgressPercentage() / 100,
                    backgroundColor: AppColors.background,
                    color: _getTierColor(userLoyalty.tier),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        userLoyalty.tierName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        loyaltyProvider.getPointsToNextTier() > 0
                            ? '${loyaltyProvider.getPointsToNextTier()} ${languageProvider.isBengali ? 'পয়েন্ট প্রয়োজন' : 'points to next tier'}'
                            : languageProvider.isBengali ? 'সর্বোচ্চ স্তর' : 'Highest tier achieved',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loyaltyProvider.getTierBenefits(userLoyalty.tier),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Program Benefits
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageProvider.isBengali ? 'প্রোগ্রাম সুবিধা' : 'Program Benefits',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitItem(
                    Icons.restaurant,
                    languageProvider.isBengali ? 'প্রতি খাবারে পয়েন্ট' : 'Points per meal',
                    '${program.pointsPerMeal} ${languageProvider.isBengali ? 'পয়েন্ট' : 'points'}',
                  ),
                  _buildBenefitItem(
                    Icons.attach_money,
                    languageProvider.isBengali ? 'প্রতি টাকায় পয়েন্ট' : 'Points per taka spent',
                    '${program.pointsPerTaka} ${languageProvider.isBengali ? 'পয়েন্ট' : 'points'}',
                  ),
                  _buildBenefitItem(
                    Icons.discount,
                    languageProvider.isBengali ? 'ছাড়ের হার' : 'Discount rate',
                    '৳${program.discountPerPoint} ${languageProvider.isBengali ? 'প্রতি পয়েন্ট' : 'per point'}',
                  ),
                  _buildBenefitItem(
                    Icons.card_giftcard,
                    languageProvider.isBengali ? 'ন্যূনতম রিডিম' : 'Minimum redemption',
                    '${program.minPointsForRedemption} ${languageProvider.isBengali ? 'পয়েন্ট' : 'points'}',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Redeem Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageProvider.isBengali ? 'পয়েন্ট রিডিম করুন' : 'Redeem Points',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    languageProvider.isBengali
                        ? 'আপনার পয়েন্ট ডিসকাউন্টের জন্য রিডিম করুন'
                        : 'Redeem your points for discounts',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              languageProvider.isBengali ? 'সর্বোচ্চ ডিসকাউন্ট' : 'Maximum Discount',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '৳${userLoyalty.potentialDiscount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // CustomButton(
                      //   text: languageProvider.isBengali ? 'রিডিম করুন' : 'Redeem',
                      //   onPressed: userLoyalty.canRedeem
                      //       ? () {
                      //           Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //               builder: (context) => const RedeemScreen(),
                      //             ),
                      //           );
                      //         }
                      //       : null,
                      // ),
                    ],
                  ),
                  if (!userLoyalty.canRedeem) ...[
                    const SizedBox(height: 8),
                    Text(
                      languageProvider.isBengali
                          ? 'রিডিম করতে কমপক্ষে ${program!.minPointsForRedemption} পয়েন্ট প্রয়োজন'
                          : 'Minimum ${program!.minPointsForRedemption} points required for redemption',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Recent Transactions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageProvider.isBengali ? 'সাম্প্রতিক লেনদেন' : 'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (userLoyalty.transactions.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: AppColors.textDisabled,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            languageProvider.isBengali ? 'কোন লেনদেন নেই' : 'No transactions',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  else
                    ...userLoyalty.transactions.take(5).map((transaction) => _buildTransactionItem(transaction, languageProvider)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(transaction, LanguageProvider languageProvider) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: transaction.isEarned ? AppColors.success.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          transaction.isEarned ? Icons.add : Icons.remove,
          color: transaction.isEarned ? AppColors.success : AppColors.primary,
        ),
      ),
      title: Text(transaction.description),
      subtitle: Text(_formatDate(transaction.transactionDate)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${transaction.isEarned ? '+' : '-'}${transaction.points}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: transaction.isEarned ? AppColors.success : AppColors.error,
            ),
          ),
          Text(
            '${languageProvider.isBengali ? 'ব্যালেন্স' : 'Balance'}: ${transaction.balanceAfter}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Color _getTierColor(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return Colors.brown;
      case LoyaltyTier.silver:
        return Colors.grey;
      case LoyaltyTier.gold:
        return Colors.amber;
      case LoyaltyTier.platinum:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}