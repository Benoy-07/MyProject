import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import 'booking_confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedMealType = 'lunch';
  final _specialInstructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _specialInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _createBooking() async {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (menuProvider.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.isBengali 
                ? 'কার্টে কোন আইটেম নেই'
                : 'No items in cart',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (authProvider.user == null) return;

    final result = await bookingProvider.createBooking(
      userId: authProvider.user!.uid,
      userEmail: authProvider.user!.email,
      userName: authProvider.user!.name,
      bookingDate: _selectedDate,
      mealType: _selectedMealType,
      items: menuProvider.cartItems,
      subtotal: menuProvider.cartTotal,
      tax: menuProvider.cartTotal * 0.05, // 5% tax
      totalAmount: menuProvider.cartTotal * 1.05,
      specialInstructions: _specialInstructionsController.text.isNotEmpty
          ? {'instructions': _specialInstructionsController.text}
          : null,
    );

    if (result.success) {
      menuProvider.clearCart();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationScreen(
              bookingId: result.bookingId!,
              totalAmount: menuProvider.cartTotal * 1.05,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Booking failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.isBengali ? 'বুকিং' : 'Booking',
        ),
      ),
      body: menuProvider.cartItems.isEmpty
          ? _buildEmptyCart(languageProvider)
          : _buildBookingForm(menuProvider, languageProvider),
    );
  }

  Widget _buildEmptyCart(LanguageProvider languageProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 16),
          Text(
            languageProvider.isBengali ? 'কার্ট খালি' : 'Cart is Empty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            languageProvider.isBengali 
                ? 'বুকিং করতে প্রথমে কিছু আইটেম কার্টে যোগ করুন'
                : 'Add some items to cart to make a booking',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: languageProvider.isBengali ? 'মেনু দেখুন' : 'View Menu',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookingForm(MenuProvider menuProvider, LanguageProvider languageProvider) {
    return SingleChildScrollView(
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
                  ...menuProvider.cartItems.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.name),
                        Text('৳${item.price.toStringAsFixed(2)}'),
                      ],
                    ),
                  )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(languageProvider.isBengali ? 'সাবটোটাল' : 'Subtotal'),
                      Text('৳${menuProvider.cartTotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(languageProvider.isBengali ? 'ট্যাক্স (৫%)' : 'Tax (5%)'),
                      Text('৳${(menuProvider.cartTotal * 0.05).toStringAsFixed(2)}'),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        languageProvider.isBengali ? 'মোট' : 'Total',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '৳${(menuProvider.cartTotal * 1.05).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Date Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageProvider.isBengali ? 'তারিখ' : 'Date',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () => _selectDate(context),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Meal Type Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageProvider.isBengali ? 'খাবারের ধরন' : 'Meal Type',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedMealType,
                    items: [
                      DropdownMenuItem(
                        value: 'breakfast',
                        child: Text(languageProvider.isBengali ? 'সকালের নাস্তা' : 'Breakfast'),
                      ),
                      DropdownMenuItem(
                        value: 'lunch',
                        child: Text(languageProvider.isBengali ? 'দুপুরের খাবার' : 'Lunch'),
                      ),
                      DropdownMenuItem(
                        value: 'dinner',
                        child: Text(languageProvider.isBengali ? 'রাতের খাবার' : 'Dinner'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedMealType = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Special Instructions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageProvider.isBengali ? 'বিশেষ নির্দেশনা' : 'Special Instructions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _specialInstructionsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: languageProvider.isBengali 
                          ? 'কোন বিশেষ নির্দেশনা...'
                          : 'Any special instructions...',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Book Now Button
          CustomButton(
            text: languageProvider.isBengali ? 'এখনই বুক করুন' : 'Book Now',
            onPressed: _createBooking,
          ),
        ],
      ),
    );
  }
}