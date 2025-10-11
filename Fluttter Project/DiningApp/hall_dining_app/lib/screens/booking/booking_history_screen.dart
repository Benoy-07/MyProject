import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:hall_dining_app/models/booking_model.dart';
import 'package:hall_dining_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Column(
      children: [
        // Filter Chips
        Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  languageProvider.isBengali ? 'সব' : 'All',
                  'all',
                  languageProvider,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  languageProvider.isBengali ? 'আসন্ন' : 'Upcoming',
                  'upcoming',
                  languageProvider,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  languageProvider.isBengali ? 'সম্পন্ন' : 'Completed',
                  'completed',
                  languageProvider,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  languageProvider.isBengali ? 'বাতিল' : 'Cancelled',
                  'cancelled',
                  languageProvider,
                ),
              ],
            ),
          ),
        ),

        // Bookings List
        Expanded(
          child: bookingProvider.isLoading
              ? const LoadingWidget(message: 'Loading bookings...')
              : bookingProvider.error.isNotEmpty
                  ? ErrorWidget(
                      title: 'Error',
                      message: bookingProvider.error,
                      buttonText: 'Retry',
                      onRetry: () {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        bookingProvider.refreshBookings(authProvider.user!.uid);
                      },
                    )
                  : _buildBookingsList(bookingProvider, languageProvider),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, LanguageProvider languageProvider) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: _selectedFilter == value ? Colors.white : null,
      ),
    );
  }

  Widget _buildBookingsList(BookingProvider bookingProvider, LanguageProvider languageProvider) {
    List bookings = [];

    switch (_selectedFilter) {
      case 'all':
        bookings = bookingProvider.bookings;
        break;
      case 'upcoming':
        bookings = bookingProvider.upcomingBookings;
        break;
      case 'completed':
        bookings = bookingProvider.bookings.where((b) => b.status == BookingStatus.completed).toList();
        break;
      case 'cancelled':
        bookings = bookingProvider.bookings.where((b) => b.status == BookingStatus.cancelled).toList();
        break;
    }

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateMessage(languageProvider),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateSubtitle(languageProvider),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: _getStatusIcon(booking.status),
            title: Text(
              '${_getMealTypeDisplay(booking.mealType, languageProvider)} - ${booking.formattedBookingDate}',
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${booking.totalQuantity} ${languageProvider.isBengali ? 'আইটেম' : 'items'}'),
                Text(
                  '৳${booking.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            trailing: Chip(
              label: Text(
                booking.displayStatus,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
              backgroundColor: _getStatusColor(booking.status),
            ),
            onTap: () {
              _showBookingDetails(booking, languageProvider);
            },
          ),
        );
      },
    );
  }

  String _getEmptyStateMessage(LanguageProvider languageProvider) {
    switch (_selectedFilter) {
      case 'all':
        return languageProvider.isBengali ? 'কোন বুকিং নেই' : 'No bookings found';
      case 'upcoming':
        return languageProvider.isBengali ? 'কোন আসন্ন বুকিং নেই' : 'No upcoming bookings';
      case 'completed':
        return languageProvider.isBengali ? 'কোন সম্পন্ন বুকিং নেই' : 'No completed bookings';
      case 'cancelled':
        return languageProvider.isBengali ? 'কোন বাতিল বুকিং নেই' : 'No cancelled bookings';
      default:
        return languageProvider.isBengali ? 'কোন বুকিং নেই' : 'No bookings found';
    }
  }

  String _getEmptyStateSubtitle(LanguageProvider languageProvider) {
    switch (_selectedFilter) {
      case 'all':
        return languageProvider.isBengali 
            ? 'আপনার প্রথম বুকিং তৈরি করুন'
            : 'Make your first booking';
      case 'upcoming':
        return languageProvider.isBengali 
            ? 'আপনার আসন্ন বুকিং এখানে দেখানো হবে'
            : 'Your upcoming bookings will appear here';
      default:
        return languageProvider.isBengali 
            ? 'অনুগ্রহ করে পরে আবার চেক করুন'
            : 'Please check back later';
    }
  }

  Icon _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Icon(Icons.pending, color: Colors.orange);
      case BookingStatus.confirmed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case BookingStatus.preparing:
        return const Icon(Icons.restaurant, color: Colors.blue);
      case BookingStatus.ready:
        return const Icon(Icons.done_all, color: Colors.green);
      case BookingStatus.completed:
        return const Icon(Icons.verified, color: Colors.green);
      case BookingStatus.cancelled:
        return const Icon(Icons.cancel, color: Colors.red);
      case BookingStatus.expired:
        return const Icon(Icons.timer_off, color: Colors.grey);
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.preparing:
        return Colors.blue;
      case BookingStatus.ready:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.expired:
        return Colors.grey;
    }
  }

  String _getMealTypeDisplay(String mealType, LanguageProvider languageProvider) {
    switch (mealType) {
      case 'breakfast':
        return languageProvider.isBengali ? 'সকালের নাস্তা' : 'Breakfast';
      case 'lunch':
        return languageProvider.isBengali ? 'দুপুরের খাবার' : 'Lunch';
      case 'dinner':
        return languageProvider.isBengali ? 'রাতের খাবার' : 'Dinner';
      default:
        return mealType;
    }
  }

  void _showBookingDetails(booking, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          languageProvider.isBengali ? 'বুকিং বিবরণ' : 'Booking Details',
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                languageProvider.isBengali ? 'বুকিং আইডি' : 'Booking ID',
                '#${booking.id.substring(0, 8)}',
              ),
              _buildDetailRow(
                languageProvider.isBengali ? 'তারিখ' : 'Date',
                booking.formattedBookingDate,
              ),
              _buildDetailRow(
                languageProvider.isBengali ? 'খাবারের ধরন' : 'Meal Type',
                _getMealTypeDisplay(booking.mealType, languageProvider),
              ),
              _buildDetailRow(
                languageProvider.isBengali ? 'স্ট্যাটাস' : 'Status',
                booking.displayStatus,
              ),
              _buildDetailRow(
                languageProvider.isBengali ? 'মোট Amount' : 'Total Amount',
                '৳${booking.totalAmount.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 16),
              Text(
                languageProvider.isBengali ? 'আইটেমস' : 'Items',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ...booking.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('• ${item.menuItemName} - ৳${item.unitPrice.toStringAsFixed(2)}'),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(languageProvider.isBengali ? 'বন্ধ' : 'Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
}